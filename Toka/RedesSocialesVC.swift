//
//  RedesSocialesVC.swift
//  Toka
//
//  Created by Martin Viruete Gonzalez on 20/06/16.
//  Copyright © 2016 oOMovil. All rights reserved.
//

import UIKit

class RedesSocialesVC: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var buttonFacebook: UIButton!
    @IBOutlet weak var buttonTwitter: UIButton!
    @IBOutlet weak var buttonLinkedIn: UIButton!
    @IBOutlet weak var buttonYouTube: UIButton!
    
    var index: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadWebView()
    }
    
    @IBAction func cargarRedSocial(sender: UIButton){
        self.index = sender.tag
        self.apagarBotones()
        switch self.index {
            case 0: self.buttonFacebook.setImage(UIImage(named: "ios_redes_fb_act"), forState: .Normal)
            case 1: self.buttonTwitter.setImage(UIImage(named: "ios_redes_tw_act"), forState: .Normal)
            case 2: self.buttonLinkedIn.setImage(UIImage(named: "ios_redes_in_act"), forState: .Normal)
            case 3: self.buttonYouTube.setImage(UIImage(named: "ios_redes_yt_act"), forState: .Normal)
            default: return
        }
        self.loadWebView()
    }
    
    func loadWebView(){
        var urlString: String?
        switch self.index {
            case 0: urlString = "https://www.facebook.com/TokaMx/"
            case 1: urlString = "https://twitter.com/Toka_mx"
            case 2: urlString = "https://www.linkedin.com/company/toka-investment-sa-de-cv-sofom-enr"
            case 3: urlString = "https://www.youtube.com/channel/UCEQj5EcJjrlpecacWQn81jQ"
            default: urlString = nil
        }
        if urlString != nil{
            guard let url = NSURL(string: urlString!) else { return }
            let request = NSURLRequest(URL: url)
            self.webView.loadRequest(request)
        }
    }
    
    func apagarBotones(){
        self.buttonFacebook.setImage(UIImage(named: "ios_redes_fb_off"), forState: .Normal)
        self.buttonTwitter.setImage(UIImage(named: "ios_redes_tw_off"), forState: .Normal)
        self.buttonLinkedIn.setImage(UIImage(named: "ios_redes_in_off"), forState: .Normal)
        self.buttonYouTube.setImage(UIImage(named: "ios_redes_yt_off"), forState: .Normal)
    }
    
}
