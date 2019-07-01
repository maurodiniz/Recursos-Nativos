//
//  AlunoAPI.swift
//  Agenda
//
//  Created by Mauro Augusto Diniz on 21/06/19.
//  Copyright © 2019 Alura. All rights reserved.
//

import UIKit
import Alamofire


// classe responsavel pelas requisições http na hora de salvar os alunos remotamente
class AlunoAPI: NSObject {
    
    // MARK: - GET
    // criando closure para que esse metodo só retorne algo depois que o servidor processar a requisição
    func recuperaAlunos(completion:@escaping() -> Void){
        Alamofire.request("http://localhost:8080/api/aluno", method:.get).responseJSON { (response) in
            switch response.result {
                case .success:
                    if let resposta = response.result.value as? Dictionary<String, Any> {
                        guard let listaDeAlunos = resposta["alunos"] as? Array<Dictionary<String, Any>> else {return}
                        
                        for dicionarioDeAluno in listaDeAlunos {
                            AlunoDAO().salvaAluno(dicionarioDeAluno: dicionarioDeAluno)
                        }
                        
                        completion()
                    }
                    break
                case .failure:
                    print(response.error!)
                    completion()
                    break
            }
        }
    }
    
    // MARK: - PUT
    func salvaAlunosNoServidor(parametros: Array<Dictionary<String, String>>) {
        guard let url = URL(string: "http://localhost:8080/api/aluno/lista") else { return }
        
        var requisicao  = URLRequest(url: url)
        requisicao.httpMethod = "PUT"
        
        // pegando os parametros recebidos e transormando em tipo Data para wue seja aceito no requisicao.httpbody
        let json = try! JSONSerialization.data(withJSONObject: parametros, options: [])
        requisicao.httpBody = json
        
        // indicando para a requisicao através do header que o que estou enviando está no formato json
        requisicao.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // fazendo a request usando a requisicao criada + Alamofire
        Alamofire.request(requisicao)
    }
    
    // MARK: - DELETE
    func deletaAluno(id: String) {
        Alamofire.request("http://localhost:8080/api/aluno/\(id)", method: .delete).responseJSON { (resposta) in
            switch resposta.result {
                case .failure:
                    print(resposta.result.error!)
                    break
                default: break
            } 
        }
    }
    
}