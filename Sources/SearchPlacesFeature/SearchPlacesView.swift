import SwiftUI
import MapKit
import ComponentLibrary
import Localization

public struct SearchPlacesView: View {
    @StateObject var model = SearchPlacesModel()
    
    public var delegate: SearchPlacesDelegate?
    
    public init() {}
        
    public var body: some View {
        NavigationStack {
            List(model.locationResults, id: \.self) { location in
                Button {
                    selectLocation(location)
                } label : {
                    VStack(alignment: .leading, spacing: Spacing.padding0) {
                        Text(location.title)
                        Text(location.subtitle)
                    }
                }
            }
            .listStyle(.plain)
            .padding(Spacing.padding2)
        }
        .searchable(text: $model.searchText, prompt: L10n.General.search)
        .onChange(of: model.searchText) { newValue in
            model.completer.queryFragment = newValue
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension SearchPlacesView {
    
    func selectLocation(_ location: MKLocalSearchCompletion) {
        let address = "\(location.title), \(location.subtitle)"
        delegate?.didSelectLocation(address)
    }
}

#Preview {
    SearchPlacesView()
}
