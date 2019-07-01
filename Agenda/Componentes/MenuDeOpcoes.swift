//
//  MenuDeOpcoes.swift
//  Agenda
//
//  Created by Mauro Augusto Diniz on 06/06/19.
//  Copyright © 2019 Alura. All rights reserved.
//

import UIKit



class MenuDeOpcoes: NSObject {

    
    func configuraMenuDeOpcoesDoAluno(navigation: UINavigationController, alunoSelecionado: Aluno) -> UIAlertController {
        let menu = UIAlertController(title: "Atenção", message: "escolha uma das opções abaixo", preferredStyle: .actionSheet)
        
        let ligacao = UIAlertAction(title: "Ligar", style: .default) { (acao) in
            LigacaoTelefonica().fazLigacao(alunoSelecionado)
        }
        
        guard let viewController = navigation.viewControllers.last else { return menu }
        let sms = UIAlertAction(title: "Enviar SMS", style: .default) { (acao) in
            Mensagem().enviaSMS(alunoSelecionado, controller: viewController)
        }
        
        let waze = UIAlertAction(title: "Localizar no Waze", style: .default) { (acao) in
            Localizacao().localizaAlunoNoWaze(alunoSelecionado)
        }
        
        let mapa = UIAlertAction(title: "Localizar no mapa", style: .default) { (acao) in
            // selecionando o viewController de mapas e chamando a tela
            let mapa = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mapa") as! MapaViewController
            mapa.aluno = alunoSelecionado
            navigation.pushViewController(mapa, animated: true)
        }
        
        let abrirPaginaWeb = UIAlertAction(title: "Abrir Site", style: .default) { (acao) in
            Safari().abrePaginaWeb(alunoSelecionado, controller: viewController)
        }
        
        
        let cancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        menu.addAction(ligacao)
        menu.addAction(sms)
        menu.addAction(waze)
        menu.addAction(mapa)
        menu.addAction(abrirPaginaWeb)
        menu.addAction(cancelar)
        
        
        return menu
    }
}
