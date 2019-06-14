//
//  Localizacao.swift
//  Agenda
//
//  Created by Mauro Augusto Diniz on 12/06/19.
//  Copyright © 2019 Alura. All rights reserved.
//

import UIKit
import CoreLocation

class Localizacao: NSObject {

    func ConverteEnderecoEmCoordenadas(_ endereco: String, local:@escaping (_ local: CLPlacemark) -> Void) {
        // para conseguirmos converter um local em coordenadas temos que usar a classe CLGeoCoder, que faz parte do CoreLocation
        let conversor = CLGeocoder()
        conversor.geocodeAddressString(endereco) { (listaDeLocalizacoes, error) in
            if let localizacao = listaDeLocalizacoes?.first {
                local(localizacao)
            }
        }
        
    }
}
