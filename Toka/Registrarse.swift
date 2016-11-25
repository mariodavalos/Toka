//
//  Registrarse.swift
//  TOKA
//
//  Created by Martin Viruete Gonzalez on 04/07/16.
//
//

import UIKit

class Registrarse: UIViewController,SOAPDelegate,UITextFieldDelegate,Popup2Delegate {

    @IBOutlet weak var textFieldNombre: UITextField!
    @IBOutlet weak var textFieldApellido: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldConfirmarEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldConfirmarPassword: UITextField!
    @IBOutlet weak var textFieldCelular: UITextField!
    @IBOutlet weak var acepto: UISwitch!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnRegistrarse: UIButton!
    
    
    
    
    var keyBoardIsVisible = false
    
    override func viewDidLoad() {
        
        btnRegistrarse.layer.cornerRadius = 5
        
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(self.keyboardWillShow(_:)),name: UIKeyboardWillShowNotification,object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(self.keyboardWillHide(_:)),name: UIKeyboardWillHideNotification,object: nil)
        
        
        let toolBar: UIToolbar = UIToolbar()
        toolBar.barStyle = .Default
        toolBar.barTintColor = UIColor(red: 39/255, green: 39/255, blue: 39/255, alpha: 1)
        toolBar.sizeToFit()
        
        var barItems = [UIBarButtonItem]()
        
        let flexSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        barItems.insert(flexSpace, atIndex: 0)
        
        let cancelButton = UIBarButtonItem()
        cancelButton.title = "Siguiente"
        cancelButton.target = self
        cancelButton.style = UIBarButtonItemStyle.Plain
        cancelButton.action = #selector(self.siguiente)
        cancelButton.tintColor = UIColor.whiteColor()
        barItems.insert(cancelButton, atIndex: 1)
        
        toolBar.setItems(barItems, animated: false)
        self.textFieldCelular.inputAccessoryView = toolBar
    }
    
    func siguiente(){
        self.textFieldPassword.becomeFirstResponder()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - @IBAction Methods
    
    @IBAction func registrarse(){
        
        if self.textFieldNombre.text!.isEmpty || self.textFieldCelular.text!.isEmpty || self.textFieldEmail.text!.isEmpty || !isValidEmail(self.textFieldEmail.text!) || self.textFieldPassword.text!.isEmpty{
            let popup = self.storyboard?.instantiateViewControllerWithIdentifier("Popup") as! Popup
            popup.icono = UIImage(named: "ios_icono_alerta")
            popup.mensaje = "-Cerciórate de haber llenado tu nombre,correo,password y celular \n -Por favor, introduce un correo válido"
            self.presentViewController(popup, animated: false, completion: nil)
            return
        }
        
        guard self.textFieldEmail.text == self.textFieldConfirmarEmail.text else {
            let popup = self.storyboard?.instantiateViewControllerWithIdentifier("Popup") as! Popup
            popup.icono = UIImage(named: "ios_icono_alerta")
            popup.mensaje = "El usuario no coincide"
            self.presentViewController(popup, animated: false, completion: nil)
            return
        }
        
        guard self.textFieldPassword.text == self.textFieldConfirmarPassword.text else {
            let popup = self.storyboard?.instantiateViewControllerWithIdentifier("Popup") as! Popup
            popup.icono = UIImage(named: "ios_icono_alerta")
            popup.mensaje = "El password no coincide"
            self.presentViewController(popup, animated: false, completion: nil)
            return
        }
        
        if !self.acepto.on{
            let popup = self.storyboard?.instantiateViewControllerWithIdentifier("Popup") as! Popup
            popup.icono = UIImage(named: "ios_icono_alerta")
            popup.mensaje = "Por favor acepta los términos y condiciones."
            self.presentViewController(popup, animated: false, completion: nil)
            return
        }
        
        let loadingView = self.storyboard?.instantiateViewControllerWithIdentifier("LoadingView") as! LoadingView
        self.presentViewController(loadingView, animated: false, completion: nil)
        
        let params = ["Nombre":self.textFieldNombre.text!,"Apellidos":self.textFieldApellido.text!,"Origen":"AppIOS","Email":self.textFieldEmail.text!,"Password":self.textFieldPassword.text!,"Celular":self.textFieldCelular.text!]
        let soap = SOAP(action: .Registrarse, params: params, delegate: self)
        soap.callRequest()
    
    }
    
    @IBAction func regresar(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func cerrarTeclado(){
        self.view.endEditing(true)
    }
    
    @IBAction func aviso(){
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("Aviso") as! Aviso
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - SOAPDelegate
    
    func didRecieveXML(XML: XMLIndexer,action: Services) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
        })
        
        do {
            if let data = try XML.byKey("soap:Envelope").byKey("soap:Body").byKey("createUserResponse").byKey("createUserResult").byKey("NewDataSet").byKey("Table").all.first{
                let enviado = try data.byKey("Res").element?.text == "OK"
                if enviado{
                    
                    /*
                    dispatch_async(dispatch_get_main_queue(), {
                        let clave = self.textFieldPassword.text!
                        let nombre = self.textFieldNombre.text!
                        let apellidos = self.textFieldApellido.text!
                        let celular = self.textFieldCelular.text!
                        let email = self.textFieldEmail.text!
                        let userData = ["clave":clave,"nombre":nombre,"apellidos":apellidos,"email":email,"celular":celular,"password":clave]
                        NSUserDefaults.standardUserDefaults().setObject(userData, forKey: Utils.USER_DATA)
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: Utils.LOGGED)
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        let notificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
                        let application = UIApplication.sharedApplication()
                        application.registerUserNotificationSettings(notificationSettings)
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            if let controller = self.storyboard?.instantiateViewControllerWithIdentifier("Slider") {
                                self.presentViewController(controller, animated: true, completion: nil)
                            }
                        })
                    })*/
                    
                    let confVC = self.storyboard?.instantiateViewControllerWithIdentifier("ActivarCuenta") as! ActivarCuenta

                    confVC.clave = self.textFieldPassword.text!
                    confVC.clave = self.textFieldNombre.text!
                    confVC.clave = self.textFieldApellido.text!
                    confVC.clave = self.textFieldCelular.text!
                    confVC.clave = self.textFieldEmail.text!
                    self.navigationController?.pushViewController(confVC, animated: true)
                    
                    
                    
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup") as! Popup
                        popUp.mensaje = "Al parecer tuvimos problemas con el registro, inténtalo más tarde. Verifica que tu correo no esté registrado."
                        popUp.icono = UIImage(named: "ios_icono_alerta")
                        self.presentViewController(popUp, animated: false, completion: nil)
                    })
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.textFieldNombre{
            self.textFieldApellido.becomeFirstResponder()
        }else if textField == self.textFieldApellido {
            self.textFieldEmail.becomeFirstResponder()
        }else if textField == self.textFieldEmail {
            self.textFieldConfirmarEmail.becomeFirstResponder()
        }else if textField == self.textFieldConfirmarEmail {
            self.textFieldCelular.becomeFirstResponder()
        }else if textField == self.textFieldPassword {
            self.textFieldConfirmarPassword.becomeFirstResponder()
        }else if textField == self.textFieldConfirmarPassword {
            self.view.endEditing(true)
        }
        return false
    }
    
    func didClick(){
        
    }
    
    func didTouchSecondButton(){
        self.registrarse()
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    // MARK: - deinit
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}
