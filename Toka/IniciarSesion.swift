//
//  IniciarSesion.swift
//  TOKA
//
//  Created by Martin Viruete Gonzalez on 28/06/16.
//
//

import UIKit
import Alamofire

class IniciarSesion: UIViewController,SOAPDelegate,Popup2Delegate,UITextFieldDelegate {
    
    @IBOutlet weak var textFieldUsuario: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var keyBoardIsVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(self.keyboardWillShow(_:)),name: UIKeyboardWillShowNotification,object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(self.keyboardWillHide(_:)),name: UIKeyboardWillHideNotification,object: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - @IBAction Methods
    
    @IBAction func iniciarSesion(){
        let loadingView = self.storyboard?.instantiateViewControllerWithIdentifier("LoadingView") as! LoadingView
        self.presentViewController(loadingView, animated: false, completion: nil)
        
        let params = ["Email":self.textFieldUsuario.text!,"Password":self.textFieldPassword.text!]
        let soap = SOAP(action: .Login, params: params, delegate: self)
        soap.callRequest()
        
        /*let soap = SOAP(action: .Usuarios, params: ["id":"232301"], delegate: self)
        soap.callRequest()*/
    }
    
    @IBAction func recuperarPassword(){
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("RecuperarPassword") as! RecuperarPassword
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func regresar(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func cerrarTeclado(){
        self.view.endEditing(true)
    }
    
    // MARK: - SOAPDelegate
    
    func didRecieveXML(XML: XMLIndexer,action: Services) {
        dispatch_async(dispatch_get_main_queue(), {
            self.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
        })
        
        
        do {
            if let data = try XML.byKey("soap:Envelope").byKey("soap:Body").byKey("getUserResponse").byKey("getUserResult").byKey("NewDataSet").byKey("Table").all.first{
                let clave = try data.byKey("clave").element?.text ?? ""
                let nombre = try data.byKey("nombre").element?.text ?? ""
                let apellidos = try data.byKey("apellidos").element?.text ?? ""
                let celular = data["celular"].element?.text ?? ""
                let id = try data.byKey("id").element?.text ?? ""
                let email = self.textFieldUsuario.text!
                let pass = self.textFieldPassword.text!
                let fechaRegistroApp = data["fechaRegistroApp"].element?.text ?? ""
                let userData = ["clave":clave,"nombre":nombre,"apellidos":apellidos,"id":id,"email":email,"password":pass,"celular":celular,"fechaRegistroApp":fechaRegistroApp]
                NSUserDefaults.standardUserDefaults().setObject(userData, forKey: Utils.USER_DATA)
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: Utils.LOGGED)
                NSUserDefaults.standardUserDefaults().setValue(id, forKey: Utils.USER_ID)
                NSUserDefaults.standardUserDefaults().synchronize()
                
                let notificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
                let application = UIApplication.sharedApplication()
                application.registerUserNotificationSettings(notificationSettings)
                
                dispatch_async(dispatch_get_main_queue(), {
                    if let controller = self.storyboard?.instantiateViewControllerWithIdentifier("Slider") {
                        self.presentViewController(controller, animated: false, completion: nil)
                    }
                })
                
            }
        }catch let error as XMLIndexer.Error{
            print(error.description)
            dispatch_async(dispatch_get_main_queue(), {
                let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup") as! Popup
                popUp.mensaje = "Haz introducido un correo o un password incorrecto porfavor intenta nuevamente."
                popUp.icono = UIImage(named: "ios_icono_alerta")
                self.presentViewController(popUp, animated: false, completion: nil)
            })
        }catch {
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.textFieldUsuario{
            self.textFieldPassword.becomeFirstResponder()
        }else{
            self.view.endEditing(true)
        }
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
    
    func didClick(){
        
    }
    
    func didTouchSecondButton(){
        self.iniciarSesion()
    }
    
    // MARK: - deinit
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}
