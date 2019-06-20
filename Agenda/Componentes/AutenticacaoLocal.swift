//
//  AutenticacaoLocal.swift
//  Agenda
//
//  Created by Mauro Augusto Diniz on 17/06/19.
//  Copyright © 2019 Alura. All rights reserved.
//

import UIKit
import LocalAuthentication // classe responsavel por trabalhar com autenticações no iOS

class AutenticacaoLocal: NSObject {

    // criando closure para que eu consiga acessar a var 'resposta' no homeTableViewController na hora de excluir um aluno da lista
    func autorizaUsuario(completion: @escaping(_ autenticado: Bool) -> Void) {
        
        var error: NSError?
        let contexto = LAContext()
        
        // verificando a disponibilidade do recurso
        if contexto.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            contexto.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "É necessario autenticação para apagar um aluno") { (resposta, error) in
                
                completion(resposta)
            }
        }
    }
    
}
