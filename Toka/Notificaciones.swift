//
//  Notificaciones.swift
//  TOKA
//
//  Created by Martin Viruete Gonzalez on 07/07/16.
//
//

import UIKit
import Alamofire

class Notificaciones: UIViewController,UITableViewDelegate,UITableViewDataSource,SOAPDelegate,Popup2Delegate {
    
    @IBOutlet weak var tableView: UITableView!
    var notificaciones = [Notificacion]()
    var email = ""
    var pass = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100.0
        
        self.traerNotificaciones()
    }
    
    func traerNotificaciones(){
        
        guard let id = NSUserDefaults.standardUserDefaults().valueForKey(Utils.USER_ID) as? String else{
            self.traerID()
            return
        }
        
        guard let userData = NSUserDefaults.standardUserDefaults().valueForKey(Utils.USER_DATA) as? [String:String], let fecha = userData["fechaRegistroApp"] else{
             self.traerID()
            return
        }
        
        let loadingView = self.storyboard?.instantiateViewControllerWithIdentifier("LoadingView") as! LoadingView
        self.presentViewController(loadingView, animated: false, completion: nil)
        let url: String = Utils.URL_SERVICIOS.stringByReplacingOccurrencesOfString("servicio", withString: Servicios.Notificaciones.rawValue)
        let params = ["id":id,"x":"\(rand())","fecha":fecha]
        print(params)
        Alamofire.request(.GET, url,parameters: params).responseJSON { (response) in
            self.dismissViewControllerAnimated(false, completion: nil)
            guard let data = response.data where response.result.isSuccess else {
                print(response.result.error)
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
                return
            }
            let json = JSON(data: data)
            if Utils.debugging { print(json) }
            for notificacion in json["data"].arrayValue{
                let nuevaNotificaion = Notificacion()
                nuevaNotificaion.fecha = notificacion["fecha"].string ?? ""
                nuevaNotificaion.titulo = notificacion["mensaje"].string ?? ""
                nuevaNotificaion.id = notificacion["idNotificaciones"].string ?? ""
                self.notificaciones.append(nuevaNotificaion)
            }
            
            self.tableView.reloadData()
            self.setBadgeZero()
        }
    }
    
    func setBadgeZero(){
        if let token = NSUserDefaults.standardUserDefaults().valueForKey("TOKEN") as? String{
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            NSUserDefaults.standardUserDefaults().setValue(0, forKey: "BADGE")
            NSUserDefaults.standardUserDefaults().synchronize()
            let notification = NSNotification(name: "PONBADGE", object: nil)
            NSNotificationCenter.defaultCenter().postNotification(notification)
            let params = ["Token":token]
            let soap = SOAP(action: .BadgeZero, params: params, delegate: self)
            soap.callRequest()
        }
    }
    
    func traerID(){
        guard let data = NSUserDefaults.standardUserDefaults().valueForKey(Utils.USER_DATA) as? [String:String] else{
            return
        }
        self.email = data["email"] ?? ""
        self.pass = data["password"] ?? ""
        let params = ["Email":email,"Password":pass]
        let soap = SOAP(action: .Login, params: params, delegate: self)
        soap.callRequest()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notificaciones.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NotificationCellTableViewCell",forIndexPath: indexPath) as! NotificationCellTableViewCell
        let notificacion = self.notificaciones[indexPath.row]
        cell.labelFecha.text = notificacion.fecha
        cell.labelTitulo.text = notificacion.titulo
        return cell
    }
    
    func borrarNotificacion(indexPath: NSIndexPath){
        guard let id = NSUserDefaults.standardUserDefaults().valueForKey(Utils.USER_ID) as? String else{
            self.traerID()
            return
        }
        
        let idNotificacion = self.notificaciones[indexPath.row].id
        
        let loadingView = self.storyboard?.instantiateViewControllerWithIdentifier("LoadingView") as! LoadingView
        self.presentViewController(loadingView, animated: false, completion: nil)
        let url: String = Utils.URL_SERVICIOS.stringByReplacingOccurrencesOfString("servicio", withString: Servicios.BorrarNotificacion.rawValue)
        let params = ["id_user":id,"id":idNotificacion]
        Alamofire.request(.GET, url,parameters: params).responseJSON { (response) in
            self.dismissViewControllerAnimated(false, completion: nil)
            guard let _ = response.data where response.result.isSuccess else {
                print(response.result.error)
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
                return
            }
            self.notificaciones.removeAtIndex(indexPath.row)
            self.tableView.beginUpdates()
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            self.tableView.endUpdates()
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Eliminar" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            self.borrarNotificacion(indexPath)
        })
        shareAction.backgroundColor = UIColor(red: 7/255, green: 22/255, blue: 137/255, alpha: 1.0)
        return [shareAction]
    }
    
    // MARK: - SOAPDelegate
    
    func didRecieveXML(XML: XMLIndexer,action: Services) {
        do {
            if let data = try XML.byKey("soap:Envelope").byKey("soap:Body").byKey("getUserResponse").byKey("getUserResult").byKey("NewDataSet").byKey("Table").all.first{
                let clave = try data.byKey("clave").element?.text ?? ""
                let nombre = try data.byKey("nombre").element?.text ?? ""
                let apellidos = try data.byKey("apellidos").element?.text ?? ""
                let id = try data.byKey("id").element?.text ?? ""
                let email = self.email
                let pass = self.pass
                let fechaRegistroApp = try data.byKey("fechaRegistroApp").element?.text ?? ""
                let userData = ["clave":clave,"nombre":nombre,"apellidos":apellidos,"id":id,"email":email,"password":pass,"fechaRegistroApp":fechaRegistroApp]
                NSUserDefaults.standardUserDefaults().setObject(userData, forKey: Utils.USER_DATA)
                NSUserDefaults.standardUserDefaults().setObject(id, forKey: Utils.USER_ID)
                NSUserDefaults.standardUserDefaults().synchronize()
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.traerNotificaciones()
                })
            }
        }catch let error as XMLIndexer.Error{
            print(error.description)
        }catch {
        }
    }
    
    func didFailReceivingXML(error: String) {
    }
    
    func didClick(){
        
    }
    
    func didTouchSecondButton(){
        self.traerNotificaciones()
    }
    
}
