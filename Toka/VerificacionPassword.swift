//
//  VerificacionPassword.swift
//  TOKA
//
//  Created by Martin Viruete Gonzalez on 20/07/16.
//
//

import UIKit

public protocol VerificacionPasswordDelegate{
    func didFinishWithExit()
}

class VerificacionPassword: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var labelTitulo: UILabel!
    @IBOutlet weak var icono: UIImageView!
    @IBOutlet weak var textfieldPass: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var keyBoardIsVisible = false
    
    var delegate: VerificacionPasswordDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(self.keyboardWillShow(_:)),name: UIKeyboardWillShowNotification,object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(self.keyboardWillHide(_:)),name: UIKeyboardWillHideNotification,object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        self.container.layer.cornerRadius = 10
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func aceptar(sender: AnyObject) {
        guard let userData = NSUserDefaults.standardUserDefaults().valueForKey(Utils.USER_DATA) as? [String:String], password = userData["password"] else{
            return
        }
        if self.textfieldPass.text! == password{
            self.dismissViewControllerAnimated(false, completion: nil)
            if self.delegate != nil { self.delegate!.didFinishWithExit() }
        }else{
            self.icono.image = UIImage(named: "ios_icono_alerta")
            self.labelTitulo.text = "Password incorrecto, por favor, ingresalo nuevamente."
        }
    }
    
    @IBAction func cerrar(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func recuperarPassword(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("RecuperarPassword") as! RecuperarPassword
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func cerrarTeclado(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
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
    
}
