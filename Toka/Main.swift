//
//  Main.swift
//  TOKA
//
//  Created by Martin Viruete Gonzalez on 28/06/16.
//
//

import UIKit

class Main: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - @IBAction Methods
    
    @IBAction func iniciarRA(){
        let notification = NSNotification(name: "irRA", object: nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    @IBAction func iniciarSesion(){
        let controller: IniciarSesion = self.storyboard?.instantiateViewControllerWithIdentifier("IniciarSesion") as! IniciarSesion
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func iniciarRegistro(){
        let controller: Registrarse = self.storyboard?.instantiateViewControllerWithIdentifier("Registrarse") as! Registrarse
        self.navigationController?.pushViewController(controller, animated: true)
    }

}
