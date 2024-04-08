import Dependencies
import MapKit

public final class SearchPlacesService: NSObject {
    
    public let publisher: ((SearchPlaceLocation) -> Void)? = nil
    public var locationResults: [SearchPlaceLocation] = []
        
    public var completer: MKLocalSearchCompleter = {
        var completer = MKLocalSearchCompleter()
        completer.resultTypes = [.address, .pointOfInterest, .query]
        return completer
    }()

    public override init() {
        super.init()
        completer.delegate = self
    }
    
    public func locationResultsStream() -> AsyncStream<[SearchPlaceLocation]> {
        return AsyncStream { continuation in
            continuation.yield(locationResults)
        }
    }
    
    public func publish(_ location: SearchPlaceLocation) {
        self.publisher?(location)
    }
}

//MARK: - MKLocalSearchCompleterDelegate
extension SearchPlacesService: MKLocalSearchCompleterDelegate {
    
    public func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        locationResults = completer.results.map { .init(title: $0.title, subtitle: $0.subtitle) }
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
