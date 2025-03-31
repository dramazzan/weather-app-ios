import Foundation

class WeatherViewModel {
    private let apiKey = "4e8cbe9bf26c33afe1a6c7c31a8a0bbb"
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    
    var weatherData: WeatherResponse?
    
    var onWeatherDataUpdate: (() -> Void)?
    var onErrorOccurred: ((String) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    
    func fetchWeather(for city: String) {
        guard !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            onErrorOccurred?("Пожалуйста, введите название города")
            return
        }
        
        onLoadingStateChanged?(true)
        
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?q=\(encodedCity)&appid=\(apiKey)&units=metric&lang=ru") else {
            onErrorOccurred?(NetworkError.invalidURL.message)
            onLoadingStateChanged?(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.onLoadingStateChanged?(false)
                
                if let error = error {
                    self.onErrorOccurred?(error.localizedDescription)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.onErrorOccurred?(NetworkError.serverError.message)
                    return
                }
                
                switch httpResponse.statusCode {
                case 200:
                    guard let data = data else {
                        self.onErrorOccurred?(NetworkError.noData.message)
                        return
                    }
                    
                    do {
                        let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                        self.weatherData = weatherResponse
                        self.onWeatherDataUpdate?()
                    } catch {
                        self.onErrorOccurred?(NetworkError.decodingError.message)
                    }
                case 404:
                    self.onErrorOccurred?(NetworkError.cityNotFound.message)
                default:
                    self.onErrorOccurred?(NetworkError.serverError.message)
                }
            }
        }.resume()
    }
    
    func formattedTemperature() -> String {
        guard let temp = weatherData?.main.temp else { return "N/A" }
        return String(format: "%.1f°C", temp)
    }
    
    func formattedHumidity() -> String {
        guard let humidity = weatherData?.main.humidity else { return "N/A" }
        return "\(humidity)%"
    }
    
    func formattedWindSpeed() -> String {
        guard let speed = weatherData?.wind.speed else { return "N/A" }
        return String(format: "%.1f м/с", speed)
    }
    
    func weatherDescription() -> String {
        guard let description = weatherData?.weather.first?.description else { return "N/A" }
        return description.capitalized
    }
    
    func cityName() -> String {
        return weatherData?.name ?? "N/A"
    }
}
