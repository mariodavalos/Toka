//
//  MisTarjetas.swift
//  TOKA
//
//  Created by Martin Viruete Gonzalez on 04/07/16.
//
//

import UIKit

class MisTarjetas: UIViewController,SOAPDelegate {
    
    @IBOutlet weak var vistaAgregarTarjetas: UIView!
    @IBOutlet weak var vistaError: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var labelNombre: UILabel!
    @IBOutlet weak var labelNombre2: UILabel!
    
    var usuario : Usuario?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.usuario = Usuario.getCurrent()
        if self.usuario != nil{
            self.labelNombre.text = self.usuario!.nombre + " " + self.usuario!.apellidos
            self.labelNombre2.text = self.usuario!.nombre + " " + self.usuario!.apellidos
            self.editarPerfil()
            self.cargarTarjetas()
        }
    }
    
    func editarPerfil(){
        let params = ["Nombre":self.usuario!.nombre,
                      "Apellidos":self.usuario!.apellidos,
                      "Email":self.usuario!.email,
                      "Password":self.usuario!.password,
                      "Token":self.usuario!.token,
                      "Celular":self.usuario!.celular]
        
        let soap = SOAP(action: .EditarPerfil, params: params, delegate: self)
        soap.callRequest()
    }
    
    func cargarTarjetas(){
        let params = ["Email":self.usuario!.email]
        let soap = SOAP(action: .Tarjetas, params: params, delegate: self)
        soap.callRequest()
    }
    
    @IBAction func agregarTarjeta(){
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("AgregarTarjetas")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func reintentar(){
        self.cargarTarjetas()
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - SOAPDelegate
    func didRecieveXML(XML: XMLIndexer,action: Services) {
        if action != .EditarPerfil{
            do {
                if let data = try XML.byKey("soap:Envelope").byKey("soap:Body").byKey("getUserCardsResponse").byKey("getUserCardsResult").byKey("NewDataSet").byKey("Table").all.first{
                    if let res = data["Res"].element?.text{
                        if res == "VACIO"{
                            dispatch_async(dispatch_get_main_queue(), {
                                self.spinner.stopAnimating()
                                if let url = NSURL(string: "http://www.toka.com.mx/app/sliderApp"){
                                    let request = NSURLRequest(URL: url)
                                    self.webView.loadRequest(request)
                                }
                                self.vistaError.hidden = true
                                self.vistaAgregarTarjetas.hidden = false
                            })
                        }
                    }else{
                        var tarjetas = [[String:String]]()
                        for tarjeta in try XML.byKey("soap:Envelope").byKey("soap:Body").byKey("getUserCardsResponse").byKey("getUserCardsResult").byKey("NewDataSet").byKey("Table").all{
                            let tarjetanum = try tarjeta.byKey("tarjeta").element?.text ?? ""
                            let etiqueta = try tarjeta.byKey("etiqueta").element?.text ?? ""
                            let Marca = try tarjeta.byKey("Marca").element?.text ?? ""
                            tarjetas.append(["tarjeta":tarjetanum,"etiqueta":etiqueta,"Marca":Marca])
                        }
                        NSUserDefaults.standardUserDefaults().setObject(tarjetas, forKey: Utils.USER_CARDS)
                        NSUserDefaults.standardUserDefaults().synchronize()
                        dispatch_async(dispatch_get_main_queue(), {
                            self.spinner.stopAnimating()
                            if let controller = self.storyboard?.instantiateViewControllerWithIdentifier("PresentacionTarjetas") {
                                self.navigationController?.setViewControllers([controller], animated: false)
                            }
                        })
                    }
                }
            }catch let error as XMLIndexer.Error{
                print(error.description)
                dispatch_async(dispatch_get_main_queue()) {
                    self.spinner.stopAnimating()
                    self.vistaError.hidden = false
                    self.vistaAgregarTarjetas.hidden = true
                }
            }catch {
                dispatch_async(dispatch_get_main_queue()) {
                    self.spinner.stopAnimating()
                    self.vistaError.hidden = false
                    self.vistaAgregarTarjetas.hidden = true
                }
            }
        }
    }
    
    func didFailReceivingXML(error: String) {
        dispatch_async(dispatch_get_main_queue()) {
            self.spinner.stopAnimating()
            self.vistaError.hidden = false
            self.vistaAgregarTarjetas.hidden = true
        }
    }
}
