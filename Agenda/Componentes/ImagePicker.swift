//
//  ImagePicker.swift
//  Agenda
//
//  Created by Mauro Augusto Diniz on 11/03/19.
//  Copyright © 2019 Alura. All rights reserved.
//

import UIKit

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
}
