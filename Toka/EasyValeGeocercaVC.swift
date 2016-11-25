//
//  EasyValeGeocercaVC.swift
//  Toka
//
//  Created by Martin Viruete Gonzalez on 21/06/16.
//  Copyright © 2016 oOMovil. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import CoreLocation

class EasyValeGeocercaVC: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    
    @IBOutlet weak var imageViewLogo: UIImageView!
    @IBOutlet weak var map: MKMapView!
    
    var easyVale: EasyVale!
    var locationManager: CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageViewLogo.downloadImageFrom(link: easyVale.logo, contentMode: .ScaleAspectFit)
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.descargarSucursales()
    }
    
    @IBAction func regresar(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func verTodasSucursales(){
        let sucursalesVC = self.storyboard?.instantiateViewControllerWithIdentifier("EasyValeSucursalesVC") as! EasyValeSucursalesVC
        sucursalesVC.easyVale = self.easyVale
        self.navigationController?.pushViewController(sucursalesVC, animated: true)
    }
    
    func descargarSucursales(){
        let url: String = Utils.URL_SERVICIOS.stringByReplacingOccurrencesOfString("servicio", withString: Servicios.EasyValeSucursales.rawValue)
        let parameters: [String:String] = ["estab":self.easyVale.idEsyvale]
        Alamofire.request(.GET, url,parameters: parameters).responseJSON { (response) in
            guard let data = response.data where response.result.isSuccess else {
                print(response.result.error)
                return
            }
            let json = JSON(data: data)
            if Utils.debugging { print(json) }
            for easyVale in json["data"].arrayValue{
                let nuevaSucursal: Sucursal = Sucursal()
                nuevaSucursal.idEsyvale_sucursales = easyVale["idEsyvale_sucursales"].string ?? ""
                nuevaSucursal.nombre = easyVale["nombre"].string ?? ""
                nuevaSucursal.estado = easyVale["estado"].string ?? ""
                nuevaSucursal.ciudad = easyVale["ciudad"].string ?? ""
                nuevaSucursal.establecimiento = easyVale["establecimiento"].string ?? ""
                nuevaSucursal.latlng = easyVale["latlng"].string ?? ""
                nuevaSucursal.direccion = easyVale["direccion"].string ?? ""
                self.easyVale.sucursales.append(nuevaSucursal)
            }
            self.mostrarSucursales()
        }
    }
    
    func mostrarSucursales(){
        var pinesSucursales: [PinSucursal] = [PinSucursal]()
        for sucursal in self.easyVale.sucursales{
            let cordenadasString: [String] = sucursal.latlng.componentsSeparatedByString(",")
            let latitud: Double = Double(cordenadasString.first ?? "0") ?? 0.0
            let longitud: Double = Double(cordenadasString.last ?? "0") ?? 0.0
            let coordenada: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
            pinesSucursales.append(PinSucursal(title: self.easyVale.nombre, locationName: sucursal.nombre, discipline: "", coordinate: coordenada))
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
            // Resize image
            let pinImage = UIImage(named: "iconshop")
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
