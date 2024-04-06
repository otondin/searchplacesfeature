import SwiftUI
import MapKit

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
                    VStack(alignment: .leading, spacing: 0) {
                        Text(location.title)
                        Text(location.subtitle)
                    }
                }
            }
            .listStyle(.plain)
            .padding(8)
        }
        .searchable(text: $model.searchText, prompt: "Search...")
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
