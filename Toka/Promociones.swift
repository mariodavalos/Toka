//
//  Promociones.swift
//  TOKA
//
//  Created by Martin Viruete Gonzalez on 07/07/16.
//
//

import UIKit

class Promociones: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let urlString = "http://www.toka.com.mx/app/promocionesApp"
        guard let url = NSURL(string: urlString) else { return }
        self.webView.scrollView.bounces = false
        self.webView.loadRequest(NSURLRequest(URL: url))
    }


}
