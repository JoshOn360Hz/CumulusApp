import SwiftUI
import CoreLocation

enum TabSelection: String, CaseIterable {
    case weather = "weather"
    case search = "search"
    case settings = "settings"
}

class AppStateManager: ObservableObject {
    @Published var selectedTab: TabSelection = .weather
    @Published var selectedLocation: CLLocation?
    @Published var selectedCityName: String?
    
    func selectLocationAndSwitchToWeather(location: CLLocation, cityName: String) {
        selectedLocation = location
        selectedCityName = cityName
        selectedTab = .weather
    }
}
