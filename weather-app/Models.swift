import Foundation


struct WeatherResponse: Decodable {
    let main: MainWeather
    let weather: [Weather]
    let wind: Wind
    let name: String
}

struct MainWeather: Decodable {
    let temp: Double
    let humidity: Int
}

struct Weather: Decodable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Wind: Decodable {
    let speed: Double
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case cityNotFound
    case serverError
    
    var message: String {
        switch self {
        case .invalidURL:
            return "Некорректный URL"
        case .noData:
            return "Нет данных"
        case .decodingError:
            return "Ошибка при обработке данных"
        case .cityNotFound:
            return "Город не найден"
        case .serverError:
            return "Ошибка сервера"
        }
    }
}
