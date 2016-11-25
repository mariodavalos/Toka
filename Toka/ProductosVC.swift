//
//  ProductosVC.swift
//  Toka
//
//  Created by Martin Viruete Gonzalez on 20/06/16.
//  Copyright © 2016 oOMovil. All rights reserved.
//

import UIKit

class ProductosVC: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableViewProductos: UITableView!
    let productos: [Producto] = Producto.getAll()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.productos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("IconCell", forIndexPath: indexPath) as! IconCell
        let producto = self.productos[indexPath.row]
        cell.imageViewIcono.image = UIImage(named: producto.icon)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.height * 0.3
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let producto = self.productos[indexPath.row]
        let detalleVC = self.storyboard?.instantiateViewControllerWithIdentifier("ProductoDetalleVC") as! ProductoDetalleVC
        detalleVC.producto = producto
        self.navigationController?.pushViewController(detalleVC, animated: true)
    }

}
