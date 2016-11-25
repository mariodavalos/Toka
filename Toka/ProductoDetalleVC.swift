//
//  DetalleProductoVC.swift
//  Toka
//
//  Created by Martin Viruete Gonzalez on 20/06/16.
//  Copyright © 2016 oOMovil. All rights reserved.
//

import UIKit

class ProductoDetalleVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    var producto: Producto!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadDetalles()
    }

    func loadDetalles(){
        var contentSize: CGFloat = 0.0
        for detalle in self.producto.detalle{
            let imageDetalle: UIImage = UIImage(named: detalle)!
            let imageDetalleHeight: CGFloat = (self.view.frame.size.width * imageDetalle.size.height) / imageDetalle.size.width
            let imageViewDetalle: UIImageView = UIImageView(image: imageDetalle)
            imageViewDetalle.frame = CGRect(x: 0.0, y: contentSize, width: self.view.frame.size.width, height: imageDetalleHeight)
            self.scrollView.addSubview(imageViewDetalle)
            contentSize += imageDetalleHeight
        }
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: contentSize)
    }
    
    
    @IBAction func regresar(){
        self.navigationController?.popViewControllerAnimated(true)
    }

}
