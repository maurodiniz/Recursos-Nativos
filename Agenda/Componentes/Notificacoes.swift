//
//  Notificacoes.swift
//  Agenda
//
//  Created by Mauro Augusto Diniz on 17/06/19.
//  Copyright © 2019 Alura. All rights reserved.
//

import UIKit

class Notificacoes: NSObject {

    func exibeNotificacaoDeMediaDosAlunos(_ dicionarioDeMedia: Dictionary<
        String, Any>) -> UIAlertController? {
        
        // criando o alerta que será exibido com a media dos alunos da lista
        if let media = dicionarioDeMedia["media"] as? String {
            let alerta = UIAlertController(title: "Atenção", message: "A média geral dos alunos é: \(media)", preferredStyle: .alert)
            
            // botão para fechar o alerta
            let botao = UIAlertAction(title: "OK", style: .default, handler: nil)
            alerta.addAction(botao)
            
            return alerta
        }
        
        return nil
        }
}
