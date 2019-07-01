//
//  Filtro.swift
//  Agenda
//
//  Created by Mauro Augusto Diniz on 01/07/19.
//  Copyright © 2019 Alura. All rights reserved.
//

import UIKit

class Filtro: NSObject {

    func filtraAlunos(_ listaDeAlunos: Array<Aluno>, filtro: String) -> Array<Aluno> {
        let AlunosEncontrados = listaDeAlunos.filter { (aluno) -> Bool in
            if let nome = aluno.nome {
                return nome.contains(filtro)
            }
            return false
        }
        
        return AlunosEncontrados
    }
}
