//
//  CalculaMediaAPI.swift
//  Agenda
//
//  Created by Mauro Augusto Diniz on 13/06/19.
//  Copyright © 2019 Alura. All rights reserved.
//

import UIKit

class CalculaMediaAPI: NSObject {

    func calculaMediaGeralDosAlunos(){
        // para acessar o servidor é necessario saber o endereço em que vamos mandar as informações dos alunos
        guard let url = URL(string: "https://www.caelum.com.br/mobile") else {return}
        
        var listaDeAlunos: Array<Dictionary<String, Any>> = []
        var json: Dictionary<String, Any> = [:]
        
        let dicionarioDeAlunos = [
            "id": "1",
            "nome": "Mauro",
            "endereco": "rua 7, Sorocaba",
            "telefone": "+5515991775256",
            "site": "www.alura.com.br",
            "nota": "10",
        ]
        listaDeAlunos.append(dicionarioDeAlunos as [String: Any])
        
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
                        let dicionario = try JSONSerialization.jsonObject(with: data!, options: [])
                        print(dicionario)
                    }catch{
                        print(error.localizedDescription)
                    }
                }
            }
            task.resume()
        } catch {
            print(error.localizedDescription)
        }
        
    }
}
