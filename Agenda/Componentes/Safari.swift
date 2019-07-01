//
//  Safari.swift
//  Agenda
//
//  Created by Mauro Augusto Diniz on 01/07/19.
//  Copyright © 2019 Alura. All rights reserved.
//

import UIKit
import SafariServices

class Safari: NSObject {

    func abrePaginaWeb(_ alunoSelecionado: Aluno, controller: UIViewController){
        // recuperando o site cadastrado e validando se está formatado
        guard var urlDoAluno = alunoSelecionado.site else {return}
        if !urlDoAluno.hasPrefix("https://") {
            urlDoAluno = String(format: "https://%@", urlDoAluno)
        }
        
        // transformando a string formatada acima em URL
        guard let url = URL(string: urlDoAluno) else {return}
        
        // usando o UIApplication eu consigo abrir a pagina no proprio navegador, porém foi usado o safariservices que abre a pagina dentro do proprio app e não permite a alteração de url
        //UIApplication.shared.open(url, options: [:], completionHandler: nil)
        let safariViewController = SFSafariViewController(url: url)
        controller.present(safariViewController, animated: true, completion: nil)

    }
}
