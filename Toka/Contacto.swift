//
//  Contacto.swift
//  TOKA
//
//  Created by Martin Viruete Gonzalez on 07/07/16.
//
//

import UIKit

class Contacto: UIViewController,SOAPDelegate,PopupDelegate,UITextFieldDelegate,UITextViewDelegate {
    
    @IBOutlet weak var textFiedlNombre: UITextField!
    @IBOutlet weak var textFiedlTelefono: UITextField!
    @IBOutlet weak var textFiedlCorreo: UITextField!
    @IBOutlet weak var textFiedlMensaje: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var keyBoardIsVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(self.keyboardWillShow(_:)),name: UIKeyboardWillShowNotification,object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(self.keyboardWillHide(_:)),name: UIKeyboardWillHideNotification,object: nil)
        // Do any additional setup after loading the view.
        
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
        self.textFiedlTelefono.inputAccessoryView = toolBar
        
        let toolBar2: UIToolbar = UIToolbar()
        toolBar2.barStyle = .Default
        toolBar2.barTintColor = UIColor(red: 39/255, green: 39/255, blue: 39/255, alpha: 1)
        toolBar2.sizeToFit()
        
        var barItems2 = [UIBarButtonItem]()
        
        let flexSpace2: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        barItems2.insert(flexSpace2, atIndex: 0)
        
        let cancelButton2 = UIBarButtonItem()
        cancelButton2.title = "Aceptar"
        cancelButton2.target = self
        cancelButton2.style = UIBarButtonItemStyle.Plain
        cancelButton2.action = #selector(self.terminar)
        cancelButton2.tintColor = UIColor.whiteColor()
        barItems2.insert(cancelButton2, atIndex: 1)
        
        toolBar2.setItems(barItems2, animated: false)
        self.textFiedlMensaje.inputAccessoryView = toolBar2
    }
    
    func siguiente(){
        self.textFiedlCorreo.becomeFirstResponder()
    }
    
    func terminar(){
        self.view.endEditing(true)
    }
    
    
    // MARK: - @IBAction Methods
    @IBAction func llamar(sender: UIButton){
        var phone = ""
        switch sender.tag {
            case 0: phone = "018003005050"
            case 1: phone = "015541250320"
            case 2: phone = "013313686174"
            default: phone = ""
        }
        let url = NSURL(string: "tel:\(phone)")!
        if UIApplication.sharedApplication().canOpenURL(url){
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func enviar(){
    
        if self.textFiedlNombre.text!.isEmpty || self.textFiedlTelefono.text!.isEmpty || self.textFiedlCorreo.text!.isEmpty || !isValidEmail(self.textFiedlCorreo.text!) || self.textFiedlMensaje.text == "Mensaje."{
            let popup = self.storyboard?.instantiateViewControllerWithIdentifier("Popup") as! Popup
            popup.icono = UIImage(named: "ios_icono_alerta")
            popup.mensaje = "-Cerciórate de haber llenado nombre,correo,teléfono y mensaje \n -Por favor, introduce un correo válido"
            self.presentViewController(popup, animated: false, completion: nil)
            return
        }
        
        let loadingView = self.storyboard?.instantiateViewControllerWithIdentifier("LoadingView") as! LoadingView
        self.presentViewController(loadingView, animated: false, completion: nil)
        let params = ["Correo":self.textFiedlCorreo.text!,"Telefono":self.textFiedlTelefono.text!,"Mensaje":self.textFiedlMensaje.text!,"Nombre":self.textFiedlNombre.text!]
        let soap = SOAP(action: .EnviarMensaje, params: params, delegate: self)
        soap.callRequest()
    }
    
    @IBAction func cerrarTeclado(){
        self.view.endEditing(true)
    }
    
    func didRecieveXML(XML: XMLIndexer,action: Services) {
        dispatch_async(dispatch_get_main_queue(), {
            self.dismissViewControllerAnimated(false, completion: nil)
        })
        do {
            if let data = try XML.byKey("soap:Envelope").byKey("soap:Body").byKey("sendMailFormResponse").byKey("sendMailFormResult").byKey("NewDataSet").byKey("Table").all.first{
                if let res = data["Res"].element?.text{
                    if res == "ENVIADO"{
                        dispatch_async(dispatch_get_main_queue(), {
                            let popup = self.storyboard?.instantiateViewControllerWithIdentifier("Popup") as! Popup
                            popup.icono = UIImage(named: "ios_icono_exitoso")
                            popup.mensaje = "Mensaje enviado con éxito"
                            popup.delegate = self
                            self.presentViewController(popup, animated: false, completion: nil)
                        })
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        let popup = self.storyboard?.instantiateViewControllerWithIdentifier("Popup") as! Popup
                        popup.icono = UIImage(named: "ios_icono_alerta")
                        popup.mensaje = "Problemas a el enviar tu mensaje"
                        self.presentViewController(popup, animated: false, completion: nil)
                    })
                }
            }
        }catch let error as XMLIndexer.Error{
            print(error.description)
            dispatch_async(dispatch_get_main_queue(), {
                let popup = self.storyboard?.instantiateViewControllerWithIdentifier("Popup") as! Popup
                popup.icono = UIImage(named: "ios_icono_alerta")
                popup.mensaje = "Problemas a el enviar tu mensaje"
                self.presentViewController(popup, animated: false, completion: nil)
            })
        }catch {
            print("error inisperado")
        }
    }
    
    func didFailReceivingXML(error: String) {
        dispatch_async(dispatch_get_main_queue(), {
            let popup = self.storyboard?.instantiateViewControllerWithIdentifier("Popup") as! Popup
            popup.icono = UIImage(named: "ios_icono_alerta")
            popup.mensaje = "Problemas a el enviar tu mensaje"
            self.presentViewController(popup, animated: false, completion: nil)
        })
    }
    
    func didTouchButton() {
        self.view.endEditing(true)
        self.textFiedlCorreo.text = ""
        self.textFiedlTelefono.text = ""
        self.textFiedlNombre.text = ""
        self.textFiedlMensaje.textColor = UIColor(red: 41/255, green: 138/255, blue: 185/255, alpha: 1.0)
        self.textFiedlMensaje.text = "Mensaje"
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "Mensaje"{
            textView.textColor = UIColor.whiteColor()
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty{
            textView.textColor = UIColor(red: 41/255, green: 138/255, blue: 185/255, alpha: 1.0)
            textView.text = "Mensaje"
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.textFiedlNombre{
            self.textFiedlTelefono.becomeFirstResponder()
        }
        else if textField == self.textFiedlCorreo{
            self.textFiedlMensaje.becomeFirstResponder()
        }
        
        return false
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
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
