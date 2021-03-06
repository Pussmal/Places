//
//  MapViewController.swift
//  Places
//
//  Created by Алексей Моторин on 14.04.2022.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate: AnyObject {
    func sendAdress(_ adress: String)
}

class MapViewController: UIViewController {
    
    var place = Places()
    let identifier = "identifier"
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 1000
    var adress: String = ""
    var placeCoordinate: CLLocationCoordinate2D? // принимает координаты места заведение
    var directionsArray = [MKDirections]()
    var previousLocation: CLLocation? {
        didSet {
            startTracerUserLocation()
        }
    }
    
    weak var delegate: MapViewControllerDelegate?
    
    private var mapKit: MKMapView = {
        let mapView = MKMapView(frame: UIScreen.main.bounds)
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        return mapView
    }()
    
    private lazy var closeMapButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "closeButton"), for: .normal)
        button.addTarget(self, action: #selector(closeMap), for: .touchUpInside)
        return button
    }()
    
    private lazy var myLocationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "myLocation"), for: .normal)
        button.addTarget(self, action: #selector(showMyLocation), for: .touchUpInside)
        return button
    }()
    
    lazy var imageMarker: UIImageView = {
        let image = UIImageView(image: UIImage(named: "marker"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.clipsToBounds = true
        return image
    }()
    
    lazy var adresslabel: UILabel = {
        let lable = UILabel()
        lable.translatesAutoresizingMaskIntoConstraints = false
        lable.font = UIFont(name: "Apple Sd Gothic Neo", size: 25)
        lable.textAlignment = .center
        return lable
    }()
    
    private lazy var distanceAndTimeLabel: UILabel = {
        let lable = UILabel()
        lable.translatesAutoresizingMaskIntoConstraints = false
        lable.font = UIFont(name: "Apple Sd Gothic Neo", size: 25)
        lable.textAlignment = .center
        lable.numberOfLines = 2
        lable.isHidden = true
        return lable
    }()
    
    lazy var addAdressButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Добавить адрес", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(addAdress), for: .touchUpInside)
        return button
    }()
    
    lazy var getDirectionsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "GetDirection"), for: .normal)
        button.addTarget(self, action: #selector(getDirections), for: .touchUpInside)
        return button
    }()
    
    lazy var imageDone: UIImageView = {
        let image = UIImageView(image: UIImage(named: "done"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.isHidden = true
        return image
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupPlaceMark()
        checkLocationAutorization()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(mapKit)
        mapKit.delegate = self
        
        mapKit.addSubview(closeMapButton)
        mapKit.addSubview(myLocationButton)
        mapKit.addSubview(imageMarker)
        mapKit.addSubview(adresslabel)
        mapKit.addSubview(addAdressButton)
        mapKit.addSubview(imageDone)
        mapKit.addSubview(getDirectionsButton)
        mapKit.addSubview(distanceAndTimeLabel)
        
        NSLayoutConstraint.activate([
            closeMapButton.topAnchor.constraint(equalTo: mapKit.topAnchor, constant: 60),
            closeMapButton.trailingAnchor.constraint(equalTo: mapKit.trailingAnchor, constant: -40),
            closeMapButton.heightAnchor.constraint(equalToConstant: 30),
            closeMapButton.widthAnchor.constraint(equalToConstant: 30),
            
            myLocationButton.bottomAnchor.constraint(equalTo: mapKit.bottomAnchor, constant: -170),
            myLocationButton.trailingAnchor.constraint(equalTo: mapKit.trailingAnchor, constant: -40),
            myLocationButton.heightAnchor.constraint(equalToConstant: 50),
            myLocationButton.widthAnchor.constraint(equalToConstant: 50),
            
            imageMarker.centerXAnchor.constraint(equalTo: mapKit.centerXAnchor),
            imageMarker.centerYAnchor.constraint(equalTo: mapKit.centerYAnchor, constant: -20),
            imageMarker.heightAnchor.constraint(equalToConstant: 40),
            imageMarker.widthAnchor.constraint(equalToConstant: 40),
            
            adresslabel.centerXAnchor.constraint(equalTo: mapKit.centerXAnchor),
            adresslabel.topAnchor.constraint(equalTo: mapKit.topAnchor, constant: 80),
            adresslabel.trailingAnchor.constraint(equalTo: mapKit.trailingAnchor, constant: -10),
            adresslabel.leadingAnchor.constraint(equalTo: mapKit.leadingAnchor, constant: 10),
            adresslabel.heightAnchor.constraint(equalToConstant: 70),
            
            distanceAndTimeLabel.centerXAnchor.constraint(equalTo: mapKit.centerXAnchor),
            distanceAndTimeLabel.topAnchor.constraint(equalTo: mapKit.topAnchor, constant: 80),
            distanceAndTimeLabel.trailingAnchor.constraint(equalTo: mapKit.trailingAnchor, constant: -10),
            distanceAndTimeLabel.leadingAnchor.constraint(equalTo: mapKit.leadingAnchor, constant: 10),
            distanceAndTimeLabel.heightAnchor.constraint(equalToConstant: 70),
            
            addAdressButton.centerXAnchor.constraint(equalTo: mapKit.centerXAnchor),
            addAdressButton.bottomAnchor.constraint(equalTo: mapKit.bottomAnchor, constant: -80),
            addAdressButton.heightAnchor.constraint(equalToConstant: 50),
            addAdressButton.widthAnchor.constraint(equalToConstant: 170),
            
            imageDone.centerXAnchor.constraint(equalTo: mapKit.centerXAnchor),
            imageDone.bottomAnchor.constraint(equalTo: mapKit.bottomAnchor, constant: -80),
            imageDone.heightAnchor.constraint(equalToConstant: 50),
            imageDone.widthAnchor.constraint(equalToConstant: 50),
            
            getDirectionsButton.centerXAnchor.constraint(equalTo: mapKit.centerXAnchor),
            getDirectionsButton.bottomAnchor.constraint(equalTo: mapKit.bottomAnchor, constant: -80),
            getDirectionsButton.heightAnchor.constraint(equalToConstant: 50),
            getDirectionsButton.widthAnchor.constraint(equalToConstant: 50)
            
        ])
    }
    
    @objc private func closeMap() {
        dismiss(animated: true)
    }
    
    // сохраняем адрес в строке locationTextField, меняем картинку на "done", затем через секунду закрываем контроллер
    @objc private func addAdress() {
        addAdressButton.showAnimation {
            self.delegate?.sendAdress(self.adress)
            self.addAdressButton.isHidden = true
            self.imageDone.isHidden = false
            
                let timer = Timer(timeInterval: 1.0,
                                  target: self,
                                  selector: #selector(self.updateImages),
                                  userInfo: nil,
                                  repeats: false)
                RunLoop.current.add(timer, forMode: .common)
                timer.tolerance = 0.1
        }
    }
    
    @objc private func updateImages() {
        dismiss(animated: true)
    }
    
    @objc private func showMyLocation() {
        showUserLocation()
    }
    
    // MARK: постройка маршрута
    @objc private func getDirections() {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Ошибка", message: "локация не определена")
            return
        }
        
        locationManager.startUpdatingLocation() // режим постоянного отслеживания текущего местоположения пользователя
        previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        guard let request = creatDirectionRequest(from: location) else {
            showAlert(title: "Ошибка", message: "местоположение не определено")
            return
        }
        
        let directions = MKDirections(request: request) // создаем маршрут
        resetMapView(withNew: directions)
        // запускаем расчет маршрута
        directions.calculate { (response, error) in
            if let error = error {
                print(error)
                return
            }
            // если ошибки нет извлекаем обработанный маршрут
            guard let response = response else {
                self.showAlert(title: "Ошибка", message: "Маршрут не построен")
                return
            }
            // респонс содержит в себе массив с маршрутами, если не запращивать альтернативные маршруты, тогда будет не больше одного, каждый обект содержит сведения о геометории которую можно отобразить на карте, имея эти данные мы можем создать на карте маршрут
            for route in response.routes {
                self.mapKit.addOverlay(route.polyline) // добавляем маршрут
                self.mapKit.setVisibleMapRect(route.polyline.boundingMapRect, animated: true) // метод чтобы маршрут был виден целиком
                
                self.distanceAndTimeLabel.text = "Расстояние: \(String(format: "%.1f", route.distance / 1000)) км\nПримерное время: \(String(format: "%.0f",route.expectedTravelTime / 60)) мин."
                self.distanceAndTimeLabel.isHidden = false
            }
        }
    }
        
    private func creatDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        // передаем координаты заведения
        guard let destinationCoordinate = placeCoordinate else { return nil }
        // определяем точку старта маршрута
        let startLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        // создаем запрос на построение маршрута от точки а до точки б
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .walking // вид транспорта
        request.requestsAlternateRoutes = true // построение альтерантивных маршрутов
        return request
    }
    
    func showUserLocation() {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapKit.setRegion(region, animated: true)
        }
    }
    
    private func startTracerUserLocation() {
        guard let previousLocation = previousLocation else { return }
        let center = getCenterLocation(for: mapKit)
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3)  {
            self.showUserLocation()
        }
        

    }
    
    // получаем координаты точки на центре экрана
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func resetMapView(withNew directions: MKDirections) {
        mapKit.removeOverlays(mapKit.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    
    private func setupPlaceMark() {
        guard let location = place.locationPlace else { return }
        
        // класс позваляет преобразовать координаты широты и долготы
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            // используется для описания точки на карте
            let annotation = MKPointAnnotation()
            annotation.title = self.place.namePlace
            annotation.subtitle = self.place.typePlace
            
            
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            self.mapKit.showAnnotations([annotation], animated: true)
            self.mapKit.selectAnnotation(annotation, animated: true)
            
        }
    }
    
    private func checkLocationServices() {
        // проверка включена ли геолокация
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAutorization()
        } else {
            showAlert(title: "Включите геолокацию", message: "Настройки - включить геолокацию")
        }
        
    }
    
    private func setupLocationManager() {
        // определение места нахождение
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // проверка статуса на использование геопозиции
    private func checkLocationAutorization() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Ваша локация недоступна", message: "Перейдите в настройки Places -> Геолокация")
            }
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            mapKit.showsUserLocation = true
            break
            
        @unknown default:
            fatalError()
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    // отображение аннтонации
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // если проверяем отображение пользователя, тогда выходим из метода
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
        }
        
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        geocoder.cancelGeocode()
        
        
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    self.adresslabel.text = "\(streetName!), \(buildNumber!)"
                    self.adress = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.adresslabel.text = "\(streetName!)"
                    self.adress = "\(streetName!)"
                } else {
                    self.adresslabel.text = ""
                    self.adress = ""
                }
            }
            
        }
        
    }
    
    // метод подсвечивает маршруты в нужном цвете, так как маршруты невидны, нужно сделать наложение
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAutorization()
    }
}

