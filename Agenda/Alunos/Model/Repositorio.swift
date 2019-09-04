//
//  Repositorio.swift
//  Agenda
//
//  Created by Mauro Augusto Diniz on 24/06/19.
//  Copyright © 2019 Alura. All rights reserved.
//

import UIKit

class Repositorio: NSObject {

    func salvaAluno(aluno: Dictionary<String, Any>) {
        // salvando o aluno localmente no device
        AlunoDAO().salvaAluno(dicionarioDeAluno: aluno)
        
        // salvando o aluno no servidor
        AlunoAPI().salvaAlunosNoServidor(parametros: [aluno]) { (salvo) in
            if salvo {
                self.atualizaAlunoSincronizado(aluno)
            }
        }
    }
    
    func recuperaAlunos(completion:@escaping(_ listaDeAlunos:Array<Aluno>) -> Void) {
        var alunos = AlunoDAO().recuperaAlunos().filter({$0.desativado == false})
        
        if alunos.count == 0 {
            AlunoAPI().recuperaAlunos {
                alunos = AlunoDAO().recuperaAlunos()
                completion(alunos)
            }
        } else {
            completion(alunos)
        }
    }
    
    func recuperaUltimosAlunos(_ versao:String, completion:@escaping() -> Void) {
        AlunoAPI().recuperaUltimosAlunos(versao) {
            // ao final da execução do completion do AlunoAPI().recuperaUltimosAlunos ele chamará esse cmpletion que retornará a resposta ao HomeTableviewController
            completion()
        }
    }
    
    func deletaAluno(aluno: Aluno) {
        aluno.desativado = true
        AlunoDAO().atualizaContexto()
        
        // extraindo o id recebido por parametro
        guard let idAluno = aluno.id else { return }
        
        // apagando do servidor
        AlunoAPI().deletaAluno(id: String(describing: idAluno).lowercased()) { (apagado) in
            if apagado{
                // apagando local
                AlunoDAO().deletaAluno(aluno: aluno)
            }
        }
        
    }
    
    func sincronizaAlunos() {
        enviaAlunosNaoSincronizados()
        sincronizaAlunosdeletados()
    }
    
    func enviaAlunosNaoSincronizados(){
        // recuperando a lista local de alunos, mas apenas os que estão com o atributo 'sincronizado' como false
        let alunos = AlunoDAO().recuperaAlunos().filter({$0.sincronizado == false})
        let listaDeParametros = criaJsonAluno(alunos)
        
        print("ALUNOS")
        print(listaDeParametros)
        
        AlunoAPI().salvaAlunosNoServidor(parametros: listaDeParametros) { (salvo) in
            // setar o atributo 'sincronizado' para verdadeiro
            for aluno in listaDeParametros {
                self.atualizaAlunoSincronizado(aluno)
            }
        }
    }
    
    // enviando para o servidor quais alunos foram deletados enquanto a conxaao estava ofline
    func sincronizaAlunosdeletados(){
        let alunos = AlunoDAO().recuperaAlunos().filter({$0.desativado == true})
        for aluno in alunos {
            deletaAluno(aluno: aluno)
        }
    }
    
    func criaJsonAluno(_ alunos: Array<Aluno>) -> Array<Dictionary<String,Any>>{
        var listaDeParametros:Array<Dictionary<String,String>> = []
        
        for aluno in alunos {
            guard let id = aluno.id else {return []}
            
            let parametros: Dictionary<String,String> = [
                "id" : String(describing: id).lowercased(),
                "nome" : aluno.nome ?? "",
                "endereco" : aluno.endereco ?? "",
                "telefone" : aluno.telefone ?? "",
                "nota" : "\(aluno.nota)"
            ]
            listaDeParametros.append(parametros)
        }
        return listaDeParametros
    }
    
    func atualizaAlunoSincronizado(_ aluno: Dictionary<String,Any>) {
        var dicionario = aluno
        
        //mudar o atributo sincronizado para 'true'
        dicionario["Sincronizado"] = true
        // salvando novamente o aluno com um novo atributo para o campo 'sincronizado'
        AlunoDAO().salvaAluno(dicionarioDeAluno: dicionario)
    }
}
