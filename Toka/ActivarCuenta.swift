//
//  ActivarCuenta.swift
//  Toka
//
//  Created by Martin Viruete Gonzalez on 10/11/16.
//  Copyright © 2016 oOMovil. All rights reserved.
//

import UIKit

class ActivarCuenta: UIViewController,SOAPDelegate,UITextFieldDelegate,Popup2Delegate{

    @IBOutlet weak var txtCodigo: UITextField!
    @IBOutlet weak var btnActivar: UIButton!
    @IBOutlet weak var btnReenviar: UIButton!
    
    var clave : String! = nil
    var nombre : String! = nil
    var apellidos : String! = nil
    var celular : String! = nil
    var email: String! = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnActivar.layer.cornerRadius = 5
        btnReenviar.layer.cornerRadius = 5
        
        let toolBar: UIToolbar = UIToolbar()
        toolBar.barStyle = .Default
        toolBar.barTintColor = UIColor(red: 39/255, green: 39/255, blue: 39/255, alpha: 1)
        toolBar.sizeToFit()
        
        var barItems = [UIBarButtonItem]()
        
        let flexSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        barItems.insert(flexSpace, atIndex: 0)
        
        let cancelButton = UIBarButtonItem()
        cancelButton.title = "Cerrar"
        cancelButton.target = self
        cancelButton.style = UIBarButtonItemStyle.Plain
        cancelButton.action = #selector(self.siguiente)
        cancelButton.tintColor = UIColor.whiteColor()
        barItems.insert(cancelButton, atIndex: 1)
        
        toolBar.setItems(barItems, animated: false)
        self.txtCodigo.inputAccessoryView = toolBar
        
        

    }
    
    func siguiente(){
        
        self.view.endEditing(true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func cerrarTeclado(){
        self.view.endEditing(true)
    }

    @IBAction func regresar(sender: AnyObject) {
    
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func activar(sender: AnyObject) {
        
        let loadingView = self.storyboard?.instantiateViewControllerWithIdentifier("LoadingView") as! LoadingView
        self.presentViewController(loadingView, animated: false, completion: nil)
        
        let params = ["Codigo":self.txtCodigo.text!]
        let soap = SOAP(action: .Registrarse, params: params, delegate: self)
        soap.callRequest()

        
    }
    
    
    @IBAction func reenviar(sender: AnyObject) {
        
        let loadingView = self.storyboard?.instantiateViewControllerWithIdentifier("LoadingView") as! LoadingView
        self.presentViewController(loadingView, animated: false, completion: nil)
        let params = [String:String]()
        //let params = ["Nombre":self.textFieldNombre.text!,"Apellidos":self.textFieldApellido.text!,"Origen":"AppIOS","Email":self.textFieldEmail.text!,"Password":self.textFieldPassword.text!,"Celular":self.textFieldCelular.text!]
        let soap = SOAP(action: .Registrarse, params: params, delegate: self)
        soap.callRequest()

        
        
    }
    
    
    func didRecieveXML(XML: XMLIndexer,action: Services) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
        })
        
        do {
            if let data = try XML.byKey("soap:Envelope").byKey("soap:Body").byKey("createUserResponse").byKey("createUserResult").byKey("NewDataSet").byKey("Table").all.first{
                let enviado = try data.byKey("Res").element?.text == "OK"
                if enviado{
                    
                     dispatch_async(dispatch_get_main_queue(), {

                     let userData = ["clave":self.clave,"nombre":self.nombre,"apellidos":self.apellidos,"email":self.email,"celular":self.celular,"password":self.clave]
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
                     })
                    
                    
                    
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

    func didClick(){
        
    }
    func didTouchSecondButton(){
        
    }


}
