//
//  Configuracion.swift
//  TOKA
//
//  Created by Martin Viruete Gonzalez on 06/07/16.
//
//

import UIKit

import UIKit

class Configuracion: UIViewController,SOAPDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,VerificacionPasswordDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var textFieldNombre: UITextField!
    @IBOutlet weak var textFieldApellido: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldCelular: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldConfirmarPassword: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imagenPerfil: UIImageView!
    @IBOutlet weak var fondoPass: UIImageView!
    @IBOutlet weak var fondoPass2: UIImageView!
    @IBOutlet weak var buttonVerificar: UIButton!
    
    var keyBoardIsVisible = false
    var imagePerfil: UIImage? = nil
    var verificado = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(self.keyboardWillShow(_:)),name: UIKeyboardWillShowNotification,object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(self.keyboardWillHide(_:)),name: UIKeyboardWillHideNotification,object: nil)
        
        if let userData = NSUserDefaults.standardUserDefaults().valueForKey(Utils.USER_DATA) as? [String:String]{
            let nombre = userData["nombre"] ?? ""
            let apellidos = userData["apellidos"] ?? ""
            let correo = userData["email"] ?? ""
            let password = userData["password"] ?? ""
            let celular = userData["celular"] ?? ""
            self.textFieldNombre.text = nombre
            self.textFieldApellido.text = apellidos
            self.textFieldEmail.text = correo
            self.textFieldPassword.text = password
            self.textFieldConfirmarPassword.text = password
            self.textFieldCelular.text = celular
        }
        
        if let imageData = NSUserDefaults.standardUserDefaults().valueForKey(Utils.USER_IMAGE) as? [String:NSData]{
            if imagePerfil == nil{
                if let userData = NSUserDefaults.standardUserDefaults().valueForKey(Utils.USER_DATA) as? [String:String]{
                    let id = userData["email"] ?? ""
                    if let img = imageData[id]{
                        self.imagenPerfil.image = UIImage(data: img)
                    }else{
                        self.imagenPerfil.image = UIImage(named: "android_default")
                    }
                }else{
                    self.imagenPerfil.image = UIImage(named: "android_default")
                }
            }else{
                self.imagenPerfil.image = self.imagePerfil
            }
        }else{
            if imagePerfil ==  nil{
                self.imagenPerfil.image = UIImage(named: "android_default")
            }else{
                self.imagenPerfil.image = self.imagePerfil
            }
        }
        self.imagenPerfil.layer.cornerRadius = self.imagenPerfil.frame.size.height / 2
        
        let toolBar: UIToolbar = UIToolbar()
        toolBar.barStyle = .Default
        toolBar.barTintColor = UIColor(red: 39/255, green: 39/255, blue: 39/255, alpha: 1)
        toolBar.sizeToFit()
        
        var barItems = [UIBarButtonItem]()
        
        let flexSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        barItems.insert(flexSpace, atIndex: 0)
        
        let cancelButton = UIBarButtonItem()
        cancelButton.title = "Aceptar"
        cancelButton.target = self
        cancelButton.style = UIBarButtonItemStyle.Plain
        cancelButton.action = #selector(self.siguiente)
        cancelButton.tintColor = UIColor.whiteColor()
        barItems.insert(cancelButton, atIndex: 1)
        
        toolBar.setItems(barItems, animated: false)
        self.textFieldCelular.inputAccessoryView = toolBar
    }
    
    func siguiente(){
        if verificado{
            self.textFieldPassword.becomeFirstResponder()
        }else{
            self.view.endEditing(true)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.textFieldNombre{
            self.textFieldApellido.becomeFirstResponder()
        }else if textField == textFieldApellido{
            self.textFieldCelular.becomeFirstResponder()
        }else if textField == textFieldPassword{
            self.textFieldConfirmarPassword.becomeFirstResponder()
        }else if textField == textFieldConfirmarPassword{
            self.view.endEditing(true)
        }
        return false
    }
    
    override func viewDidLayoutSubviews() {
        if let imageData = NSUserDefaults.standardUserDefaults().valueForKey(Utils.USER_IMAGE) as? [String:NSData]{
            if imagePerfil == nil{
                if let userData = NSUserDefaults.standardUserDefaults().valueForKey(Utils.USER_DATA) as? [String:String]{
                    let id = userData["email"] ?? ""
                    if let img = imageData[id]{
                        self.imagenPerfil.image = UIImage(data: img)
                    }else{
                        self.imagenPerfil.image = UIImage(named: "android_default")
                    }
                }else{
                    self.imagenPerfil.image = UIImage(named: "android_default")
                }
            }else{
                self.imagenPerfil.image = self.imagePerfil
            }
        }else{
            if imagePerfil ==  nil{
                self.imagenPerfil.image = UIImage(named: "android_default")
            }else{
                self.imagenPerfil.image = self.imagePerfil
            }
        }
        self.imagenPerfil.layer.cornerRadius = self.imagenPerfil.frame.size.height / 2
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - @IBAction Methods
    
    func guardarCambios(){
        
        if self.textFieldNombre.text!.isEmpty || self.textFieldCelular.text!.isEmpty || self.textFieldPassword.text!.isEmpty{
            let popup = self.storyboard?.instantiateViewControllerWithIdentifier("Popup") as! Popup
            popup.icono = UIImage(named: "ios_icono_alerta")
            popup.mensaje = "Cerciórate de haber llenado todos los campos."
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
        
        let loadingView = self.storyboard?.instantiateViewControllerWithIdentifier("LoadingView") as! LoadingView
        self.presentViewController(loadingView, animated: false, completion: nil)
        
        let params = ["Nombre":self.textFieldNombre.text!,"Apellidos":self.textFieldApellido.text!,"Email":self.textFieldEmail.text!,"Password":self.textFieldPassword.text!,"Celular":self.textFieldCelular.text!]
        let soap = SOAP(action: .EditarPerfil, params: params, delegate: self)
        soap.callRequest()
    }
    
    @IBAction func guardar(){
        self.guardarCambios()
    }
    
    @IBAction func cancelar(){
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MisTarjetasNC")
        self.slideMenuController()!.changeMainViewController(controller!, close: true)
    }
    
    @IBAction func verificarPassword(){
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("VerificacionPassword") as! VerificacionPassword
        controller.delegate = self
        self.presentViewController(controller, animated: false, completion: nil)
    }
    
    @IBAction func cerrarSesions(){
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: Utils.USER_DATA)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: Utils.LOGGED)
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: Utils.USER_ID)
        NSUserDefaults.standardUserDefaults().synchronize()
        if let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MainNC") {
            self.presentViewController(controller, animated: false, completion: nil)
        }
    }
    
    @IBAction func openPhotoLibraryButton(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.imagePerfil = image
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBAction func cerrarTeclado(){
        self.view.endEditing(true)
    }
    
    func didFinishWithExit(){
        self.textFieldPassword.enabled = true
        self.textFieldPassword.textColor = UIColor.whiteColor()
        self.textFieldPassword.text = ""
        
        self.textFieldConfirmarPassword.enabled = true
        self.textFieldConfirmarPassword.textColor = UIColor.whiteColor()
        self.textFieldConfirmarPassword.text = ""
        
        self.fondoPass.image = UIImage(named: "ios_fondo_azul_claro")
        self.fondoPass2.image = UIImage(named: "ios_fondo_azul_claro")
        
        self.buttonVerificar.enabled = false
        self.buttonVerificar.hidden = true
        
        self.verificado = true
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
    
    // MARK: - SOAPDelegate
    
    func didRecieveXML(XML: XMLIndexer,action: Services) {
        dispatch_async(dispatch_get_main_queue(), {
            self.dismissViewControllerAnimated(false, completion: nil)
        })
        do {
            if let data = try XML.byKey("soap:Envelope").byKey("soap:Body").byKey("editUserResponse").byKey("editUserResult").byKey("NewDataSet").byKey("Table").all.first{
                let enviado = try data.byKey("Res").element?.text == "OK"
                if enviado{
                    dispatch_async(dispatch_get_main_queue(), {
                        var id = ""
                        if self.imagePerfil != nil{
                            if let userData = NSUserDefaults.standardUserDefaults().valueForKey(Utils.USER_DATA) as? [String:String]{
                                id = userData["id"] ?? ""
                                let user = userData["email"] ?? ""
                                if let imageData = NSUserDefaults.standardUserDefaults().valueForKey(Utils.USER_IMAGE) as? [String:NSData]{
                                    var valuesToSave = imageData
                                    valuesToSave[user] = UIImagePNGRepresentation(self.imagePerfil!)!
                                    NSUserDefaults.standardUserDefaults().setValue(valuesToSave, forKey: Utils.USER_IMAGE)
                                }else{
                                    let data = UIImagePNGRepresentation(self.imagePerfil!)!
                                    NSUserDefaults.standardUserDefaults().setValue([user:data], forKey: Utils.USER_IMAGE)
                                }
                            }
                        }
                        let clave = self.textFieldPassword.text!
                        let nombre = self.textFieldNombre.text!
                        let apellidos = self.textFieldApellido.text!
                        let email = self.textFieldEmail.text!
                        let celular = self.textFieldCelular.text!
                        let userData = ["clave":clave,"nombre":nombre,"apellidos":apellidos,"email":email,"id":id,"password":clave,"celular":celular]
                        NSUserDefaults.standardUserDefaults().setObject(userData, forKey: Utils.USER_DATA)
                        
                        NSUserDefaults.standardUserDefaults().synchronize()
                        dispatch_async(dispatch_get_main_queue(), {
                            self.cancelar()
                        })
                    })
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup") as! Popup
                        popUp.mensaje = "Hubo problemas a el editar tu perfil intentalo mas tarde."
                        popUp.icono = UIImage(named: "ios_icono_alerta")
                        self.presentViewController(popUp, animated: false, completion: nil)
                    })
                }
                
            }
        }catch {
            dispatch_async(dispatch_get_main_queue(), {
                let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup") as! Popup
                popUp.mensaje = "Hubo problemas a el editar tu perfil intentalo mas tarde."
                popUp.icono = UIImage(named: "ios_icono_alerta")
                self.presentViewController(popUp, animated: false, completion: nil)
            })
        }
    }
    
    func didFailReceivingXML(error: String) {
        dispatch_async(dispatch_get_main_queue(), {
            let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup") as! Popup
            popUp.mensaje = "Problemas con al conectarse con el servidor. Porfavor, verfica tu conexión a internet o intentalo más tarde."
            popUp.icono = UIImage(named: "ios_icono_conexion")
            self.presentViewController(popUp, animated: false, completion: nil)
        })
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
    
}