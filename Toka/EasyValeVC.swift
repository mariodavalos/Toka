//
//  EasyValeVC.swift
//  Toka
//
//  Created by Martin Viruete Gonzalez on 20/06/16.
//  Copyright © 2016 oOMovil. All rights reserved.
//

import UIKit
import Alamofire

class EasyValeVC: UIViewController, UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textFiedlBusqueda: UITextField!
    
    var easyValeArray: [EasyVale] = [EasyVale]()
    var filtroBusqueda: [EasyVale] = [EasyVale]()
    var buscando = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.descargarEasyVale()
    }
    
    func descargarEasyVale(){
        let url: String = Utils.URL_SERVICIOS.stringByReplacingOccurrencesOfString("servicio", withString: Servicios.EasyVale.rawValue)
        Alamofire.request(.GET, url).responseJSON { (response) in
            guard let data = response.data where response.result.isSuccess else {
                print(response.result.error)
                return
            }
            self.easyValeArray.removeAll()
            let json = JSON(data: data)
            if Utils.debugging { print(json) }
            for easyVale in json["data"].arrayValue{
                let nuevoEasyVale: EasyVale = EasyVale()
                nuevoEasyVale.idEsyvale = easyVale["idEsyvale"].string ?? ""
                nuevoEasyVale.nombre = easyVale["nombre"].string ?? ""
                nuevoEasyVale.fecha_alta = easyVale["fecha_alta"].string ?? ""
                nuevoEasyVale.logo = easyVale["logo"].string ?? ""
                self.easyValeArray.append(nuevoEasyVale)
            }
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.buscando{
            return self.filtroBusqueda.count
        }
        return self.easyValeArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: EasyValeCell = collectionView.dequeueReusableCellWithReuseIdentifier("EasyValeCell", forIndexPath: indexPath) as! EasyValeCell
        let easyVale: EasyVale = (self.buscando) ? self.filtroBusqueda[indexPath.row] : self.easyValeArray[indexPath.row]
        //guard let logoURL: NSURL = NSURL(string: easyVale.logo) else { return cell }
        cell.imageViewLogo.downloadImageFrom(link: easyVale.logo, contentMode: .ScaleAspectFit)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let easyVale: EasyVale = (self.buscando) ? self.filtroBusqueda[indexPath.row] : self.easyValeArray[indexPath.row]
        let easyValeGeocercaVC: EasyValeGeocercaVC = self.storyboard?.instantiateViewControllerWithIdentifier("EasyValeGeocercaVC") as! EasyValeGeocercaVC
        easyValeGeocercaVC.easyVale = easyVale
        self.navigationController?.pushViewController(easyValeGeocercaVC, animated: true)
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        return CGSize(width: self.view.frame.size.width * 0.45, height: self.view.frame.size.width * 0.2)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.buscando = false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.buscando = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string == "" && textField.text!.characters.count == 1{
            self.buscando = false
            print("EN BLANCO")
        }else{
            self.buscando = true
            self.filtroBusqueda = self.easyValeArray.filter{ store in
                let busqueda = (string != "") ? self.textFiedlBusqueda.text! + string : String(self.textFiedlBusqueda.text!.characters.dropLast())
                return store.nombre.lowercaseString.containsString(busqueda.lowercaseString)
            }
        }
        self.collectionView.reloadData()
        return true
    }
}

// Images downloader
extension UIImageView {
    func downloadImageFrom(link link:String, contentMode: UIViewContentMode) {
        NSURLSession.sharedSession().dataTaskWithURL( NSURL(string:link)!, completionHandler: {
            (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.contentMode =  contentMode
                if let data = data { self.image = UIImage(data: data) }
            }
        }).resume()
    }
}

