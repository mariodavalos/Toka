//
//  Menu.swift
//  Toka
//
//  Created by Martin Viruete Gonzalez on 17/06/16.
//  Copyright © 2016 oOMovil. All rights reserved.
//

import UIKit

class Menu: UIViewControllerFullScreen, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var labelUsuario: UILabel!
    @IBOutlet weak var imageViewPerfil: UIImageView!
    
    let arrayImagenes: [String] = ["ios_menu_btn_mistarjetas","ios_menu_btn_easyvale","ios_menu_btn_easygas","ios_menu_btn_promos",
                                   "ios_menu_btn_prod","ios_menu_btn_nosotros","ios_menu_btn_redes","ios_menu_btn_contacto","ios_menu_btn_notificaciones","ios_menu_btn_config"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
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
        
        if let userData = NSUserDefaults.standardUserDefaults().valueForKey(Utils.USER_DATA) as? [String:String]{
            let nombre = userData["nombre"] ?? ""
            let apellidos = userData["apellidos"] ?? ""
            self.labelUsuario.text = nombre + " " + apellidos
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.imageViewPerfil.layer.cornerRadius = self.imageViewPerfil.frame.size.height / 2
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayImagenes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("IconCell", forIndexPath: indexPath) as! IconCell
        let icono = self.arrayImagenes[indexPath.row]
        cell.imageViewIcono.image = UIImage(named: icono)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.height * 0.08
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var controller: UIViewController?
        switch indexPath.row{
            case 0: controller = self.storyboard?.instantiateViewControllerWithIdentifier("MisTarjetasNC")
            case 1: controller = self.storyboard?.instantiateViewControllerWithIdentifier("EasyValeNC")
            case 2: controller = self.storyboard?.instantiateViewControllerWithIdentifier("EasyGasNC")
            case 3: controller = self.storyboard?.instantiateViewControllerWithIdentifier("Promociones")
            case 4: controller = self.storyboard?.instantiateViewControllerWithIdentifier("ProductosNC")
            case 5: controller = self.storyboard?.instantiateViewControllerWithIdentifier("NosotrosVC")
            case 6: controller = self.storyboard?.instantiateViewControllerWithIdentifier("RedesSocialesVC")
            case 7: controller = self.storyboard?.instantiateViewControllerWithIdentifier("Contacto")
            case 8: controller = self.storyboard?.instantiateViewControllerWithIdentifier("Notificaciones")
            case 9: controller = self.storyboard?.instantiateViewControllerWithIdentifier("Configuracion")
            default: controller = nil
        }
        if controller != nil {
            self.slideMenuController()!.changeMainViewController(controller!, close: true)
        }
    }
}