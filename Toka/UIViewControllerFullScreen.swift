//
//  ViewControllerFullScreen.swift
//  Toka
//
//  Created by Martin Viruete Gonzalez on 17/06/16.
//  Copyright © 2016 oOMovil. All rights reserved.
//

import UIKit

class UIViewControllerFullScreen: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true // Esconde la barra de estado (La que muestra el wifi y la bateria)
    }

}
