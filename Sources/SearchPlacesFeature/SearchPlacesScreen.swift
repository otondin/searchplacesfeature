import SwiftUI
import ComposableArchitecture

@Reducer
public struct SearchPlacesFeature {
    
    public init() {}
    
    @Dependency(\.searchPlacesService) var searchPlacesService
    
    @ObservableState
    public struct State: Equatable {
        
        public init() {}
        
        var searchText = ""
        var locationResults: [SearchPlaceLocation] = []
        var selectedLocation: SearchPlaceLocation?
    }
    
    @CasePathable
    public enum Action: Equatable, BindableAction {
        case onAppear
        case searchQuery(String)
        case setSelectedLocation(SearchPlaceLocation?)
        case locationResultsSubscriber
        case locationResultsPublisher([SearchPlaceLocation])
        case binding(BindingAction<State>)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
            .onChange(of: \.searchText) { oldValue, newValue in
                Reduce { state, action in
                    return .send(.searchQuery(newValue))
                }
            }

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.locationResultsSubscriber)
                
            case let .searchQuery(query):
                searchPlacesService.completer.queryFragment = query
                return .send(.locationResultsSubscriber)
                
            case let .setSelectedLocation(location):
                guard let location
                else { return .none }
                
                state.selectedLocation = location
                searchPlacesService.publish(location)
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
            .onAppear {
                store.send(.onAppear)
            }
            .searchable(text: $store.searchText, prompt: "Search...")
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
