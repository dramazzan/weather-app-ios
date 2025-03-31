import UIKit

class WeatherViewController: UIViewController {
    
    private let viewModel = WeatherViewModel()
    
    private let cityTextField = UITextField()
    private let searchButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let weatherStackView = UIStackView()
    private let cityLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let weatherDescriptionLabel = UILabel()
    private let humidityLabel = UILabel()
    private let windSpeedLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Погода"
        
        cityTextField.placeholder = "Введите название города"
        cityTextField.borderStyle = .roundedRect
        cityTextField.returnKeyType = .search
        cityTextField.delegate = self
        
        searchButton.setTitle("Получить погоду", for: .normal)
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        
        activityIndicator.hidesWhenStopped = true
        
        let searchStackView = UIStackView(arrangedSubviews: [cityTextField, searchButton])
        searchStackView.axis = .horizontal
        searchStackView.spacing = 8
        searchStackView.distribution = .fillProportionally
        
        cityLabel.font = UIFont.boldSystemFont(ofSize: 24)
        cityLabel.textAlignment = .center
        
        temperatureLabel.font = UIFont.systemFont(ofSize: 36, weight: .semibold)
        temperatureLabel.textAlignment = .center
        
        weatherDescriptionLabel.font = UIFont.systemFont(ofSize: 18)
        weatherDescriptionLabel.textAlignment = .center
        
        humidityLabel.font = UIFont.systemFont(ofSize: 16)
        humidityLabel.textAlignment = .center
        
        windSpeedLabel.font = UIFont.systemFont(ofSize: 16)
        windSpeedLabel.textAlignment = .center
        
        weatherStackView.axis = .vertical
        weatherStackView.spacing = 12
        weatherStackView.alignment = .center
        weatherStackView.addArrangedSubview(cityLabel)
        weatherStackView.addArrangedSubview(temperatureLabel)
        weatherStackView.addArrangedSubview(weatherDescriptionLabel)
        weatherStackView.addArrangedSubview(humidityLabel)
        weatherStackView.addArrangedSubview(windSpeedLabel)
        weatherStackView.isHidden = true
        
        view.addSubview(searchStackView)
        view.addSubview(activityIndicator)
        view.addSubview(weatherStackView)
        
        searchStackView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        weatherStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            cityTextField.heightAnchor.constraint(equalToConstant: 44),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: searchStackView.bottomAnchor, constant: 40),
            
            weatherStackView.topAnchor.constraint(equalTo: searchStackView.bottomAnchor, constant: 40),
            weatherStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            weatherStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupBindings() {
        viewModel.onWeatherDataUpdate = { [weak self] in
            guard let self = self else { return }
            self.updateUI()
            self.weatherStackView.isHidden = false
            
            self.weatherStackView.alpha = 0
            UIView.animate(withDuration: 0.5) {
                self.weatherStackView.alpha = 1
            }
        }
        
        viewModel.onErrorOccurred = { [weak self] message in
            let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
        
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            if isLoading {
                self?.activityIndicator.startAnimating()
                self?.weatherStackView.isHidden = true
            } else {
                self?.activityIndicator.stopAnimating()
            }
        }
    }
    
    private func updateUI() {
        cityLabel.text = viewModel.cityName()
        temperatureLabel.text = viewModel.formattedTemperature()
        weatherDescriptionLabel.text = viewModel.weatherDescription()
        humidityLabel.text = "Влажность: \(viewModel.formattedHumidity())"
        windSpeedLabel.text = "Скорость ветра: \(viewModel.formattedWindSpeed())"
    }
    
    @objc private func searchButtonTapped() {
        view.endEditing(true)
        if let city = cityTextField.text {
            viewModel.fetchWeather(for: city)
        }
    }
}

extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchButtonTapped()
        return true
    }
}
