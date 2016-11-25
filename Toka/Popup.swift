//
//  Popup.swift
//  TOKA
//
//  Created by Martin Viruete Gonzalez on 01/07/16.
//
//

import UIKit

public protocol PopupDelegate : NSObjectProtocol{
    func didTouchButton()
}

class Popup: UIViewController {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var imageViewIcono: UIImageView!
    @IBOutlet weak var labelTitulo: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var icono: UIImage!
    var mensaje: String!
    var buttonIcon: UIImage? = UIImage(named: "ios_btn_aceptar")
    var delegate: PopupDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.container.layer.cornerRadius = 10
        self.labelTitulo.text = self.mensaje
        self.imageViewIcono.image = self.icono
        self.button.setImage(self.buttonIcon, forState: .Normal)
    }
    
    override func viewDidLayoutSubviews() {
        self.container.layer.cornerRadius = 10
    }
    
    @IBAction func aceptar(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
        if self.delegate != nil { self.delegate!.didTouchButton() }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
