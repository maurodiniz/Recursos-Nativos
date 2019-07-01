//
//  Repositorio.swift
//  Agenda
//
//  Created by Mauro Augusto Diniz on 24/06/19.
//  Copyright © 2019 Alura. All rights reserved.
//

import UIKit

class Repositorio: NSObject {

    func salvaAluno(aluno: Dictionary<String, String>) {
        AlunoAPI().salvaAlunosNoServidor(parametros: [aluno])
        AlunoDAO().salvaAluno(dicionarioDeAluno: aluno)
    }
    
    func recuperaAlunos(completion:@escaping(_ listaDeAlunos:Array<Aluno>) -> Void) {
        var alunos = AlunoDAO().recuperaAlunos()
        
        if alunos.count == 0 {
            AlunoAPI().recuperaAlunos {
                alunos = AlunoDAO().recuperaAlunos()
                completion(alunos)
            }
        } else {
            completion(alunos)
        }
    }
    
    func deletaAluno(aluno: Aluno) {
        // extraindo o id recebido por parametro
        guard let idAluno = aluno.id else { return }
        
        // apagando do servidor
        AlunoAPI().deletaAluno(id: String(describing: idAluno).lowercased())
        // apagando local
        AlunoDAO().deletaAluno(aluno: aluno)
    }
    
    func sincronizaAlunos() {
        // recuperando a lista local de alunos
        let alunos = AlunoDAO().recuperaAlunos()
        var listaDeParametros:Array<Dictionary<String,String>> = []
        
        for aluno in alunos {
            guard let id = aluno.id else {return}
            
            let parametros: Dictionary<String,String> = [
                "id" : String(describing: id).lowercased(),
                "nome" : aluno.nome ?? "",
                "endereco" : aluno.endereco ?? "",
                "telefone" : aluno.telefone ?? "",
                "nota" : "\(aluno.nota)"
            ]
            listaDeParametros.append(parametros)
        }
        
        AlunoAPI().salvaAlunosNoServidor(parametros: listaDeParametros)
    }
}
