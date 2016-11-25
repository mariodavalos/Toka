//
//  Slider.swift
//  Unity-iPhone
//
//  Created by Martin Viruete Gonzalez on 22/01/16.
//
//

import UIKit

class Slider: SlideMenuController {

    override func awakeFromNib() {
        if NSUserDefaults.standardUserDefaults().boolForKey("IR_NOTIFICACIONES"){
            if let controller = self.storyboard?.instantiateViewControllerWithIdentifier("Notificaciones") {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "IR_NOTIFICACIONES")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.mainViewController = controller
            }
        }else{
            if let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MisTarjetasNC") {
                self.mainViewController = controller
            }
        }
        if let controller = self.storyboard?.instantiateViewControllerWithIdentifier("Menu") {
            self.leftViewController = controller
        }
        super.awakeFromNib()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
