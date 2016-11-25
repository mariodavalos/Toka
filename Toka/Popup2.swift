
//
//  Popup2.swift
//  TOKA
//
//  Created by Martin Viruete Gonzalez on 10/07/16.
//
//

import UIKit

public protocol Popup2Delegate : NSObjectProtocol{
    func didClick()
    func didTouchSecondButton()
}

class Popup2: UIViewController {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var imageViewIcono: UIImageView!
    @IBOutlet weak var labelTitulo: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var secondbutton: UIButton!
    
    var icono: UIImage!
    var mensaje: String!
    var buttonIcon: UIImage? = UIImage(named: "ios_btn_aceptar")
    var buttonIcon2: UIImage? = UIImage(named: "ios_btn_verdetalles")
    var delegate: Popup2Delegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.container.layer.cornerRadius = 10
        self.labelTitulo.text = self.mensaje
        self.imageViewIcono.image = self.icono
        self.button.setImage(self.buttonIcon, forState: .Normal)
        self.secondbutton.setImage(self.buttonIcon2, forState: .Normal)
    }
    
    override func viewDidLayoutSubviews() {
        self.container.layer.cornerRadius = 10
    }
    
    @IBAction func aceptar(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
        if self.delegate != nil { self.delegate!.didClick() }
    }
    
    @IBAction func aceptar2(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
        if self.delegate != nil { self.delegate!.didTouchSecondButton() }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}
