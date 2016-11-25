//
//  Aviso.swift
//  TOKA
//
//  Created by Martin Viruete Gonzalez on 11/07/16.
//
//

import UIKit
import Alamofire

class Aviso: UIViewController {

    @IBOutlet weak var labelAviso: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Alamofire.request(.GET, "http://appadmin.toka.com.mx/api/aviso/format/json").responseJSON { (response) in
            guard let data = response.data where response.result.isSuccess else {
                print(response.result.error)
                if let avisoGuardado = NSUserDefaults.standardUserDefaults().stringForKey("AVISO_PRIV"){
                    self.labelAviso.text = avisoGuardado
                }
                return
            }
            let json = JSON(data: data)
            if Utils.debugging { print(json) }
            if json["exito"].intValue == 1{
                if let mydatat = json["data"].array{
                    if let aviso = mydatat[0].dictionary{
                        if let stringAviso = aviso["aviso"]?.string{
                            self.labelAviso.text = stringAviso
                            NSUserDefaults.standardUserDefaults().setValue(stringAviso, forKey: "AVISO_PRIV")
                            NSUserDefaults.standardUserDefaults().synchronize()
                        }
                    }
                }
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    @IBAction func regresar(){
        self.navigationController?.popViewControllerAnimated(true)
    }

}
