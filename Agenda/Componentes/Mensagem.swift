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

}

extension Mensagem: MFMessageComposeViewControllerDelegate {
    
    // MARK: - Metodos
    func configuraSMS(_ aluno: Aluno) -> MFMessageComposeViewController? {
        if MFMessageComposeViewController.canSendText() {
            let componenteMensagem = MFMessageComposeViewController()
            guard let numeroDoAluno = aluno.telefone else {return componenteMensagem}
            componenteMensagem.recipients = [numeroDoAluno]
            componenteMensagem.messageComposeDelegate = self

            
            return componenteMensagem
        } else {
            return nil
        }
    }
    
    // MARK: - MessageComposeDelegate
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
