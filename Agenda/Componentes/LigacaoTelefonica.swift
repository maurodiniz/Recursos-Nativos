//
//  LigacaoTelefonica.swift
//  Agenda
//
//  Created by Mauro Augusto Diniz on 01/07/19.
//  Copyright © 2019 Alura. All rights reserved.
//

import UIKit

class LigacaoTelefonica: NSObject {

    func fazLigacao(_ alunoSelecionado: Aluno) {
        
        guard let numeroDoAluno = alunoSelecionado.telefone else {return}
        // através do UIAplication consigo acessar apps externos, como o telefone por exemplo
        if let url = URL(string: "tel://\(numeroDoAluno)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
