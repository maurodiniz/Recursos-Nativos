//
//  MenuDeOpcoes.swift
//  Agenda
//
//  Created by Mauro Augusto Diniz on 06/06/19.
//  Copyright © 2019 Alura. All rights reserved.
//

import UIKit

enum menuActionSheetAluno {
    case sms
    case ligacao
    case waze
    case mapa
}

class MenuDeOpcoes: NSObject {

    
    func configuraMenuDeOpcoesDoAluno(completion:@escaping(_ opcao: menuActionSheetAluno) -> Void ) -> UIAlertController {
        let menu = UIAlertController(title: "Atenção", message: "escolha uma das opções abaixo", preferredStyle: .actionSheet)
        
        let ligacao = UIAlertAction(title: "Ligar", style: .default) { (acao) in
            completion(.ligacao)
        }
        
        let sms = UIAlertAction(title: "Enviar SMS", style: .default) { (acao) in
            completion(.sms)
        }
        
        let waze = UIAlertAction(title: "Localizar no Waze", style: .default) { (acao) in
            completion(.waze)
        }
        
        let mapa = UIAlertAction(title: "Localizar no mapa", style: .default) { (acao) in
            completion(.mapa)
        }
        
        let cancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        menu.addAction(ligacao)
        menu.addAction(sms)
        menu.addAction(waze)
        menu.addAction(mapa)
        menu.addAction(cancelar)
        
        
        return menu
    }
}
