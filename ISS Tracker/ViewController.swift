import UIKit
import GoogleMaps

class ViewController: UIViewController {

    var camera = GMSCameraPosition.camera(withLatitude: 37.7749, longitude: -122.4194, zoom: 6) {
        didSet {
            mapView.camera = camera
        }
    }
    var marker: GMSMarker? {
        didSet {
            if let position = marker?.position {
                let newPosition = GMSCameraPosition.camera(withLatitude: position.latitude, longitude: position.longitude, zoom: 3.5)
                mapView.animate(to: newPosition)
                //mapView.animate(toLocation: CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude))
                marker?.snippet = "\(position.latitude),\(position.longitude)"
            }
        }
    }
    lazy var mapView : GMSMapView = {
        let view = GMSMapView.map(withFrame: .zero, camera: camera)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var activeTask : URLSessionDataTask?
    var refreshTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        refreshTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(timerFetch), userInfo: nil, repeats: true)
    }

    @objc
    func timerFetch() {
        fetchISSLocation {location in
            guard let location = location else {
                return
            }

            if let marker = self.marker {
                marker.position = CLLocationCoordinate2D(latitude: location.position.latitude, longitude: location.position.longitude)
            } else {
                self.marker = GMSMarker(position: CLLocationCoordinate2D(latitude: location.position.latitude, longitude: location.position.longitude))
                self.marker?.title = "ISS"
                self.marker?.isDraggable = false
                self.marker?.map = self.mapView
            }
        }
    }

    func fetchISSLocation(completion: @escaping (ISSLocationResponse?) -> () = { _ in }) {

        guard activeTask == nil else {
            completion(nil)
            return
        }

        if let url = URL(string: "http://api.open-notify.org/iss-now.json") {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    let statusCodeRange = 200..<300
                    guard let httpResponse = response as? HTTPURLResponse, statusCodeRange.contains(httpResponse.statusCode) else {
                        completion(nil)
                        return
                    }
                    if let data = data {
                        do {
                            let issResponse = try JSONDecoder().decode(ISSLocationResponse.self, from: data)
                            completion(issResponse)
                        } catch let error {
                            print(error)
                        }
                    }
                    self.activeTask = nil
                }
            }
            task.resume()
            self.activeTask = task
        }
    }

}
