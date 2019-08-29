//
//  AlunoUserDefaults.swift
//  Agenda
//
//  Created by Mauro Augusto Diniz on 29/08/19.
//  Copyright © 2019 Alura. All rights reserved.
//

import UIKit

// classe usada para salvar a data/hora que será usada no versionamento da lista de alunos
class AlunoUserDefaults: NSObject {
    
    let preferencias = UserDefaults.standard
    
    func salvaVersao(_ json:[String:Any]) {
        guard let versao = json["momentoDaUltimaModificacao"] as? String else { return }
        
        preferencias.set(versao, forKey: "ultima-versao")
    }
    
    func recuperaUltimaVersao() -> String? {
        let versao = preferencias.object(forKey: "ultima-versao") as? String
        
        return versao
    }
}
