import SwiftUI
import CoreLocation

class AppStateManager: ObservableObject {
    @Published var selectedTabIndex: Int = 0
    @Published var selectedLocation: CLLocation?
    @Published var selectedCityName: String?
    
    func selectLocationAndSwitchToWeather(location: CLLocation, cityName: String) {
        selectedLocation = location
        selectedCityName = cityName
        selectedTabIndex = 0     }
}
