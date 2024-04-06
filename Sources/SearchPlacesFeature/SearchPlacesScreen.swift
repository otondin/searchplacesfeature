import SwiftUI
import ComposableArchitecture
import MapKit

@Reducer
public struct SearchPlacesFeature {
    
    public init() {}
    
    @Dependency(\.searchPlacesService) var searchPlacesService
    
    @ObservableState
    public struct State: Equatable {
        
        public init() {}
        
        var searchText = ""
        var locationResults: [MKLocalSearchCompletion] = []
        var selectedLocation: MKLocalSearchCompletion?
    }
    
    @CasePathable
    public enum Action: Equatable, BindableAction {
        case searchQuery(String)
        case setSelectedLocation(MKLocalSearchCompletion?)
        case locationResultsSubscriber
        case locationResultsPublisher([MKLocalSearchCompletion])
        case binding(BindingAction<State>)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case let .searchQuery(query):
                searchPlacesService.completer.queryFragment = query
                return .none
                
            case let .setSelectedLocation(location):
                state.selectedLocation = location
                return .none
                
            case .locationResultsSubscriber:
                return .run { send in
                    for await locationResults in searchPlacesService.locationResultsStream() {
                        await send(.locationResultsPublisher(locationResults))
                    }
                }
                                
            case let .locationResultsPublisher(locationResults):
                state.locationResults = locationResults
                return .none

            case .binding:
                // catch-all
                return .none
            }
        }
    }
}

public struct SearchPlacesScreen: View {
    @Perception.Bindable var store: StoreOf<SearchPlacesFeature>
    
    public init(store: StoreOf<SearchPlacesFeature>) {
        self.store = store
    }
   
    public var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                List(store.locationResults, id: \.self) { location in
                    Button {
                        store.send(.setSelectedLocation(location))
                    } label : {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(location.title)
                            Text(location.subtitle)
                        }
                    }
                }
                .listStyle(.plain)
                .padding(8)
            }
            .searchable(text: $store.searchText.sending(\.searchQuery), prompt: "Search...")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SearchPlacesScreen(
        store: .init(
            initialState: .init(),
            reducer: {
                SearchPlacesFeature()
            }
        )
    )
}
