//
//  Usuario.swift
//  TOKA
//
//  Created by Martin Viruete Gonzalez on 10/07/16.
//
//

import Foundation
class Usuario {
    
    var id: String
    var nombre: String 
    var apellidos: String
    var email: String
    var password: String
    var token: String
    var celular: String
    
    init(id: String,nombre: String,apellidos: String,email: String,password: String,token: String,celular: String){
        self.id = id
        self.nombre = nombre
        self.apellidos = apellidos
        self.email = email
        self.password = password
        self.token = token
        self.celular = celular
    }
    
    static func getCurrent() -> Usuario?{
        if let userData = NSUserDefaults.standardUserDefaults().valueForKey(Utils.USER_DATA) as? [String:String]{
            let id = userData["id"] ?? ""
            let nombre = userData["nombre"] ?? ""
            let apellidos = userData["apellidos"] ?? ""
            let email = userData["email"] ?? ""
            let password = userData["password"] ?? ""
            let token = NSUserDefaults.standardUserDefaults().valueForKey("TOKEN") as? String ?? ""
            let celular = userData["celular"] ?? ""
            let usuario = Usuario(id: id,nombre: nombre, apellidos: apellidos, email: email, password: password, token: token,celular: celular)
            return usuario
        }
        return nil
    }
}