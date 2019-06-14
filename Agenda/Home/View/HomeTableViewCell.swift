//
//  HomeTableViewCell.swift
//  Agenda
//
//  Created by Ândriu Coelho on 24/11/17.
//  Copyright © 2017 Alura. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var imageAluno: UIImageView!
    @IBOutlet weak var labelNomeDoAluno: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configuraCelula(_ aluno: Aluno){
        
        imageAluno.layer.cornerRadius = imageAluno.frame.width/2
        imageAluno.layer.masksToBounds = true
        
        labelNomeDoAluno.text = aluno.nome
        
        // convertendo o aluno.foto de NSObject para UIImage
        if let imagemDoAluno = aluno.foto as? UIImage {
            imageAluno.image = imagemDoAluno
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
