//
//  Firebase.swift
//  Agenda
//
//  Created by Mauro Augusto Diniz on 26/08/19.
//  Copyright © 2019 Alura. All rights reserved.
//

import UIKit
import Alamofire
import FirebaseMessaging

// Classe responsavel por gerar a requisição ao servidor da Alura
class Firebase: NSObject {
    
    enum statusDoAluno:Int {
        case ativo
        case inativo
    }

    // Tentando realizar a chamada ao seridor através do metodo request do AlamoFire
    func enviaTokenParaServidor(token: String) {
        
        // recuperando o endereço de IP armazenado no info.plist para que eu possa acessar o servidor da Alura do iphone
        guard let urlPadrao = Configuracao().getUrlPadrao() else { return }
        
        Alamofire.request("\(urlPadrao)api/firebase/dispositivo", method: .post, headers:["token":token]).responseData
    }
    
    func serializaMensagem(mensagem: MessagingRemoteMessage) {
        // recuperando a mensagem do firebase na chave ["alunoSync"]
        guard let respostaDoFirebase = mensagem.appData["alunoSync"] as? String else { return }
        
        // transformando em tipo data para que possa ler na JSONSerialization.jsonObject
        guard let data = respostaDoFirebase.data(using: .utf8) else { return }
        
        do{
            // transformado o tipo 'Data?' em um Dictionary<String,Any>
            guard let mensagem = try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any> else { return }
            
            guard let listaDeAlunos = mensagem["alunos"] as? Array<Dictionary<String, Any>> else { return }
            
            // enviando a lista recuperada do servidor para sincronizar com a que tem no telefone
            sincronizaAlunos(alunos: listaDeAlunos)
            
            // usando a classe nativa NotificationCenter para notificar o HomeTableViewController quando um novo aluno for cadastrado e ele precisa atualizar a tela
            NotificationCenter.default.post(name: NSNotification.Name("atualizaAlunos"), object: nil)
        } catch {
            print(error.localizedDescription)
        }
        
        
        
    }
    
    func sincronizaAlunos(alunos: Array<Dictionary<String, Any>>) {
        for aluno in alunos {
            
            guard let status = aluno["desativado"] as? Int else {return}
            if status == statusDoAluno.ativo.rawValue {
                AlunoDAO().salvaAluno(dicionarioDeAluno: aluno)
            } else {
                // recuperando o id do aluno que o for está percorrendo
                guard let idDoAluno = aluno["id"] as? String else {return}
                // chamando a classe AlunoDAO().recuperaAlunos e pedindo para filtrar com base no id recuperado acima, retornando o primeiro resultado
                guard let aluno = AlunoDAO().recuperaAlunos().filter({ $0.id == UUID(uuidString: idDoAluno) }).first else {return}
                
                AlunoDAO().deletaAluno(aluno: aluno)
            }
            
            
        }
    }
    
}
