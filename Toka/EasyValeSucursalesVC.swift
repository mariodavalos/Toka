//
//  EasyValeSucursalesVC.swift
//  Toka
//
//  Created by Martin Viruete Gonzalez on 22/06/16.
//  Copyright © 2016 oOMovil. All rights reserved.
//

import UIKit

class EasyValeSucursalesVC: UIViewController, UITableViewDataSource, UITableViewDelegate,EasyValeEstablecimientoDelegate {

    @IBOutlet weak var imageViewLogo: UIImageView!
    @IBOutlet weak var tableViewSucursales: UITableView!
    
    var easyVale: EasyVale!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageViewLogo.downloadImageFrom(link: easyVale.logo, contentMode: .ScaleAspectFit)
    }
    
    @IBAction func regresar(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.easyVale.sucursales.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SucursalCell", forIndexPath: indexPath) as! SucursalCell
        let sucursal = self.easyVale.sucursales[indexPath.row]
        cell.labelNombre.text = sucursal.nombre
        cell.labelCiudadEstado.text = sucursal.ciudad + "," + sucursal.estado
        cell.buttonVerMapa.tag = indexPath.row
        cell.buttonVerMapa.addTarget(self, action: #selector(self.verEstablecimiento(_:)), forControlEvents: .TouchUpInside)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.height * 0.1
    }
    
    func verEstablecimiento(sender: UIButton){
        let sucursal = self.easyVale.sucursales[sender.tag]
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("EasyValeEstablecimiento") as! EasyValeEstablecimiento
        vc.easyVale = self.easyVale
        vc.sucursal = sucursal
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func willGoToAll() {
        self.navigationController?.popViewControllerAnimated(false)
    }
}
