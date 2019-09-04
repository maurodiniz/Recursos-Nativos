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
                        self.serializaAlunos(resposta)
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
    func salvaAlunosNoServidor(parametros: Array<Dictionary<String, Any>>, completion:@escaping(_ salvo: Bool) -> Void) {
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
        Alamofire.request(requisicao).responseData { (resposta) in
            if resposta.error == nil{
                completion(true)
            } 
        }
    }
    
    // MARK: - DELETE
    func deletaAluno(id: String, completion:@escaping(_ apagado: Bool) -> Void) {
        Alamofire.request("\(urlPadrao)api/aluno/\(id)", method: .delete).responseJSON { (resposta) in
            switch resposta.result {
                case .success:
                    completion(true)
                    break
                case .failure:
                    completion(false)
                    print(resposta.result.error!)
                    break
            } 
        }
    }
    
    // metodo criado para adicionar a data da ultima versão da lista de alunos 
    func recuperaUltimosAlunos(_ versao: String, completion:@escaping() -> Void) {
        Alamofire.request("\(urlPadrao)api/aluno/diff", method: .get, headers:["datahora":versao]).responseJSON { (response) in
            switch response.result {
            case .success:
                print("ULTIMOS ALUNOS")
                if let resposta = response.result.value as? Dictionary<String,Any> {
                    self.serializaAlunos(resposta)
                }
                completion()
                break
            case .failure:
                print("FALHA")
                break
            }
        }
    }
    
    // MARK: - Serialização
    func serializaAlunos(_ resposta: Dictionary<String,Any>){
        guard let listaDeAlunos = resposta["alunos"] as? Array<Dictionary<String, Any>> else {return}
        
        for dicionarioDeAluno in listaDeAlunos {
            guard let status = dicionarioDeAluno["desativado"] as? Bool else {return}
            // se o status for 'true'devo excluir do device, se for 'false' devo salvar
            if status {
                guard let idDoAluno = dicionarioDeAluno["id"] as? String else {return}
                guard let UUIDAluno = UUID(uuidString: idDoAluno) else {return}
                // validando se existe algum aluno com o UUId igual do recuperado acima
                if let aluno = AlunoDAO().recuperaAlunos().filter({$0.id == UUIDAluno}).first {
                    AlunoDAO().deletaAluno(aluno: aluno)
                } else {
                    AlunoDAO().salvaAluno(dicionarioDeAluno: dicionarioDeAluno)
                }
            }
            
        }
        // chamando a classe AlunoUserDefaults para salvar a data/hora que essa requisição está sendo feita
        AlunoUserDefaults().salvaVersao(resposta)
    }
    
}
