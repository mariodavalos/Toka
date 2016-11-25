//
//  EasyGasEstaciones.swift
//  TOKA
//
//  Created by Martin Viruete Gonzalez on 08/07/16.
//
//

import UIKit

class EasyGasEstaciones: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableViewSucursales: UITableView!
    @IBOutlet weak var textFiedlBusqueda: UITextField!
    
    var easyGasArray: [EasyGas] = [EasyGas]()
    var filtroBusqueda: [EasyGas] = [EasyGas]()
    var filtro = ""
    var buscando = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textFiedlBusqueda.text = filtro
    }
    
    @IBAction func regresar(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.easyGasArray.count == 0 || self.filtroBusqueda.count == 0{
            return 1
        }
        return (self.buscando) ? self.filtroBusqueda.count : self.easyGasArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.easyGasArray.count == 0 || self.filtroBusqueda.count == 0{
            let cell = tableView.dequeueReusableCellWithIdentifier("ErrorResultadosCell", forIndexPath: indexPath)
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("SucursalCell", forIndexPath: indexPath) as! SucursalCell
        let estacion = (self.buscando) ? self.filtroBusqueda[indexPath.row] : self.easyGasArray[indexPath.row]
        cell.labelNombre.text = estacion.nombre
        cell.labelCiudadEstado.text = estacion.ciudad + "," + estacion.estado
        cell.buttonVerMapa.tag = indexPath.row
        cell.buttonVerMapa.addTarget(self, action: #selector(self.verEstablecimiento(_:)), forControlEvents: .TouchUpInside)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.height * 0.1
    }
    
    func verEstablecimiento(sender: UIButton){
        let sucursal = (self.buscando) ? self.filtroBusqueda[sender.tag] : self.easyGasArray[sender.tag]
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("EasyGasUbicacionEstablecimiento") as! EasyGasUbicacionEstablecimiento
        vc.easyGas = sucursal
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.buscando = false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.buscando = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string == "" && textField.text!.characters.count == 1{
            self.buscando = false
            print("EN BLANCO")
        }else{
            self.buscando = true
            self.filtroBusqueda = self.easyGasArray.filter{ store in
                let busqueda = (string != "") ? self.textFiedlBusqueda.text! + string : String(self.textFiedlBusqueda.text!.characters.dropLast())
                return store.nombre.lowercaseString.containsString(busqueda.lowercaseString)
            }
        }
        self.tableViewSucursales.reloadData()
        return true
    }

}
