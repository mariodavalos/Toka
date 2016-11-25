//
//  EasyGasUbicacionEstablecimiento.swift
//  TOKA
//
//  Created by Martin Viruete Gonzalez on 08/07/16.
//
//
import UIKit
import MapKit
import Alamofire
import CoreLocation

class EasyGasUbicacionEstablecimiento: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    
    @IBOutlet weak var labelNombre: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    var easyGas: EasyGas!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        self.labelNombre.text = self.easyGas.nombre + "\n" + self.easyGas.ciudad + "," + self.easyGas.estado
        
        self.mostrarSucursales()
    }
    
    @IBAction func regresar(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func verTodas(){
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func mostrarSucursales(){
        var pinesSucursales: [PinSucursal] = [PinSucursal]()
        let cordenadasString: [String] = easyGas.latlng.componentsSeparatedByString(",")
        let latitud: Double = Double(cordenadasString.first ?? "0") ?? 0.0
        let longitud: Double = Double(cordenadasString.last ?? "0") ?? 0.0
        let coordenada: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
        pinesSucursales.append(PinSucursal(title: easyGas.nombre, locationName: easyGas.nombre, discipline: "", coordinate: coordenada))
        self.map.addAnnotations(pinesSucursales)
        self.centerMapOnLocation(CLLocation(latitude: latitud, longitude: longitud))
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse && CLLocationManager.locationServicesEnabled(){
            self.map.showsUserLocation = true
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.distanceFilter = 200
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        NSLog("latitude %+.6f, longitude %+.6f\n",location.coordinate.latitude,location.coordinate.longitude)
        self.locationManager.stopUpdatingLocation()
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 900
        let coordinateRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,regionRadius * 2.0, regionRadius * 2.0)
        self.map.setRegion(coordinateRegion, animated: false)
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? PinSucursal {
            let identifier = "pin"
            var view: MKAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier){
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
            }
            // Resize image
            let pinImage = UIImage(named: "icongas")
            let size = CGSize(width: 30, height: 30)
            UIGraphicsBeginImageContext(size)
            pinImage!.drawInRect(CGRectMake(0, 0, size.width, size.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            view.image = resizedImage
            return view
        }
        return nil
    }
    
}