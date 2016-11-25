//
//  CarruselTarjetas.swift
//  TOKA
//
//  Created by Martin Viruete Gonzalez on 04/07/16.
//
//

import UIKit

protocol CarruselDelegate {
    func moveToIndex(index:Int)
}

class CarruselTarjetas: UIPageViewController {

    var tarjetas = [Tarjetas]()
    var currentIndex: Int = 0
    var delegateT: CarruselDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.obtenerTarjetas()
        dataSource = self
        delegate = self
        if NSUserDefaults.standardUserDefaults().boolForKey("VER_ULTIMO") && self.tarjetas.count > 1{
            if let viewController = viewPhotoCommentController(self.tarjetas.count - 1) {
                viewController.vistaActiva = true
                let viewControllers = [viewController]
                setViewControllers(viewControllers,direction: .Forward,animated: false,completion: nil)
            }
        }else{
            if let viewController = viewPhotoCommentController(currentIndex ) {
                viewController.vistaActiva = true
                let viewControllers = [viewController]
                setViewControllers(viewControllers,direction: .Forward,animated: false,completion: nil)
            }
        }
    }
    
    func viewPhotoCommentController(index: Int) -> TarjetaViewController? {
        if let storyboard = storyboard, page = storyboard.instantiateViewControllerWithIdentifier("TarjetaViewController")as? TarjetaViewController {
            page.tarjeta = self.tarjetas[index]
            page.tarjetaIndex = index
            page.view.tag = index
            return page
        }
        return nil
    }
    
    func moveToIndex(index: Int){
        if let viewController = viewPhotoCommentController(index) {
            viewController.vistaActiva = true
            let viewControllers = [viewController]
            setViewControllers(viewControllers,direction: .Forward,animated: false,completion: nil)
        }
    }
    
    func obtenerTarjetas(){
        let defaults = NSUserDefaults.standardUserDefaults()
        if let tarjetas = defaults.valueForKey(Utils.USER_CARDS) as? [[String:String]]{
            
            for tarjeta in tarjetas{
                let numero = tarjeta["tarjeta"] ?? "NULL"
                let etiqueta = tarjeta["etiqueta"] ?? "NULL"
                let marca = tarjeta["Marca"] ?? "NULL"
                self.tarjetas.append(Tarjetas(numero: numero, etiqueta: etiqueta, marca: marca))
            }
            
        }
    }
    
}

extension CarruselTarjetas: UIPageViewControllerDataSource,UIPageViewControllerDelegate{
    
    func pageViewController(pageViewController: UIPageViewController,viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? TarjetaViewController {
            var index = viewController.tarjetaIndex
            guard index != NSNotFound && index != 0 else { return nil }
            index = index - 1
            if let page = viewPhotoCommentController(index){
                page.view.tag = index
                page.vistaActiva = false
                return page
            }
            return nil
        }
        return nil
    }
    
    
    func pageViewController(pageViewController: UIPageViewController,viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        if let viewController = viewController as? TarjetaViewController {
            var index = viewController.tarjetaIndex
            guard index != NSNotFound else { return nil }
            index = index + 1
            guard index != tarjetas.count else {return nil}
            if let page = viewPhotoCommentController(index){
                page.view.tag = index
                page.vistaActiva = false
                return page
            }
            return nil
        }
        return nil
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.tarjetas.count
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed
        {
            return
        }
        if let page = pageViewController.viewControllers?.first as? TarjetaViewController{
            if delegateT != nil{
                delegateT?.moveToIndex(page.tarjetaIndex)
            }
        }
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        //print("UAH AUSDHA SD")
    }
    
    
    /*func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.currentIndex ?? 0
    }*/
    
}
