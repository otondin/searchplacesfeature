import Dependencies
import MapKit

public class SearchPlacesService: NSObject {
    
    
    public var locationResults: [MKLocalSearchCompletion] = []
        
    public var completer: MKLocalSearchCompleter = {
        var completer = MKLocalSearchCompleter()
        completer.resultTypes = [.address, .pointOfInterest, .query]
        return completer
    }()

    public override init() {
        super.init()
        completer.delegate = self
    }
    
    public func locationResultsStream() -> AsyncStream<[MKLocalSearchCompletion]> {
        return AsyncStream { continuation in
            continuation.yield(locationResults) // TODO: create a model to avoid importing MapKit on faeture side
        }
    }
}

//MARK: - MKLocalSearchCompleterDelegate
extension SearchPlacesService: MKLocalSearchCompleterDelegate {
    
    public func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        locationResults = completer.results
    }
    
    public func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        print(error.localizedDescription)
    }
}

public enum SearchPlacesServiceKey: DependencyKey {
    public static let liveValue = SearchPlacesService()
}

public extension DependencyValues {
    var searchPlacesService: SearchPlacesService {
        get { self[SearchPlacesServiceKey.self] }
        set { self[SearchPlacesServiceKey.self] = newValue }
    }
}
