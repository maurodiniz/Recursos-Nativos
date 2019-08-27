//
//  Configuracao.swift
//  Agenda
//
//  Created by Mauro Augusto Diniz on 26/08/19.
//  Copyright © 2019 Alura. All rights reserved.
//

import UIKit

class Configuracao: NSObject {
    // Abstraindo o trecho que busca a URLpadrao do Info.plist para que eu possa usa-lo em diversas partes do projeto sem precisar copiar e colar a mesma parte do código. O retorno está como String Opcional pois os guardlets podem retornar nulo
    func getUrlPadrao() -> String? {
        guard let caminhoParaPlist = Bundle.main.path(forResource: "Info", ofType: "plist") else { return nil }
        guard let dicionario = NSDictionary(contentsOfFile: caminhoParaPlist) else {return nil}
        guard let urlPadrao = dicionario["URLpadrao"] as? String else { return nil }
        
        return urlPadrao
    }
}
