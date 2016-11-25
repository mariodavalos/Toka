//
//  TarjetaViewController.swift
//  TOKA
//
//  Created by Martin Viruete Gonzalez on 04/07/16.
//
//

import UIKit
import Alamofire

class TarjetaViewController: UIViewController,SOAPDelegate,Popup2Delegate {
    
    @IBOutlet weak var labelAlias: UILabel!
    @IBOutlet weak var labelNumero: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var tarjeta: Tarjetas!
    var tarjetaIndex: Int!
    
    var contents = ""
    var baseUrl: NSURL?
    
    var mesActual: Int = 0
    var mesAnterior: Int = 0
    var mesAnterior2: Int = 0
    
    var mesActivo = 2
    
    var añoActual: Int = 0
    var posibleAñoAnterior: Int?
    var saldo: Double?
    var movimientosObtenidos = false
    var bloqueada = false
    var vistaActiva = false
    var aparecio = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.labelAlias.text = self.tarjeta.etiqueta
        var numero = self.tarjeta.numero
        numero.removeRange(tarjeta.numero.startIndex...tarjeta.numero.endIndex.advancedBy(-5))
        self.labelNumero.text = "************" + numero
        
        self.obtenerFecha()
        
        let HTML = NSBundle.mainBundle().pathForResource("index", ofType: "html", inDirectory: "web")
        self.contents = try! String(contentsOfFile: HTML!, encoding: NSUTF8StringEncoding)
        self.baseUrl = NSURL(fileURLWithPath: HTML!)
        self.obtenerSaldo()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.aparecio = true
        if self.bloqueada{
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
                let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup") as! Popup
                popUp.mensaje = "No se puede consultar el saldo y movimientos, por favor comunícate al 01 (55) 4125 0320 opción 4 y 2 para validar el estatus de tu tarjeta."
                popUp.buttonIcon = UIImage(named: "ios_btn_aceptar")
                popUp.icono = UIImage(named: "ios_icono_alerta")
                self.presentViewController(popUp, animated: false, completion: nil)
            }
            return
        }
    }
    
    func loadWebView(webView: UIWebView,forIndex: Int){
        var gastos = 0.0
        var depositos = 0.0
        for mov in self.tarjeta.movimientos{
            gastos += Double(mov.consumo) ?? 0.0
            depositos += Double(mov.abono) ?? 0.0
        }
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.groupingSeparator = ","
        
        let formatGasto = NSNumber(double: gastos)
        let formatSaldo = NSNumber(double: self.saldo!)
        let formatDeposito = NSNumber(double: depositos)
        
        var newContent = self.contents.stringByReplacingOccurrencesOfString("val_gastos", withString: "\(formatter.stringFromNumber(formatGasto)!)")
        newContent = newContent.stringByReplacingOccurrencesOfString("val_depositos", withString: "\(formatter.stringFromNumber(formatDeposito)!)")
        newContent = newContent.stringByReplacingOccurrencesOfString("val_saldoactual", withString: "\(formatter.stringFromNumber(formatSaldo)!)")
        webView.loadHTMLString(newContent, baseURL: self.baseUrl)
    }
    
    func obtenerSaldo(){
        let params = ["Tarjeta":self.tarjeta.numero,"origen":"AppIOS"]
        if self.tarjeta.marca == "MASTERCARD"{
            let soap = SOAP(action: Services.SaldoMaster, params: params, delegate: self)
            soap.callRequest()
        }else{
            let soap = SOAP(action: Services.SaldoCarnet, params: params, delegate: self)
            soap.callRequest()
        }
    }
    
    func obtenerFecha(){
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Month , .Year], fromDate: date)
        
        self.añoActual  =  components.year
        self.mesActual  =  components.month
        
    }
    
    func stringForMonth(month: Int) -> String{
        switch month {
        case 1: return "ENERO"
        case 2: return "FEBRERO"
        case 3: return "MARZO"
        case 4: return "ABRIL"
        case 5: return "MAYO"
        case 6: return "JUNIO"
        case 7: return "JULIO"
        case 8: return "AGOSTO"
        case 9: return "SEPTIEMBRE"
        case 10: return "OCTUBRE"
        case 11: return "NOVIEMBRE"
        case 12: return "DICIEMBRE"
        default: return ""
        }
    }
    
    func startDateFor(month: Int) -> String{
        switch month {
        case 1: return (self.posibleAñoAnterior != nil) ? "\(self.posibleAñoAnterior!)0101" :  "\(self.añoActual)0101"
        case 2: return (self.posibleAñoAnterior != nil) ? "\(self.posibleAñoAnterior!)0201" : "\(self.añoActual)0201"
        case 3: return (self.posibleAñoAnterior != nil) ? "\(self.posibleAñoAnterior!)0301" : "\(self.añoActual)0301"
        case 4: return (self.posibleAñoAnterior != nil) ? "\(self.posibleAñoAnterior!)0401" : "\(self.añoActual)0401"
        case 5: return (self.posibleAñoAnterior != nil) ? "\(self.posibleAñoAnterior!)0501" : "\(self.añoActual)0501"
        case 6: return (self.posibleAñoAnterior != nil) ? "\(self.posibleAñoAnterior!)0601" : "\(self.añoActual)0601"
        case 7: return (self.posibleAñoAnterior != nil) ? "\(self.posibleAñoAnterior!)0701" : "\(self.añoActual)0701"
        case 8: return (self.posibleAñoAnterior != nil) ? "\(self.posibleAñoAnterior!)0801" : "\(self.añoActual)0801"
        case 9: return (self.posibleAñoAnterior != nil) ? "\(self.posibleAñoAnterior!)0901" : "\(self.añoActual)0901"
        case 10: return (self.posibleAñoAnterior != nil) ? "\(self.posibleAñoAnterior!)1001" : "\(self.añoActual)1001"
        case 11: return (self.posibleAñoAnterior != nil) ? "\(self.posibleAñoAnterior!)1101" : "\(self.añoActual)1101"
        case 12: return (self.posibleAñoAnterior != nil) ? "\(self.posibleAñoAnterior!)1201" : "\(self.añoActual)1201"
        default: return ""
        }
    }
    
    func endDateFor(month: Int) -> String{
        switch month {
        case 1: return (self.posibleAñoAnterior != nil) ? "\(self.posibleAñoAnterior!)0131" : "\(self.añoActual)0131"
        case 2: return (self.posibleAñoAnterior != nil) ? "\(self.posibleAñoAnterior!)0228" : "\(self.añoActual)0228"
        case 3: return (self.posibleAñoAnterior != nil) ? "\(self.posibleAñoAnterior!)0331" : "\(self.añoActual)0331"
        case 4: return (self.posibleAñoAnterior != nil) ? "\(self.posibleAñoAnterior!)0430" : "\(self.añoActual)0430"
        case 5: return (self.posibleAñoAnterior != nil) ? "\(self.posibleAñoAnterior!)0531" : "\(self.añoActual)0531"
        case 6: return (self.posibleAñoAnterior != nil) ? "\(self.posibleAñoAnterior!)0630" : "\(self.añoActual)0630"
        case 7: return (self.posibleAñoAnterior != nil) ? "\(self.posibleAñoAnterior!)0731" : "\(self.añoActual)0731"
        case 8: return (self.posibleAñoAnterior != nil) ? "\(self.posibleAñoAnterior!)0831" : "\(self.añoActual)0831"
        case 9: return (self.posibleAñoAnterior != nil) ? "\(self.posibleAñoAnterior!)0930" : "\(self.añoActual)0930"
        case 10: return (self.posibleAñoAnterior != nil) ? "\(self.posibleAñoAnterior!)1031" : "\(self.añoActual)1031"
        case 11: return (self.posibleAñoAnterior != nil) ? "\(self.posibleAñoAnterior!)1130" : "\(self.añoActual)1130"
        case 12: return (self.posibleAñoAnterior != nil) ? "\(self.posibleAñoAnterior!)1231" : "\(self.añoActual)1231"
        default: return ""
        }
    }
    
    func loadMovimientos(month: Int){
        self.tarjeta.movimientos.removeAll()
        self.movimientosObtenidos = false
        self.tableView.reloadData()
        let fechaInicio = self.startDateFor(month)
        let fechaFin = self.endDateFor(month)
        let params = ["Tarjeta":self.tarjeta.numero,"fechaInicio":fechaInicio,"fechaFin":fechaFin]
        print("PARAMETROS A ENVIAR \(params)")
        if self.tarjeta.marca == "MASTERCARD"{
            
            Alamofire.request(.GET, "http://appadmin.toka.com.mx/api/movimientos_master/format/json?tarjeta=\(self.tarjeta.numero)&fi=\(fechaInicio)&ff=\(fechaFin)").response(completionHandler: { (req, res, data, error) in
                
                if let respuesta = data{
                    let XML = SWXMLHash.parse(respuesta)
                    if Utils.debugging { print(XML) }
                    self.movimientosObtenidos = true
                    for data in XML["soap:Envelope"]["soap:Body"]["consultaMovimientosMasterResponse"]["consultaMovimientosMasterResult"]["respuestaMovimientos"].all{
                        
                        let concepto = data["descripcionComercio"].element?.text ?? ""
                        print("NUMERO DE DATA QUE SE IMPRIME \(concepto)")
                        let fecha = data["fecha"].element?.text?.stringByReplacingOccurrencesOfString(" ", withString: "") ?? ""
                        let monto = data["monto"].element?.text?.stringByReplacingOccurrencesOfString(" ", withString: "") ?? ""
                        let tipo = data["tipo"].element?.text?.stringByReplacingOccurrencesOfString(" ", withString: "") ?? ""
                        let documento = data["documento1"].element?.text?.stringByReplacingOccurrencesOfString(" ", withString: "") ?? ""
                        let nuevoMovimiento = MovimientosTarjeta()
                        
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyyMMdd"
                        let date = dateFormatter.dateFromString(fecha)
                        dateFormatter.dateFormat = "dd/MM/yyyy"
                        nuevoMovimiento.fecha = dateFormatter.stringFromDate(date!)
                        
                        nuevoMovimiento.concepto = concepto
                        nuevoMovimiento.tipo = tipo
                        nuevoMovimiento.documento = documento
                        
                        if tipo == "RECARGA" || tipo == "REVERSIONDEFACTURA"{
                            nuevoMovimiento.abono = monto
                        }else{
                            nuevoMovimiento.consumo = monto
                        }
                        
                        if tipo == "FACTURA"{
                            nuevoMovimiento.tipo = "CONSUMO"
                        }else if tipo == "NOTADECREDITO" || tipo == "NOTADEDEBITO"{
                            nuevoMovimiento.tipo = "DECREMENTO"
                            nuevoMovimiento.concepto = "DECREMENTO GO ONLINE"
                        }else if tipo == "ADELANTODEEFECTIVO"{
                            nuevoMovimiento.tipo = "CONSUMO"
                            nuevoMovimiento.concepto = "DISPOSICIÓN EFECTIVO"
                            nuevoMovimiento.abono = ""
                            nuevoMovimiento.consumo = monto
                        }else if tipo == "MOV.REVERSIONRECARGAEFECTIVO"{
                            nuevoMovimiento.tipo = "CONSUMO"
                            nuevoMovimiento.concepto = "MOV.REVERSIÓN RECARGA EFECTIVO"
                            nuevoMovimiento.abono = ""
                            nuevoMovimiento.consumo = monto
                        }else if tipo == "CREDITOPORTRASLADO"{
                            nuevoMovimiento.tipo = "ABONO"
                            nuevoMovimiento.concepto = "TRASPASO DE MOV. DÓLARES"
                            nuevoMovimiento.abono = monto
                            nuevoMovimiento.consumo = ""
                        }else if tipo == "DEBITOPORTRASLADO"{
                            nuevoMovimiento.tipo = "CONSUMO"
                            nuevoMovimiento.concepto = "TRASPASO DE MOV. DÓLARES"
                            nuevoMovimiento.abono = ""
                            nuevoMovimiento.consumo = monto
                        }else if tipo == "REVERSIONADELANTODEEFECTIVO"{
                            nuevoMovimiento.tipo = "ABONO"
                            nuevoMovimiento.concepto = "REVERSIÓN ADELANTO DE EFECTIVO"
                            nuevoMovimiento.abono = monto
                            nuevoMovimiento.consumo = ""
                        }else if tipo == "RECARGA"{
                            nuevoMovimiento.tipo = "DISPERSIÓN"
                            nuevoMovimiento.concepto = "DISPERSIÓN GO ONLINE"
                        }else if tipo == "ABONOASUCUENTA....GRACIAS"{
                            nuevoMovimiento.tipo = "DISPERSIÓN"
                            nuevoMovimiento.concepto = "DISPERSIÓN GO ONLINE"
                            nuevoMovimiento.abono = monto
                            nuevoMovimiento.consumo = ""
                        }else if tipo == "DEVOLUCIONDEFACTURA"{
                            nuevoMovimiento.abono = monto
                            nuevoMovimiento.consumo = ""
                        }
                        
                        self.tarjeta.movimientos.append(nuevoMovimiento)
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                }else{
                    let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup2") as! Popup2
                    popUp.mensaje = "No encontramos conexión a internet. Porfavor, verifica tu conexión."
                    popUp.buttonIcon2 = UIImage(named: "ios_btn_reintentar")
                    popUp.buttonIcon = UIImage(named: "ios_btn_cancelar")
                    popUp.icono = UIImage(named: "ios_icono_conexion")
                    popUp.delegate = self
                    self.presentViewController(popUp, animated: false, completion: nil)
                }
            })
            
        }else{
            let soap = SOAP(action: Services.ConsultaMovimientosCarnet, params: params, delegate: self)
            soap.callRequest()
        }
        
    }
    
    func loadDatos(){
    }
    
    // MARK: - SOAPDelegate
    
    func didRecieveXML(XML: XMLIndexer,action: Services) {
        if action == Services.ConsultaMovimientosCarnet || action == Services.ConsultaMovimientosMaster{
            if tarjeta.marca != "MASTERCARD"{
                for data in XML["soap:Envelope"]["soap:Body"]["consultaMovimientosCarnetResponse"]["consultaMovimientosCarnetResult"]["return"]["listTransaction"].all{
                    let nuevoMovimiento = MovimientosTarjeta()
                    let merchant = data["MERCHANT"].element?.text ?? ""
                    if merchant == "DEPOSITO"{
                        nuevoMovimiento.abono = data["AMOUNT_LC"].element?.text ?? ""
                        nuevoMovimiento.consumo = ""
                        nuevoMovimiento.tipo = "DISPERSION"
                    }else{
                        nuevoMovimiento.consumo = data["AMOUNT_LC"].element?.text ?? ""
                        nuevoMovimiento.abono = ""
                        nuevoMovimiento.tipo = "CONSUMO"
                    }
                    
                    let fecha = data["DATE"].element?.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) ?? ""
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyyMMdd"
                    let date = dateFormatter.dateFromString(fecha)
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                    nuevoMovimiento.fecha = dateFormatter.stringFromDate(date!)
                    
                    nuevoMovimiento.concepto = data["MERCHANT"].element?.text ?? ""
                    
                    if nuevoMovimiento.concepto == "MEMBRESIAS EASYCARD"{
                        nuevoMovimiento.concepto = "RECARGA TELCEL 01800"
                    }else if  nuevoMovimiento.concepto == ""{
                        nuevoMovimiento.concepto = "OPERACION SOLICITADA POR EL CLIENTE"
                    }
                    self.tarjeta.movimientos.append(nuevoMovimiento)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.movimientosObtenidos = true
                    self.tableView.reloadData()
                })
            }
        }else if action == Services.SaldoCarnet{
            
            if let bloqueada = XML["soap:Envelope"]["soap:Body"]["consultaSaldoCarnetResponse"]["consultaSaldoCarnetResult"]["return"]["RETURN_DESCRIPTION"].element?.text{
                if bloqueada == "CARD NUMBER  DOES NOT EXISTS."{
                    self.saldo = nil
                    self.bloqueada = true
                    self.movimientosObtenidos = false
                    if self.aparecio{
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tableView.reloadData()
                            let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup") as! Popup
                            popUp.mensaje = "No se puede consultar el saldo y movimientos, por favor comunícate al 01 (55) 4125 0320 opción 4 y 2 para validar el estatus de tu tarjeta."
                            popUp.buttonIcon = UIImage(named: "ios_btn_aceptar")
                            popUp.icono = UIImage(named: "ios_icono_alerta")
                            self.presentViewController(popUp, animated: false, completion: nil)
                        }
                        return
                    }else{
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tableView.reloadData()
                        })
                    }
                    return
                }
            }
            
            self.bloqueada = false
            if let saldo = XML["soap:Envelope"]["soap:Body"]["consultaSaldoCarnetResponse"]["consultaSaldoCarnetResult"]["return"]["AVAILABLE_FOR_PURCHASE_LIMIT"].element?.text{
                self.saldo = Double(saldo) ?? nil
                if self.saldo != nil{
                    dispatch_async(dispatch_get_main_queue(), {
                        self.loadMovimientos(self.mesActual)
                    })
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        self.movimientosObtenidos = true
                        self.tableView.reloadData()
                    })
                }
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    self.movimientosObtenidos = true
                    self.tableView.reloadData()
                })
            }
        }else if action == Services.SaldoMaster{
            
            if let bloqueada = XML["soap:Envelope"]["soap:Body"]["consultaSaldoMasterResponse"]["consultaSaldoMasterResult"]["Data"]["Result"].element?.text{
                if bloqueada == "Bloqueada"{
                    self.saldo = nil
                    self.bloqueada = true
                    self.movimientosObtenidos = false
                    if self.aparecio{
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tableView.reloadData()
                            let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup") as! Popup
                            popUp.mensaje = "No se puede consultar el saldo y movimientos, por favor comunícate al 01 (55) 4125 0320 opción 4 y 2 para validar el estatus de tu tarjeta."
                            popUp.buttonIcon = UIImage(named: "ios_btn_aceptar")
                            popUp.icono = UIImage(named: "ios_icono_alerta")
                            self.presentViewController(popUp, animated: false, completion: nil)
                        }
                        return
                    }else{
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tableView.reloadData()
                        })
                    }
                    return
                }
            }
            
            self.bloqueada = false
            if let saldo = XML["soap:Envelope"]["soap:Body"]["consultaSaldoMasterResponse"]["consultaSaldoMasterResult"]["Data"]["Result"].element?.text{
                self.saldo = Double(saldo) ?? nil
                if self.saldo != nil{
                    dispatch_async(dispatch_get_main_queue(), {
                        self.loadMovimientos(self.mesActual)
                    })
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        self.movimientosObtenidos = true
                        self.tableView.reloadData()
                    })
                }
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    self.movimientosObtenidos = true
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    func didFailReceivingXML(error: String) {
        dispatch_async(dispatch_get_main_queue()) {
            let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("Popup2") as! Popup2
            popUp.mensaje = "No encontramos conexión a internet. Porfavor, verifica tu conexión."
            popUp.buttonIcon2 = UIImage(named: "ios_btn_reintentar")
            popUp.buttonIcon = UIImage(named: "ios_btn_cancelar")
            popUp.icono = UIImage(named: "ios_icono_conexion")
            popUp.delegate = self
            self.presentViewController(popUp, animated: false, completion: nil)
        }
    }
    
}

extension TarjetaViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return (self.tarjeta.movimientos.count == 0) ? 1 : self.tarjeta.movimientos.count
        default: return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2{
            return self.view.frame.size.height * 0.1
        }
        return 0.000001
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return self.view.frame.size.height * 0.28
        case 1: return self.view.frame.size.height * 0.1
        case 2: return self.view.frame.size.height * 0.15
        default: return 0.0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2{
            return tableView.dequeueReusableCellWithIdentifier("HeaderInfo")
        }
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let celdaGrafico = tableView.dequeueReusableCellWithIdentifier("GraficaCell", forIndexPath: indexPath) as! GraficaCell
            celdaGrafico.webView.scrollView.bounces = false
            celdaGrafico.webView.backgroundColor = UIColor.clearColor()
            celdaGrafico.webView.opaque = false
            if self.movimientosObtenidos  && saldo != nil{
                self.loadWebView(celdaGrafico.webView, forIndex: indexPath.row)
            }
            return celdaGrafico
        case 1:
            
            if self.bloqueada{
                let cell = UITableViewCell()
                cell.selectionStyle = .None
                cell.backgroundColor = UIColor.clearColor()
                return cell
            }
            
            let celdaMes = tableView.dequeueReusableCellWithIdentifier("MesesCell", forIndexPath: indexPath) as! MesesCell
            if self.mesActual == 1{
                self.mesAnterior = 12
                self.mesAnterior2 = 11
                self.posibleAñoAnterior = self.añoActual - 1
                celdaMes.primerMes.text = self.stringForMonth(self.mesAnterior2)
                celdaMes.segundoMes.text = self.stringForMonth(self.mesAnterior)
                celdaMes.tercerMes.text = self.stringForMonth(self.mesActual)
            }else if self.mesActual == 2{
                self.mesAnterior = self.mesActual - 1
                self.mesAnterior2 = 12
                self.posibleAñoAnterior = self.añoActual - 1
                celdaMes.primerMes.text = self.stringForMonth(self.mesAnterior2)
                celdaMes.segundoMes.text = self.stringForMonth(self.mesAnterior)
                celdaMes.tercerMes.text = self.stringForMonth(self.mesActual)
            }else{
                self.mesAnterior = self.mesActual - 1
                self.mesAnterior2 = self.mesActual - 2
                celdaMes.primerMes.text = self.stringForMonth(self.mesAnterior2)
                celdaMes.segundoMes.text = self.stringForMonth(self.mesAnterior)
                celdaMes.tercerMes.text = self.stringForMonth(self.mesActual)
            }
            celdaMes.buttonPrimer.addTarget(self, action: #selector(self.obtnerAnteriorAnterior), forControlEvents: .TouchUpInside)
            celdaMes.buttonSegundo.addTarget(self, action: #selector(self.obtenerAnterior), forControlEvents: .TouchUpInside)
            celdaMes.buttonTercero.addTarget(self, action: #selector(self.obtenerActual), forControlEvents: .TouchUpInside)
            
            if mesActivo == 2{
                celdaMes.tercerMes.textColor = UIColor.whiteColor()
                celdaMes.segundoMes.textColor = UIColor(red: 50/255, green: 173/255, blue: 222/255, alpha: 1.0)
                celdaMes.primerMes.textColor = UIColor(red: 50/255, green: 173/255, blue: 222/255, alpha: 1.0)
            }else if mesActivo == 1{
                celdaMes.segundoMes.textColor = UIColor.whiteColor()
                celdaMes.tercerMes.textColor = UIColor(red: 50/255, green: 173/255, blue: 222/255, alpha: 1.0)
                celdaMes.primerMes.textColor = UIColor(red: 50/255, green: 173/255, blue: 222/255, alpha: 1.0)
            }else {
                celdaMes.primerMes.textColor = UIColor.whiteColor()
                celdaMes.tercerMes.textColor = UIColor(red: 50/255, green: 173/255, blue: 222/255, alpha: 1.0)
                celdaMes.segundoMes.textColor = UIColor(red: 50/255, green: 173/255, blue: 222/255, alpha: 1.0)
            }
            
            return celdaMes
        case 2:
            if self.tarjeta.movimientos.count == 0{
                if movimientosObtenidos{
                    return tableView.dequeueReusableCellWithIdentifier("IndicadorError", forIndexPath: indexPath)
                }else{
                    return tableView.dequeueReusableCellWithIdentifier("IndicadorSpinner", forIndexPath: indexPath)
                }
            }else{
                let formatter = NSNumberFormatter()
                formatter.numberStyle = .DecimalStyle
                formatter.groupingSeparator = ","
                
                let celdaInformacion = tableView.dequeueReusableCellWithIdentifier("InformacionTarjetaCell", forIndexPath: indexPath) as! InformacionTarjetaCell
                celdaInformacion.fecha.text = self.tarjeta.movimientos[indexPath.row].fecha
                
                let abono = (self.tarjeta.movimientos[indexPath.row].abono.isEmpty) ? 0 : Double(self.tarjeta.movimientos[indexPath.row].abono) ?? 0
                let consumo = (self.tarjeta.movimientos[indexPath.row].consumo.isEmpty) ? 0 : Double(self.tarjeta.movimientos[indexPath.row].consumo) ?? 0
                
                let formatAbono = NSNumber(double: abono)
                let formatConsumo = NSNumber(double: consumo)
                
                celdaInformacion.abono.text = (formatAbono == 0) ? "" : "$" + formatter.stringFromNumber(formatAbono)!
                celdaInformacion.consumo.text = (formatConsumo == 0) ? "" : "$" + formatter.stringFromNumber(formatConsumo)!
                celdaInformacion.concepto.text = self.tarjeta.movimientos[indexPath.row].concepto
                
                
                if (indexPath.row % 2) != 0{
                    celdaInformacion.backgroundColor = UIColor.whiteColor()
                    celdaInformacion.fecha.textColor = UIColor(red: 64/255, green: 124/255, blue: 201/255, alpha: 1.0)
                    celdaInformacion.consumo.textColor = UIColor(red: 64/255, green: 124/255, blue: 201/255, alpha: 1.0)
                    celdaInformacion.abono.textColor = UIColor(red: 64/255, green: 124/255, blue: 201/255, alpha: 1.0)
                    celdaInformacion.concepto.textColor = UIColor(red: 64/255, green: 124/255, blue: 201/255, alpha: 1.0)
                }else{
                    celdaInformacion.backgroundColor = UIColor(red: 64/255, green: 124/255, blue: 201/255, alpha: 1.0)
                    celdaInformacion.fecha.textColor = UIColor.whiteColor()
                    celdaInformacion.consumo.textColor = UIColor.whiteColor()
                    celdaInformacion.abono.textColor = UIColor.whiteColor()
                    celdaInformacion.concepto.textColor = UIColor.whiteColor()
                }
                
                return celdaInformacion
            }
        default: return UITableViewCell()
        }
    }
    
    func obtenerActual(){
        self.mesActivo = 2
        self.loadMovimientos(self.mesActual)
    }
    
    func obtenerAnterior(){
        self.mesActivo = 1
        self.loadMovimientos(self.mesAnterior)
    }
    
    func obtnerAnteriorAnterior(){
        self.mesActivo = 0
        self.loadMovimientos(self.mesAnterior2)
    }
    
    func didClick(){
        
    }
    
    func didTouchSecondButton(){
        if saldo != nil{
            self.loadMovimientos(self.mesActual)
        }else{
            self.obtenerSaldo()
        }
    }
    
}
