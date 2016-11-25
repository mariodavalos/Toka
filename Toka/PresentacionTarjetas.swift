//
//  PresentacionTarjetas.swift
//  TOKA
//
//  Created by Martin Viruete Gonzalez on 05/07/16.
//
//

import UIKit

class PresentacionTarjetas: UIViewController,UITableViewDelegate,UITableViewDataSource,Popup2Delegate,SOAPDelegate,PopupDelegate,CarruselDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var vistaTarjetas: UIView!
    @IBOutlet weak var imagenEstado: UIImageView!
    @IBOutlet weak var flechaDerecha: UIButton!
    @IBOutlet weak var flechaIzquierda: UIButton!
    
    var tarjetas = [Tarjetas]()
    var verTarjetas = false
    var indexTarjetas = 0
    var currentIndex = 0
    
    var pass = ""
    var email = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = NSURL(string: "http://www.toka.com.mx/app/sliderApp"){
           let request = NSURLRequest(URL: url)
            self.webView.loadRequest(request)
        }
        
        for vc in self.childViewControllers{
            if let carrusel = vc as? CarruselTarjetas{
                carrusel.delegateT = self
            }
        }
        self.obtenerTarjetas()
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    @IBAction func verCerrarTarjetas(){
        if !verTarjetas{
            UIView.animateWithDuration(0.6, animations: {
                self.vistaTarjetas.frame.offsetInPlace(dx: 0.0, dy: self.view.frame.size.height * -0.63)
                self.imagenEstado.image = UIImage(named: "ios_mistarjetas_down")
            })
        }else{
            UIView.animateWithDuration(0.6, animations: {
                self.vistaTarjetas.frame.offsetInPlace(dx: 0.0, dy: self.view.frame.size.height * 0.63)
                self.imagenEstado.image = UIImage(named: "ios_mistarjetas_up")
            })
        }
        self.verTarjetas = !self.verTarjetas
    }
    
    @IBAction func agregarTarjeta(){
        self.verTarjetas = false
        self.imagenEstado.image = UIImage(named: "ios_mistarjetas_up")
        dispatch_async(dispatch_get_main_queue()) {
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("AgregarTarjetas")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tarjetas.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.height * 0.1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TarjetaCell",forIndexPath: indexPath) as! TarjetaCell
        let tarjeta = self.tarjetas[indexPath.row]
        cell.etiqueta.text = tarjeta.etiqueta
        var numero = tarjeta.numero
        numero.removeRange(tarjeta.numero.startIndex...tarjeta.numero.endIndex.advancedBy(-5))
        cell.numero.text = "************" + numero
        cell.editar.tag = indexPath.row
        cell.editar.addTarget(self, action: #selector(self.editarTarjeta(_:)), forControlEvents: .TouchUpInside)
        cell.borrar.tag = indexPath.row
        cell.borrar.addTarget(self, action: #selector(self.borrarTarjeta(_:)), forControlEvents: .TouchUpInside)
        cell.grafica.tag = indexPath.row
        cell.grafica.addTarget(self, action: #selector(self.verEstadistica(_:)), forControlEvents: .TouchUpInside)
        
        if (indexPath.row % 2) != 0{
            cell.backgroundColor = UIColor(red: 28/255, green: 35/255, blue: 120/255, alpha: 1.0)
        }else{
            cell.backgroundColor = UIColor(red: 26/255, green: 61/255, blue: 144/255, alpha: 1.0)
        }
        
        return cell
    }
    
    func verEstadistica(sender: UIButton){
        self.verCerrarTarjetas()
        for vc in self.childViewControllers{
            if let carrusel = vc as? CarruselTarjetas{
                carrusel.moveToIndex(sender.tag)
            }
        }
    }
    
    func editarTarjeta(sender: UIButton){
        self.verTarjetas = false
        self.imagenEstado.image = UIImage(named: "ios_mistarjetas_up")
        let editarVC = self.storyboard?.instantiateViewControllerWithIdentifier("EditarTarjeta") as! EditarTarjeta
        editarVC.tarjeta = self.tarjetas[sender.tag]
        self.navigationController?.pushViewController(editarVC, animated: true)
    }
    
    func borrarTarjeta(sender: UIButton){
        let tarjeta = self.tarjetas[sender.tag]
        self.indexTarjetas = sender.tag
        let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup2") as! Popup2
        popUp.mensaje = "¿Confirmas que deseas eliminar la tarjeta: \(tarjeta.etiqueta)?"
        popUp.buttonIcon2 = UIImage(named: "ios_btn_eliminar")
        popUp.buttonIcon = UIImage(named: "ios_btn_cancelar")
        popUp.icono = UIImage(named: "ios_icono_alerta")
        popUp.delegate = self
        self.presentViewController(popUp, animated: false, completion: nil)
    }
    
    func didTouchSecondButton() {
        let loadingView = self.storyboard?.instantiateViewControllerWithIdentifier("LoadingView") as! LoadingView
        self.presentViewController(loadingView, animated: false, completion: nil)
        if let usuario = Usuario.getCurrent(){
            if usuario.id == ""{
                self.email = usuario.email
                self.pass = usuario.password
                let params = ["Email":usuario.email,"Password":usuario.password]
                let soap = SOAP(action: .Login, params: params, delegate: self)
                soap.callRequest()
            }else{
                
                let tarjeta = self.tarjetas[self.indexTarjetas]
                let params = ["Tarjeta":tarjeta.numero,
                              "IdUsuario": usuario.id]
                let soap = SOAP(action: .BorrarTarjeta, params: params, delegate: self)
                soap.callRequest()
            }
        }
    }
    
    func didRecieveXML(XML: XMLIndexer, action: Services) {
        
        if action == Services.Login{
            do {
                if let data = try XML.byKey("soap:Envelope").byKey("soap:Body").byKey("getUserResponse").byKey("getUserResult").byKey("NewDataSet").byKey("Table").all.first{
                    let clave = try data.byKey("clave").element?.text ?? ""
                    let nombre = try data.byKey("nombre").element?.text ?? ""
                    let apellidos = try data.byKey("apellidos").element?.text ?? ""
                    let celular = data["celular"].element?.text ?? ""
                    let id = try data.byKey("id").element?.text ?? ""
                    let email = self.email
                    let pass = self.pass
                    let userData = ["clave":clave,"nombre":nombre,"apellidos":apellidos,"id":id,"email":email,"password":pass,"celular":celular]
                    NSUserDefaults.standardUserDefaults().setObject(userData, forKey: Utils.USER_DATA)
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: Utils.LOGGED)
                    NSUserDefaults.standardUserDefaults().setValue(id, forKey: Utils.USER_ID)
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        let tarjeta = self.tarjetas[self.indexTarjetas]
                        let params = ["Tarjeta":tarjeta.numero,
                            "IdUsuario": id]
                        let soap = SOAP(action: .BorrarTarjeta, params: params, delegate: self)
                        soap.callRequest()
                    })
                    
                }
            }catch let error as XMLIndexer.Error{
                print(error.description)
            }catch {
            }

        }else{
            dispatch_async(dispatch_get_main_queue(), {
                self.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
            })
            do {
                if let data = try XML.byKey("soap:Envelope").byKey("soap:Body").byKey("deleteCardResponse").byKey("deleteCardResult").byKey("NewDataSet").byKey("Table").all.first{
                    if let res = data["Res"].element?.text{
                        if res == "SUCCESS"{
                            dispatch_async(dispatch_get_main_queue(), {
                                let popup = self.storyboard?.instantiateViewControllerWithIdentifier("Popup") as! Popup
                                popup.mensaje = "Ajustes realizados con éxito"
                                popup.icono = UIImage(named: "ios_icono_exitoso")
                                popup.delegate = self
                                popup.buttonIcon = UIImage(named: "ios_btn_aceptar")
                                self.presentViewController(popup, animated: false, completion: nil)
                            })
                        }else{
                            dispatch_async(dispatch_get_main_queue()) {
                                self.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
                                let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup2") as! Popup2
                                popUp.mensaje = "No es posible conectarse con el servidor en estos momentos."
                                popUp.buttonIcon2 = UIImage(named: "ios_btn_reintentar")
                                popUp.buttonIcon = UIImage(named: "ios_btn_cancelar")
                                popUp.icono = UIImage(named: "ios_icono_alerta")
                                popUp.delegate = self
                                self.presentViewController(popUp, animated: false, completion: nil)
                            }
                        }
                    }else{
                        dispatch_async(dispatch_get_main_queue()) {
                            self.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
                            let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup2") as! Popup2
                            popUp.mensaje = "No es posible conectarse con el servidor en estos momentos."
                            popUp.buttonIcon2 = UIImage(named: "ios_btn_reintentar")
                            popUp.buttonIcon = UIImage(named: "ios_btn_cancelar")
                            popUp.icono = UIImage(named: "ios_icono_alerta")
                            popUp.delegate = self
                            self.presentViewController(popUp, animated: false, completion: nil)
                        }
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
                        let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup2") as! Popup2
                        popUp.mensaje = "No es posible conectarse con el servidor en estos momentos."
                        popUp.buttonIcon2 = UIImage(named: "ios_btn_reintentar")
                        popUp.buttonIcon = UIImage(named: "ios_btn_cancelar")
                        popUp.icono = UIImage(named: "ios_icono_alerta")
                        popUp.delegate = self
                        self.presentViewController(popUp, animated: false, completion: nil)
                    }
                }
            }catch let error as XMLIndexer.Error{
                print(error.description)
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
                    let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup2") as! Popup2
                    popUp.mensaje = "No es posible conectarse con el servidor en estos momentos."
                    popUp.buttonIcon2 = UIImage(named: "ios_btn_reintentar")
                    popUp.buttonIcon = UIImage(named: "ios_btn_cancelar")
                    popUp.icono = UIImage(named: "ios_icono_alerta")
                    popUp.delegate = self
                    self.presentViewController(popUp, animated: false, completion: nil)
                }
            }catch {
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
                    let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup2") as! Popup2
                    popUp.mensaje = "No es posible conectarse con el servidor en estos momentos."
                    popUp.buttonIcon2 = UIImage(named: "ios_btn_reintentar")
                    popUp.buttonIcon = UIImage(named: "ios_btn_cancelar")
                    popUp.icono = UIImage(named: "ios_icono_alerta")
                    popUp.delegate = self
                    self.presentViewController(popUp, animated: false, completion: nil)
                }
            }
        }
        
        
    }
    
    func didFailReceivingXML(error: String) {
        dispatch_async(dispatch_get_main_queue()) {
            self.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
            let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup2") as! Popup2
            popUp.mensaje = "No encontramos conexión a internet. Porfavor, verifica tu conexión."
            popUp.buttonIcon2 = UIImage(named: "ios_btn_reintentar")
            popUp.buttonIcon = UIImage(named: "ios_btn_cancelar")
            popUp.icono = UIImage(named: "ios_icono_conexion")
            popUp.delegate = self
            self.presentViewController(popUp, animated: false, completion: nil)
        }
    }
    
    func didTouchButton() {
        if let slider = self.slideMenuController(){
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MisTarjetasNC")
            slider.changeMainViewController(vc!, close: true)
        }
    }
    
    func didClick() {
        
    }
    
    func moveToIndex(index: Int) {
        self.currentIndex = index
        self.flechaIzquierda.hidden = false
        self.flechaIzquierda.enabled = true
        self.flechaDerecha.hidden = false
        self.flechaDerecha.enabled = true
        if self.currentIndex == self.tarjetas.count - 1{
            self.flechaDerecha.hidden = true
            self.flechaDerecha.enabled = false
        }
        if self.currentIndex == 0{
            self.flechaIzquierda.hidden = true
            self.flechaIzquierda.enabled = false
        }
    }
    
    @IBAction func siguienteTarjeta(){
        self.currentIndex += 1
        if self.currentIndex == self.tarjetas.count - 1{
            self.flechaDerecha.hidden = true
            self.flechaDerecha.enabled = false
        }
        self.flechaIzquierda.hidden = false
        self.flechaIzquierda.enabled = true
        for vc in self.childViewControllers{
            if let carrusel = vc as? CarruselTarjetas{
                carrusel.moveToIndex(self.currentIndex)
            }
        }
    }
    
    @IBAction func anteriorTarjeta(){
        self.currentIndex -= 1
        if self.currentIndex == 0{
            self.flechaIzquierda.hidden = true
            self.flechaIzquierda.enabled = false
        }
        self.flechaDerecha.hidden = false
        self.flechaDerecha.enabled = true
        for vc in self.childViewControllers{
            if let carrusel = vc as? CarruselTarjetas{
                carrusel.moveToIndex(self.currentIndex)
            }
        }
    }

    func obtenerTarjetas(){
        let defaults = NSUserDefaults.standardUserDefaults()
        if let tarjetas = defaults.valueForKey(Utils.USER_CARDS) as? [[String:String]]{
            for tarjeta in tarjetas{
                let numero = tarjeta["tarjeta"] ?? "NULL"
                let etiqueta = tarjeta["etiqueta"] ?? "NULL"
                let marca = tarjeta["Marca"] ?? "NULL"
                self.tarjetas.append(Tarjetas(numero: numero, etiqueta: etiqueta, marca: marca))
            }
        }
        if self.tarjetas.count == 1{
            self.flechaDerecha.hidden = true
            self.flechaDerecha.enabled = false
            self.flechaIzquierda.enabled = false
            self.flechaIzquierda.hidden = true
        }else{
            if self.tarjetas.count > 1{
                self.flechaDerecha.hidden = false
                self.flechaDerecha.enabled = true
                self.flechaIzquierda.enabled = true
                self.flechaIzquierda.hidden = true
            }
            if NSUserDefaults.standardUserDefaults().boolForKey("VER_ULTIMO"){
                self.currentIndex = self.tarjetas.count - 1
                self.flechaDerecha.hidden = true
                self.flechaDerecha.enabled = false
                self.flechaIzquierda.enabled = true
                self.flechaIzquierda.hidden = false
                NSUserDefaults.standardUserDefaults().setBool(false,forKey: "VER_ULTIMO")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        self.tableView.reloadData()
    }
}
