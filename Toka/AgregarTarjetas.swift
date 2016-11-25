//
//  AgregarTarjetas.swift
//  TOKA
//
//  Created by Martin Viruete Gonzalez on 04/07/16.
//
//

import UIKit

class AgregarTarjetas: UIViewController,UITextFieldDelegate,SOAPDelegate,Popup2Delegate {
    
    @IBOutlet weak var textFieldAlias: UITextField!
    @IBOutlet weak var textFieldNumero: UITextField!
    @IBOutlet weak var textFieldMesVigencia: UITextField!
    @IBOutlet weak var textFieldAnioVigencia: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var keyBoardIsVisible = false
    var agregado = false
    var otra = false

    override func viewDidLoad() {
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
        cancelButton.action = #selector(self.siguienteMes)
        cancelButton.tintColor = UIColor.whiteColor()
        barItems.insert(cancelButton, atIndex: 1)
        
        toolBar.setItems(barItems, animated: false)
        self.textFieldNumero.inputAccessoryView = toolBar
        
        let toolBar2: UIToolbar = UIToolbar()
        toolBar2.barStyle = .Default
        toolBar2.barTintColor = UIColor(red: 39/255, green: 39/255, blue: 39/255, alpha: 1)
        toolBar2.sizeToFit()
        
        var barItems2 = [UIBarButtonItem]()
        
        let flexSpace2: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        barItems2.insert(flexSpace2, atIndex: 0)
        
        let cancelButton2 = UIBarButtonItem()
        cancelButton2.title = "Siguiente"
        cancelButton2.target = self
        cancelButton2.style = UIBarButtonItemStyle.Plain
        cancelButton2.action = #selector(siguienteAnio)
        cancelButton2.tintColor = UIColor.whiteColor()
        barItems2.insert(cancelButton2, atIndex: 1)
        
        toolBar2.setItems(barItems2, animated: false)
        self.textFieldMesVigencia.inputAccessoryView = toolBar2
        
        let toolBar3: UIToolbar = UIToolbar()
        toolBar3.barStyle = .Default
        toolBar3.barTintColor = UIColor(red: 39/255, green: 39/255, blue: 39/255, alpha: 1)
        toolBar3.sizeToFit()
        
        var barItems3 = [UIBarButtonItem]()
        
        let flexSpace3: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        barItems3.insert(flexSpace3, atIndex: 0)
        
        let cancelButton3 = UIBarButtonItem()
        cancelButton3.title = "Aceptar"
        cancelButton3.target = self
        cancelButton3.style = UIBarButtonItemStyle.Plain
        cancelButton3.action = #selector(self.aceptar)
        cancelButton3.tintColor = UIColor.whiteColor()
        barItems3.insert(cancelButton3, atIndex: 1)
        
        toolBar3.setItems(barItems3, animated: false)
        self.textFieldAnioVigencia.inputAccessoryView = toolBar3
    }
    
    @IBAction func agregarTarjeta(){
        
        let loadingView = self.storyboard?.instantiateViewControllerWithIdentifier("LoadingView") as! LoadingView
        self.presentViewController(loadingView, animated: false, completion: nil)
        
        if let userData = NSUserDefaults.standardUserDefaults().valueForKey(Utils.USER_DATA) as? [String:String]{
            let email = userData["email"] ?? ""
            let etiqueta = self.textFieldAlias.text!
            let numero = self.textFieldNumero.text!
            let mes = (self.textFieldMesVigencia.text! == "") ? "0" : String(Int(self.textFieldMesVigencia.text!)!)
            let anio = self.textFieldAnioVigencia.text!
            
            let params = ["Email":email,"Mes":mes,"Anio":anio,"Etiqueta":etiqueta,"Tarjeta":numero]
            let soap = SOAP(action: .AgregarTarjeta, params: params, delegate: self)
            soap.callRequest()
        }
    }
    
    func siguienteMes(){
        self.textFieldMesVigencia.becomeFirstResponder()
    }
    
    func siguienteAnio(){
        self.textFieldAnioVigencia.becomeFirstResponder()
    }
    
    func aceptar(){
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.textFieldAlias{
            self.textFieldNumero.becomeFirstResponder()
        }
        return false
    }
    
    @IBAction func regresar(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func cerrarTeclado(){
        self.view.endEditing(true)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == self.textFieldMesVigencia{
            return self.textFieldMesVigencia.text!.characters.count < 2 || string == ""
        }
        else if textField == self.textFieldAnioVigencia{
            return self.textFieldAnioVigencia.text!.characters.count < 2 || string == ""
        }
        else if textField == self.textFieldNumero{
            return self.textFieldNumero.text!.characters.count < 16 || string == ""
        }
        else{
            return true
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
    
    // MARK: - deinit
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - SOAPDelegate
    
    func didRecieveXML(XML: XMLIndexer,action: Services) {
        dispatch_async(dispatch_get_main_queue(), {
            self.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
        })
        do {
            if let data = try XML.byKey("soap:Envelope").byKey("soap:Body").byKey("addCardResponse").byKey("addCardResult").byKey("Data").all.first{
                if let res = data["Result"].element?.text{
                    print (res)
                    
                    switch res {
                    
                    case "SUCCESS":
                        self.agregado = true
                        self.otra = true
                        dispatch_async(dispatch_get_main_queue()) {
                            let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup2") as! Popup2
                            popUp.mensaje = "¡Tu tarjeta ha sido añadida con éxito!"
                            popUp.buttonIcon2 = UIImage(named: "ios_btn_verdetalles")
                            popUp.buttonIcon = UIImage(named: "ios_btn_anadir")
                            popUp.icono = UIImage(named: "ios_icono_exitoso")
                            popUp.delegate = self
                            self.presentViewController(popUp, animated: false, completion: nil)
                        }
                        break

                    case "-1", "0","ERROR VIGENCIA":
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup2") as! Popup2
                            popUp.mensaje = "Los datos son incorrectos verifica los 16 dígitos de la tarjeta y la fecha de vigencia."
                            popUp.buttonIcon2 = UIImage(named: "ios_btn_reintentar")
                            popUp.buttonIcon = UIImage(named: "ios_btn_cancelar")
                            popUp.icono = UIImage(named: "ios_icono_alerta")
                            popUp.delegate = self
                            self.presentViewController(popUp, animated: false, completion: nil)
                        }

                        
                    break
                        
                    case "-2":
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup2") as! Popup2
                            popUp.mensaje = "No es posible agregar la tarjeta."
                            popUp.buttonIcon2 = UIImage(named: "ios_btn_reintentar")
                            popUp.buttonIcon = UIImage(named: "ios_btn_cancelar")
                            popUp.icono = UIImage(named: "ios_icono_alerta")
                            popUp.delegate = self
                            self.presentViewController(popUp, animated: false, completion: nil)
                        }
                        break
                        
                    case "ERROR NO GUARDO":
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup2") as! Popup2
                            popUp.mensaje = "No es posible agregar la tarjeta, intente más tarde."
                            popUp.buttonIcon2 = UIImage(named: "ios_btn_reintentar")
                            popUp.buttonIcon = UIImage(named: "ios_btn_cancelar")
                            popUp.icono = UIImage(named: "ios_icono_alerta")
                            popUp.delegate = self
                            self.presentViewController(popUp, animated: false, completion: nil)
                        }
                        
                        break
                        
                    case "ERROR EXISTE":
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup2") as! Popup2
                            popUp.mensaje = "La tarjeta ya se encuentra registrada."
                            popUp.buttonIcon2 = UIImage(named: "ios_btn_reintentar")
                            popUp.buttonIcon = UIImage(named: "ios_btn_cancelar")
                            popUp.icono = UIImage(named: "ios_icono_alerta")
                            popUp.delegate = self
                            self.presentViewController(popUp, animated: false, completion: nil)
                        }
                        break
                        
                    case "ERROR EXISTE VALIDADA":
                        dispatch_async(dispatch_get_main_queue()) {
                            let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup2") as! Popup2
                            popUp.mensaje = "No es posible agregar la tarjeta, por favor comunícate al 01 (55) 4125 0320 Código:510"
                            popUp.buttonIcon2 = UIImage(named: "ios_btn_reintentar")
                            popUp.buttonIcon = UIImage(named: "ios_btn_cancelar")
                            popUp.icono = UIImage(named: "ios_icono_alerta")
                            popUp.delegate = self
                            self.presentViewController(popUp, animated: false, completion: nil)
                        }

                        break
                        
                    case "ERROR NO SE ENCONTRO ID CLIENTE", "ERROR NO PERTENECE A LA EMPRESA":
                        dispatch_async(dispatch_get_main_queue()) {
                            let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup2") as! Popup2
                            popUp.mensaje = "No es posible agregar la tarjeta, por favor comunícate al 01 (55) 4125 0320 Código:530"
                            popUp.buttonIcon2 = UIImage(named: "ios_btn_reintentar")
                            popUp.buttonIcon = UIImage(named: "ios_btn_cancelar")
                            popUp.icono = UIImage(named: "ios_icono_alerta")
                            popUp.delegate = self
                            self.presentViewController(popUp, animated: false, completion: nil)
                        }
                        
                        break
                        
                    case "ERROR TARJETA ANIO":
                        dispatch_async(dispatch_get_main_queue()) {
                            let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup2") as! Popup2
                            popUp.mensaje = "No es posible agregar la tarjeta, por favor comunícate al 01 (55) 4125 0320 Código:520"
                            popUp.buttonIcon2 = UIImage(named: "ios_btn_reintentar")
                            popUp.buttonIcon = UIImage(named: "ios_btn_cancelar")
                            popUp.icono = UIImage(named: "ios_icono_alerta")
                            popUp.delegate = self
                            self.presentViewController(popUp, animated: false, completion: nil)
                        }
                        
                        break
                   
                    case "BLOQUEO":
                        dispatch_async(dispatch_get_main_queue()) {
                            let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup2") as! Popup2
                            popUp.mensaje = "No es posible agregar la tarjeta, por favor comunícate al 01 (55) 4125 0320 Código:201"
                            popUp.buttonIcon2 = UIImage(named: "ios_btn_reintentar")
                            popUp.buttonIcon = UIImage(named: "ios_btn_cancelar")
                            popUp.icono = UIImage(named: "ios_icono_alerta")
                            popUp.delegate = self
                            self.presentViewController(popUp, animated: false, completion: nil)
                        }
                        
                        break
                        
                    case "ERROR TOKENS":
                        dispatch_async(dispatch_get_main_queue()) {
                            let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup2") as! Popup2
                            popUp.mensaje = "No es posible agregar la tarjeta, por favor comunícate al 01 (55) 4125 0320 Código:601"
                            popUp.buttonIcon2 = UIImage(named: "ios_btn_reintentar")
                            popUp.buttonIcon = UIImage(named: "ios_btn_cancelar")
                            popUp.icono = UIImage(named: "ios_icono_alerta")
                            popUp.delegate = self
                            self.presentViewController(popUp, animated: false, completion: nil)
                        }
                        
                        break
                        
                    case "ERROR LIMITE":
                        dispatch_async(dispatch_get_main_queue()) {
                            let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup2") as! Popup2
                            popUp.mensaje = "Haz alcanzado el límite de registros de tarjetas de esta cuenta, por favor comunícate al 01 (55) 4125 0320 Código:406"
                            popUp.buttonIcon2 = UIImage(named: "ios_btn_reintentar")
                            popUp.buttonIcon = UIImage(named: "ios_btn_cancelar")
                            popUp.icono = UIImage(named: "ios_icono_alerta")
                            popUp.delegate = self
                            self.presentViewController(popUp, animated: false, completion: nil)
                        }
                        
                        break
                        
                    
                        
                    default:
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup2") as! Popup2
                            popUp.mensaje = "Por favor, verifica que los datos de tu tarjeta sean correctos."
                            popUp.buttonIcon2 = UIImage(named: "ios_btn_reintentar")
                            popUp.buttonIcon = UIImage(named: "ios_btn_cancelar")
                            popUp.icono = UIImage(named: "ios_icono_alerta")
                            popUp.delegate = self
                            self.presentViewController(popUp, animated: false, completion: nil)

                        }
                        break
                    }
                    
                    
                    /*
                    if res == "SUCCESS"{
                        self.agregado = true
                        self.otra = true
                        dispatch_async(dispatch_get_main_queue()) {
                            let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup2") as! Popup2
                            popUp.mensaje = "¡Tu tarjeta ha sido añadida con éxito!"
                            popUp.buttonIcon2 = UIImage(named: "ios_btn_verdetalles")
                            popUp.buttonIcon = UIImage(named: "ios_btn_anadir")
                            popUp.icono = UIImage(named: "ios_icono_exitoso")
                            popUp.delegate = self
                            self.presentViewController(popUp, animated: false, completion: nil)
                        }
                    }
                    
                    else{
                        dispatch_async(dispatch_get_main_queue()) {
                            let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup2") as! Popup2
                            popUp.mensaje = "Por favor, verifica que los datos de tu tarjeta sean correctos."
                            popUp.buttonIcon2 = UIImage(named: "ios_btn_reintentar")
                            popUp.buttonIcon = UIImage(named: "ios_btn_cancelar")
                            popUp.icono = UIImage(named: "ios_icono_alerta")
                            popUp.delegate = self
                            self.presentViewController(popUp, animated: false, completion: nil)
                        }
                    }
                    
                    */
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
            print("error inisperado")
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
    
    func didClick() {
        if self.otra{
            self.textFieldAlias.text = ""
            self.textFieldNumero.text = ""
            self.textFieldMesVigencia.text = ""
            self.textFieldAnioVigencia.text = ""
        }else{
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func didTouchSecondButton() {
        if self.agregado{
            NSUserDefaults.standardUserDefaults().setBool(true,forKey: "VER_ULTIMO")
            NSUserDefaults.standardUserDefaults().synchronize()
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MisTarjetasNC")
            self.slideMenuController()!.changeMainViewController(controller!, close: true)
        }else{
            self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }

}
