//
//  RecuperarPassword.swift
//  TOKA
//
//  Created by Martin Viruete Gonzalez on 04/07/16.
//
//

import UIKit

class RecuperarPassword: UIViewController,SOAPDelegate,PopupDelegate,Popup2Delegate,UITextFieldDelegate {
    
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(self.keyboardWillShow(_:)),name: UIKeyboardWillShowNotification,object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(self.keyboardWillHide(_:)),name: UIKeyboardWillHideNotification,object: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - @IBAction Methods

    @IBAction func recuperarPassword(){
        self.view.endEditing(true)
        let loadingView = self.storyboard?.instantiateViewControllerWithIdentifier("LoadingView") as! LoadingView
        self.presentViewController(loadingView, animated: false, completion: nil)
        
        let params = ["Email":self.textFieldEmail.text!]
        let soap = SOAP(action: .RecuperarPassword, params: params, delegate: self)
        soap.callRequest()
    }
    
    @IBAction func regresar(){
        if let nav = self.navigationController{
            nav.popViewControllerAnimated(true)
        }else{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func cerrarTeclado(){
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // MARK: - SOAPDelegate
    
    func didRecieveXML(XML: XMLIndexer,action: Services) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
        })
        
        do {
            if let data = try XML.byKey("soap:Envelope").byKey("soap:Body").byKey("sendMailPasswordResponse").byKey("sendMailPasswordResult").byKey("NewDataSet").byKey("Table").all.first{
                let enviado = try data.byKey("Res").element?.text == "ENVIADO"
                if enviado{
                    dispatch_async(dispatch_get_main_queue(), {
                        let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup") as! Popup
                        popUp.mensaje = "Hemos enviado el password a tu correo. Porfavor, revisa tu bandeja de entrada e inicia sesión."
                        popUp.icono = UIImage(named: "ios_icono_exitoso")
                        popUp.buttonIcon = UIImage(named: "ios_btn_iniciarsecion")
                        popUp.delegate = self
                        self.presentViewController(popUp, animated: false, completion: nil)
                    })
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup") as! Popup
                        popUp.mensaje = "No hemos encontrado tu correo, cerciórate de haber introducido tu correo correcto. ¿No estás registrado? Te invitamos."
                        popUp.icono = UIImage(named: "ios_icono_alerta")
                        self.presentViewController(popUp, animated: false, completion: nil)
                    })
                }
            }
        }catch _ as XMLIndexer.Error{
            dispatch_async(dispatch_get_main_queue(), {
                let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup") as! Popup
                popUp.mensaje = "No hemos encontrado tu correo, cerciórate de haber introducido tu correo correcto. ¿No estás registrado? Te invitamos."
                popUp.icono = UIImage(named: "ios_icono_alerta")
                self.presentViewController(popUp, animated: false, completion: nil)
            })
        }catch {
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
        guard let value = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.CGRectValue()
        let adjustmentHeight = (CGRectGetHeight(keyboardFrame) + 20) * (show ? 1 : -1)
        self.scrollView.contentInset.bottom += adjustmentHeight
        self.scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.adjustInsetForKeyboardShow(true, notification: notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.adjustInsetForKeyboardShow(false, notification: notification)
    }
    
    func didClick(){
        
    }
    
    func didTouchSecondButton(){
        self.recuperarPassword()
    }
    
    // MARK: - PopupDelegate
    
    func didTouchButton() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - deinit
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}
