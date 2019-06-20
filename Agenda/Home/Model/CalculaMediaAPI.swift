//
//  CalculaMediaAPI.swift
//  Agenda
//
//  Created by Mauro Augusto Diniz on 13/06/19.
//  Copyright © 2019 Alura. All rights reserved.
//

import UIKit

class CalculaMediaAPI: NSObject {

    // closure criada para retornar o dicionario de alunos para o viewController manipular
    func calculaMediaGeralDosAlunos(alunos: Array<Aluno>, sucesso:@escaping(_ dicionarioDeMedias: Dictionary<String, Any>) -> Void, falha:@escaping(_ erro: Error) -> Void ){
        // para acessar o servidor é necessario saber o endereço em que vamos mandar as informações dos alunos
        guard let url = URL(string: "https://www.caelum.com.br/mobile") else {return}
        
        var listaDeAlunos: Array<Dictionary<String, Any>> = []
        var json: Dictionary<String, Any> = [:]
        
        // laço para percorrer todos os alunos e extrair os dados
        for aluno in alunos {
            
            guard let nome = aluno.nome else {break}
            guard let endereco = aluno.endereco else {break}
            guard let telefone = aluno.telefone else {break}
            guard let site = aluno.site else {break}
            
            let dicionarioDeAlunos = [
                // objectID é gerado pelo próprio CoreData e refere ao id do registro que ele está percorrendo no momento.
                "id": "\(aluno.objectID)",
                "nome": "\(nome)",
                "endereco": endereco,
                "telefone": telefone,
                "site": site,
                "nota": String(aluno.nota),
            ]
            listaDeAlunos.append(dicionarioDeAlunos as [String: Any])
        }
        
        
        
        
        json = [
            "list": [
                ["aluno": listaDeAlunos]
            ]
        ]
        
        var requisicao = URLRequest(url: url)
        do {
            // o metodo httpBody recebe um objeto tipo Data, por isso uso JSONSerialization.data() para fazer a conversão
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            requisicao.httpBody = data
            
            // indicando qual a operação que a requisição irá fazer (GET: busca uma informação, POST: envia uma informação, PUT: atualiza, DELETE: apaga )
            requisicao.httpMethod = "POST"
            
            // especificando para o servidor o tipo de dado que estou enviando
            requisicao.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: requisicao) { (data, response, error) in
                if error == nil {
                    // transformando o Data em um dicionario
                    do{
                        let dicionario = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                        sucesso(dicionario)
                    }catch{
                        falha(error)
                    }
                }
            }
            task.resume()
        } catch {
            print(error.localizedDescription)
        }
        
    }
}
