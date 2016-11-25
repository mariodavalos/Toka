//
//  NosotrosVC.swift
//  Toka
//
//  Created by Martin Viruete Gonzalez on 20/06/16.
//  Copyright © 2016 oOMovil. All rights reserved.
//

import UIKit

class NosotrosVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    let nosotrosTexto: [String] = ["android_nosotros_texto1","android_nosotros_texto2","android_nosotros_texto3","android_nosotros_texto4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadNosotros()
    }
    
    func loadNosotros(){
        var contentSize: CGFloat = 0.0
        for texto in self.nosotrosTexto{
            let imageDetalle: UIImage = UIImage(named: texto)!
            let imageDetalleHeight: CGFloat = (self.view.frame.size.width * imageDetalle.size.height) / imageDetalle.size.width
            let imageViewDetalle: UIImageView = UIImageView(image: imageDetalle)
            imageViewDetalle.frame = CGRect(x: 0.0, y: contentSize, width: self.view.frame.size.width, height: imageDetalleHeight)
            self.scrollView.addSubview(imageViewDetalle)
            contentSize += imageDetalleHeight
        }
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: contentSize)
    }
}
