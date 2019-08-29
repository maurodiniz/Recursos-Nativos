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
    lazy var urlPadrao: String = {
        guard let urlPadrao = Configuracao().getUrlPadrao() else { return ""}
        return urlPadrao
    }()
    
    // MARK: - GET
    // criando closure para que esse metodo só retorne algo depois que o servidor processar a requisição
    func recuperaAlunos(completion:@escaping() -> Void){
        Alamofire.request("\(urlPadrao)api/aluno", method:.get).responseJSON { (response) in
            switch response.result {
                case .success:
                    if let resposta = response.result.value as? Dictionary<String, Any> {
                        guard let listaDeAlunos = resposta["alunos"] as? Array<Dictionary<String, Any>> else {return}
                        
                        for dicionarioDeAluno in listaDeAlunos {
                            AlunoDAO().salvaAluno(dicionarioDeAluno: dicionarioDeAluno)
                        }
                        // chamando a classe AlunoUserDefaults para salvar a data/hora que essa requisição está sendo feita
                        AlunoUserDefaults().salvaVersao(resposta)
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
        guard let urlPadrao = Configuracao().getUrlPadrao() else { return }
        guard let url = URL(string: "\(urlPadrao)api/aluno/lista") else { return }
        
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
        Alamofire.request("\(urlPadrao)api/aluno/\(id)", method: .delete).responseJSON { (resposta) in
            switch resposta.result {
                case .failure:
                    print(resposta.result.error!)
                    break
                default: break
            } 
        }
    }
    
    // metodo criado para adicionar a data da ultima versão da lista de alunos 
    func recuperaUltimosAlunos(_ versao: String, completion:@escaping() -> Void) {
        Alamofire.request("\(urlPadrao)api/aluno/diff", method: .get, headers:["datahora":versao]).responseJSON { (response) in
            switch response.result {
            case .success:
                print("ULTIMOS ALUNOS")
                break
            case .failure:
                print("FALHA")
                break
            }
        }
    }
    
}
