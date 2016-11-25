//
//  Producto.swift
//  Toka
//
//  Created by Martin Viruete Gonzalez on 20/06/16.
//  Copyright © 2016 oOMovil. All rights reserved.
//

import Foundation
class Producto {
    
    var icon: String = ""
    var detalle: [String] = [String]()
    
    init(icon: String, detalle: [String]){
        self.icon = icon
        self.detalle = detalle
    }
    
    static func getAll() -> [Producto]{
        var productos: [Producto] = [Producto]()
        productos.append(Producto(icon: "android_tarjeta1_easyvale", detalle: ["android_tarjeta1_easyvale1","android_tarjeta1_easyvale2","android_tarjeta1_easyvale3","android_tarjeta1_easyvale4"]))
        productos.append(Producto(icon: "android_tarjeta2_easygo", detalle: ["android_tarjeta2_easygo1","android_tarjeta2_easygo2","android_tarjeta2_easygo3","android_tarjeta2_easygo4"]))
        productos.append(Producto(icon: "android_tarjeta3_easyblack", detalle: ["android_tarjeta3_easygoblack1","android_tarjeta3_easygoblack2","android_tarjeta3_easygoblack3","android_tarjeta3_easygoblack4"]))
        productos.append(Producto(icon: "android_tarjeta4_easyshop", detalle: ["android_tarjeta4_easyshop1","android_tarjeta4_easyshop2","android_tarjeta4_easyshop3","android_tarjeta4_easyshop4"]))
        productos.append(Producto(icon: "android_tarjeta5_easygas", detalle: ["android_tarjeta5_easygas1","android_tarjeta5_easygas2","android_tarjeta5_easygas3","android_tarjeta5_easygas4"]))
        productos.append(Producto(icon: "android_tarjeta6_contpaq", detalle: ["android_tarjeta6_contpaq1","android_tarjeta6_contpaq2","android_tarjeta6_contpaq3","android_tarjeta6_contpaq4"]))
        return productos
    }
    
}
