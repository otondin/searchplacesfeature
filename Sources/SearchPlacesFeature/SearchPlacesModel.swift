import MapKit

public class SearchPlacesModel: NSObject, ObservableObject {
    @Published public var searchText = ""
    @Published public var locationResults: [MKLocalSearchCompletion] = []
    
    public var completer: MKLocalSearchCompleter = {
        var completer = MKLocalSearchCompleter()
        completer.resultTypes = [.address, .pointOfInterest, .query]
        return completer
    }()
    
    override init() {
        super.init()
        completer.delegate = self
    }
}

extension SearchPlacesModel: MKLocalSearchCompleterDelegate {
    
    public func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        locationResults = completer.results
    }
    
    public func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        print(error.localizedDescription)
    }
}
