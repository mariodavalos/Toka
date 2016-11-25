//
//  EditarTarjeta.swift
//  TOKA
//
//  Created by Martin Viruete Gonzalez on 09/07/16.
//
//

import UIKit

class EditarTarjeta: UIViewController,UITextFieldDelegate,SOAPDelegate,Popup2Delegate {
    
    
    @IBOutlet weak var textFieldAlias: UITextField!
    @IBOutlet weak var textFieldNumero: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var keyBoardIsVisible = false
    var tarjeta: Tarjetas!
    var email = ""
    var pass = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(self.keyboardWillShow(_:)),name: UIKeyboardWillShowNotification,object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(self.keyboardWillHide(_:)),name: UIKeyboardWillHideNotification,object: nil)
        self.textFieldAlias.text = self.tarjeta.etiqueta
        var numero = self.tarjeta.numero
        numero.removeRange(tarjeta.numero.startIndex...tarjeta.numero.endIndex.advancedBy(-5))
        self.textFieldNumero.text = "************" + numero
    }
    
    @IBAction func editarTarjeta(){
        if let user = Usuario.getCurrent(){
            
            let loadingView = self.storyboard?.instantiateViewControllerWithIdentifier("LoadingView") as! LoadingView
            self.presentViewController(loadingView, animated: false, completion: nil)
            
            let id = user.id
            if id == ""{
                self.email = user.email
                self.pass = user.password
                let params = ["Email":user.email,"Password":user.password]
                let soap = SOAP(action: .Login, params: params, delegate: self)
                soap.callRequest()
            }else{
                let etiqueta = self.textFieldAlias.text!
                let numero = tarjeta.numero
                
                let params = ["IdUsuario":id,"Etiqueta":etiqueta,"Tarjeta":numero]
                let soap = SOAP(action: .EditarTarjeta, params: params, delegate: self)
                soap.callRequest()
            }
            
        }
    }
    
    @IBAction func regresar(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func cerrarTeclado(){
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // MARK: - Manage Keyboard
    func adjustInsetForKeyboardShow(show: Bool, notification: NSNotification) {
        self.keyBoardIsVisible = show
        guard let value = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.CGRectValue()
        let adjustmentHeight = (CGRectGetHeight(keyboardFrame) + 20) * (show ? 1 : -1)
        self.scrollView.contentInset.bottom += adjustmentHeight
        self.scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if !self.keyBoardIsVisible{
            self.adjustInsetForKeyboardShow(true, notification: notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.adjustInsetForKeyboardShow(false, notification: notification)
    }
    
    // MARK: - deinit
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - SOAPDelegate
    
    func didRecieveXML(XML: XMLIndexer,action: Services) {
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
                        let etiqueta = self.textFieldAlias.text!
                        let numero = self.tarjeta.numero
                        
                        let params = ["IdUsuario":id,"Etiqueta":etiqueta,"Tarjeta":numero]
                        let soap = SOAP(action: .EditarTarjeta, params: params, delegate: self)
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
                if let data = try XML.byKey("soap:Envelope").byKey("soap:Body").byKey("editCardResponse").byKey("editCardResult").byKey("NewDataSet").byKey("Table").all.first{
                    if let res = data["Res"].element?.text{
                        if res == "SUCCESS"{
                            dispatch_async(dispatch_get_main_queue()) {
                                let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MisTarjetasNC")
                                self.slideMenuController()!.changeMainViewController(controller!, close: true)
                            }
                        }else{
                            dispatch_async(dispatch_get_main_queue()) {
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
    
    func didClick(){
        
    }
    
    func didTouchSecondButton(){
        self.editarTarjeta()
    }

}
