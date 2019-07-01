//
//  Mensagem.swift
//  Agenda
//
//  Created by Mauro Augusto Diniz on 10/06/19.
//  Copyright © 2019 Alura. All rights reserved.
//

import UIKit
import MessageUI // responsável pelo envio de sms

class Mensagem: NSObject {
    
    var delegate: MFMessageComposeViewControllerDelegate?
    
    func setaDelegate() -> MFMessageComposeViewControllerDelegate? {
        delegate = self
        
        return delegate
    }

}

extension Mensagem: MFMessageComposeViewControllerDelegate {
    // MARK: - Metodos
    func enviaSMS(_ aluno: Aluno, controller: UIViewController) {
        if MFMessageComposeViewController.canSendText() {
            let componenteMensagem = MFMessageComposeViewController()
            guard let numeroDoAluno = aluno.telefone else {return}
            componenteMensagem.recipients = [numeroDoAluno]
            
            guard let delegate = setaDelegate() else {return}
            componenteMensagem.messageComposeDelegate = delegate
            controller.present(componenteMensagem, animated: true, completion: nil)
        }
    }
    
    // MARK: - MessageComposeDelegate
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
