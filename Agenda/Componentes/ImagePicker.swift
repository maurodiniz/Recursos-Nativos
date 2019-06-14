//
//  ImagePicker.swift
//  Agenda
//
//  Created by Mauro Augusto Diniz on 11/03/19.
//  Copyright © 2019 Alura. All rights reserved.
//

import UIKit

enum MenuOpcoes {
    case camera
    case biblioteca
}

protocol imagePickerFotoSelecionada {
    func imagePickerFotoSelecionada(_ foto: UIImage)
}

// implamentando o protocolo UIImagePickerControllerDelegate para ter acesso aos métodos que controlam o image picker
class ImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Atributos
    var delegate: imagePickerFotoSelecionada?
    
    // MARK: - Métodos
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let foto = info[UIImagePickerControllerOriginalImage] as! UIImage
        delegate?.imagePickerFotoSelecionada(foto)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func menuDeOpcoes(completion: @escaping(_ opcao: MenuOpcoes) -> Void) -> UIAlertController {
        // criando um UIAlertController do tipo actionSheet para que apareça um menu de opções quando o usuario clicar na foto
        let menu = UIAlertController(title: "Atenção", message: "Escolha uma das opções abaixo", preferredStyle: .actionSheet)
        //opçoes do menu
        let camera = UIAlertAction(title: "tirar foto", style: .default) { (acao) in
            completion(.camera)
        }
        menu.addAction(camera)
        let biblioteca = UIAlertAction(title: "biblioteca", style: .default) { (acao) in
            completion(.biblioteca)
        }
        menu.addAction(biblioteca)
        let cancelar = UIAlertAction(title: "cancelar", style: .cancel, handler: nil)
        menu.addAction(cancelar)
        
        return menu
    }
}
