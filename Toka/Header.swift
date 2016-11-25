//
//  Header.swift
//  Toka
//
//  Created by Martin Viruete Gonzalez on 16/06/16.
//  Copyright © 2016 oOMovil. All rights reserved.
//

import UIKit

class Header: UIViewController {
    
    @IBOutlet weak var labelUsuario: UILabel!
    @IBOutlet weak var labelContador: UILabel!
    @IBOutlet weak var imageViewPerfil: UIImageView!
    
    @IBAction func abrirCerrarMenu() {
        if let slideMenuController = self.slideMenuController() {
            slideMenuController.openLeft()
        }
    }
    
    @IBAction func abrirNotificaciones() {
        if let slideMenuController = self.slideMenuController() {
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("Notificaciones")
            slideMenuController.changeMainViewController(controller!, close: true)
        }
    }
    
    override func viewDidLoad() {
        if let userData = NSUserDefaults.standardUserDefaults().valueForKey(Utils.USER_DATA) as? [String:String]{
            let nombre = userData["nombre"] ?? ""
            //let apellidos = userData["apellidos"] ?? ""
            self.labelUsuario.text = nombre //+ " " + apellidos
        }
        self.ponIndicador()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.ponIndicador), name: "PONBADGE", object: nil)
    }
    
    func ponIndicador() {
        if UIApplication.sharedApplication().applicationIconBadgeNumber > 0 {
            self.labelContador.text = "\(UIApplication.sharedApplication().applicationIconBadgeNumber)"
            return
        }
        
        if let badge = NSUserDefaults.standardUserDefaults().valueForKey("BADGE") as? Int{
            self.labelContador.text = "\(badge)"
            UIApplication.sharedApplication().applicationIconBadgeNumber = badge
        }
    }
    
    override func viewDidLayoutSubviews() {
        if let imageData = NSUserDefaults.standardUserDefaults().valueForKey(Utils.USER_IMAGE) as? [String:NSData]{
            if let userData = NSUserDefaults.standardUserDefaults().valueForKey(Utils.USER_DATA) as? [String:String]{
                let id = userData["email"] ?? ""
                if let img = imageData[id]{
                    self.imageViewPerfil.image = UIImage(data: img)
                }else{
                    self.imageViewPerfil.image = UIImage(named: "android_default")
                }
            }else{
                self.imageViewPerfil.image = UIImage(named: "android_default")
            }
        }else{
            self.imageViewPerfil.image = UIImage(named: "android_default")
        }
        self.imageViewPerfil.layer.cornerRadius = self.imageViewPerfil.frame.size.height / 2
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
