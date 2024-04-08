import Foundation

public struct SearchPlaceLocation: Identifiable, Codable, Hashable, Equatable {
    public let id = UUID()
    public let title: String
    public let subtitle: String
}
