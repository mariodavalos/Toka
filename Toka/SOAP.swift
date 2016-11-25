//
//  SOAP.swift
//  TOKA
//
//  Created by Martin Viruete Gonzalez on 01/07/16.
//
//

import Foundation

protocol SOAPDelegate {
    func didRecieveXML(XML: XMLIndexer,action: Services)
    func didFailReceivingXML(error: String)
}

class SOAP: NSObject, NSURLSessionTaskDelegate, NSURLSessionDelegate {
    
    let webServiceURL: String = "https://aplicaciones.toka.com.mx/WebServiceAppToka/Service.asmx"
    let nameSpace: String = "\"http://tempuri.org/\""
    
    var action: Services
    var params: [String:String]
    var delegate: SOAPDelegate?
    
    init(action: Services,params: [String:String],delegate: SOAPDelegate?){
        self.action = action
        self.params = params
        self.delegate = delegate
    }
    
    func callRequest(){
        
        let soapMessage: String = self.createXML()
        
        let length = String(format: "%d",soapMessage.characters.count)
        
        let urlString: String = self.webServiceURL
        
        guard let URL: NSURL = NSURL(string:  urlString) else { return }
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: URL)
        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(length, forHTTPHeaderField: "Content-Length")
        request.addValue("http://tempuri.org/\(self.action.rawValue)", forHTTPHeaderField: "SOAPAction")
        request.HTTPMethod = "POST"
        request.HTTPBody = soapMessage.dataUsingEncoding(NSUTF8StringEncoding)
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let delegateQueue = NSOperationQueue.mainQueue()
        let session: NSURLSession = NSURLSession(configuration: configuration, delegate: self, delegateQueue: delegateQueue)
        let dataTask: NSURLSessionDataTask = session.dataTaskWithRequest(request)
        dataTask.resume()
    }
    
    func createXML() -> String {
        var soapMessage = ""
        soapMessage += "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
        soapMessage += "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
        soapMessage +=      "<soap:Header>"
        soapMessage +=          "<AuthHeader xmlns=\(self.nameSpace)>"
        soapMessage +=              "<Username>appTokaWs</Username>"
        soapMessage +=              "<Password>WsA!1eMEaeh$EsEM3j0rsUv#HstRiaJfea</Password>"
        soapMessage +=          "</AuthHeader>"
        soapMessage +=      "</soap:Header>"
        soapMessage +=      "<soap:Body>"
        soapMessage +=          "<\(self.action.rawValue) xmlns=\(self.nameSpace)>"
        for (key,value) in self.params { soapMessage += "<\(key)>\(value)</\(key)>" }
        soapMessage +=          "</\(self.action.rawValue)>"
        soapMessage +=      "</soap:Body>"
        soapMessage += "</soap:Envelope>"
        return soapMessage
    }
    
    // - MARK: NSURLSessionTaskDelegate
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData){
        let XML = SWXMLHash.parse(data)
        if Utils.debugging { print(XML) }
        if delegate != nil{
            self.delegate!.didRecieveXML(XML,action: self.action)
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil{
            let errorString = error!.localizedDescription
            if Utils.debugging { print(errorString) }
            if delegate != nil{
                self.delegate!.didFailReceivingXML(errorString)
            }
        }
    }
    
    // - MARK: NSURLSessionDelegate
    
    /*func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential,NSURLCredential(forTrust:challenge.protectionSpace.serverTrust!))
    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential,NSURLCredential(forTrust:challenge.protectionSpace.serverTrust!))
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
        completionHandler(request)
    }*/
    
    
}

enum Services: String {
    case Login = "getUser"
    case RecuperarPassword = "sendMailPassword"
    case Registrarse = "createUser"
    case Tarjetas = "getUserCards"
    case ConsultaMovimientosCarnet = "consultaMovimientosCarnet"
    case ConsultaMovimientosMaster = "consultaMovimientosMaster"
    case EditarPerfil = "editUser"
    case EnviarMensaje = "sendMailForm"
    case BadgeZero = "setBadgeZero"
    case AgregarTarjeta = "addCard"
    case BorrarTarjeta = "deleteCard"
    case EditarTarjeta = "editCard"
    case SaldoCarnet = "consultaSaldoCarnet"
    case SaldoMaster = "consultaSaldoMaster"
    case Usuarios = "getRegisteredUsers"
}