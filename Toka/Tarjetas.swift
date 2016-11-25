//
//  Tarjetas.swift
//  TOKA
//
//  Created by Martin Viruete Gonzalez on 04/07/16.
//
//

import Foundation

class Tarjetas {
    
    var numero: String
    var etiqueta: String
    var marca: String
    var movimientos: [MovimientosTarjeta] = [MovimientosTarjeta]()
    
    init(numero: String,etiqueta: String, marca: String){
        self.numero = numero
        self.etiqueta = etiqueta
        self.marca = marca
    }
    
}