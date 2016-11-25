//
//  EasyGasVC.swift
//  TOKA
//
//  Created by Martin Viruete Gonzalez on 08/07/16.
//
//

import UIKit
import MapKit
import Alamofire
import CoreLocation


class EasyGasVC: UIViewController,UITextFieldDelegate,CLLocationManagerDelegate,MKMapViewDelegate {
    
    @IBOutlet weak var textFiedlBusqueda: UITextField!
    @IBOutlet weak var map: MKMapView!
    
    var locationManager: CLLocationManager!
    var easyGasArray: [EasyGas] = [EasyGas]()
    var filtroBusqueda: [EasyGas] = [EasyGas]()
    var filtro: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.descargarEasyGas()
    }
    
    func descargarEasyGas(){
        let url: String = Utils.URL_SERVICIOS.stringByReplacingOccurrencesOfString("servicio", withString: Servicios.EasyGas.rawValue)
        Alamofire.request(.GET, url).responseJSON { (response) in
            guard let data = response.data where response.result.isSuccess else {
                print(response.result.error)
                return
            }
            self.easyGasArray.removeAll()
            let json = JSON(data: data)
            if Utils.debugging { print(json) }
            for easyVale in json["data"].arrayValue{
                let nuevoEasyGas: EasyGas = EasyGas()
                nuevoEasyGas.ciudad = easyVale["ciudad"].string ?? ""
                nuevoEasyGas.nombre = easyVale["nombre"].string ?? ""
                nuevoEasyGas.estado = easyVale["estado"].string ?? ""
                nuevoEasyGas.idEasygas = easyVale["idEasygas"].string ?? ""
                nuevoEasyGas.latlng = easyVale["latlng"].string ?? ""
                self.easyGasArray.append(nuevoEasyGas)
            }
            self.mostrarSucursales()
        }
    }
    
    @IBAction func buscar(){
        if let busqueda = self.filtro{
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("EasyGasEstaciones") as! EasyGasEstaciones
            vc.buscando = true
            vc.easyGasArray = self.easyGasArray
            vc.filtroBusqueda = self.filtroBusqueda
            vc.filtro = busqueda
            self.view.endEditing(true)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func mostrarSucursales(){
        var pinesSucursales: [PinSucursal] = [PinSucursal]()
        for gas in self.easyGasArray{
            let cordenadasString: [String] = gas.latlng.componentsSeparatedByString(",")
            let latitud: Double = Double(cordenadasString.first ?? "0") ?? 0.0
            let longitud: Double = Double(cordenadasString.last ?? "0") ?? 0.0
            let coordenada: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
            pinesSucursales.append(PinSucursal(title: gas.nombre, locationName: gas.nombre, discipline: "", coordinate: coordenada))
        }
        self.map.addAnnotations(pinesSucursales)
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
        self.centerMapOnLocation(location)
        self.locationManager.stopUpdatingLocation()
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1800
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
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string == "" && textField.text!.characters.count == 1{
            self.filtro = ""
            return true
        }
        self.filtroBusqueda = self.easyGasArray.filter{ store in
            let busqueda = (string != "") ? self.textFiedlBusqueda.text! + string : String(self.textFiedlBusqueda.text!.characters.dropLast())
            self.filtro = busqueda
            return store.nombre.lowercaseString.containsString(busqueda.lowercaseString)
        }
        return true
    }
}
