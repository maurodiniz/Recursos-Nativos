//
//  AlunoDAO.swift
//  Agenda
//
//  Created by Mauro Augusto Diniz on 24/06/19.
//  Copyright © 2019 Alura. All rights reserved.
//

import UIKit
import CoreData

// classe responsavel por toda persistencia de dados localmente
class AlunoDAO: NSObject {
    
    // busncando o contexto que já existe no appDelegate
    var contexto: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    // NSFetchedResultsController é responsavel por interagir com o core data para acessar os dados
    var gerenciadorDeResultados: NSFetchedResultsController<Aluno>?
    
    
    
    func recuperaAlunos() -> Array<Aluno>{
        // criando o request
        let pesquisaAluno: NSFetchRequest<Aluno> = Aluno.fetchRequest()
        
        // criando o sort para ordenar por ordem alfabética
        let ordenaPorNome = NSSortDescriptor(key: "nome", ascending: true)
        
        pesquisaAluno.sortDescriptors = [ordenaPorNome]
        
        gerenciadorDeResultados = NSFetchedResultsController(fetchRequest: pesquisaAluno, managedObjectContext: contexto, sectionNameKeyPath: nil, cacheName: nil)
        
        do{
            try gerenciadorDeResultados?.performFetch()
        }catch {
            print(error.localizedDescription)
        }
        guard let listaDeAlunos = gerenciadorDeResultados?.fetchedObjects else { return [] }
        
        return listaDeAlunos
    }

    func salvaAluno(dicionarioDeAluno: Dictionary<String,Any>){
        var aluno: NSManagedObject?
        guard let id = UUID(uuidString: dicionarioDeAluno["id"] as! String) else { return }
        // verificando se a lista de alunos tem algum com o mesmo id recuperado acima, se tiver quer dizer que é o mesmo e ele será editado, se não tiver quer dizer que irá criar um novo aluno
        let alunos = recuperaAlunos().filter { $0.id == id }
        if alunos.count > 0 {
            guard let alunoEncontrado = alunos.first else {return}
            aluno = alunoEncontrado
        } else {
            let entidade = NSEntityDescription.entity(forEntityName: "Aluno", in: contexto)
            aluno = NSManagedObject(entity: entidade!, insertInto: contexto)
        }
        
        // setando os valores
        aluno?.setValue(id, forKey: "id")
        aluno?.setValue(dicionarioDeAluno["nome"], forKey: "nome")
        aluno?.setValue(dicionarioDeAluno["endereco"], forKey: "endereco")
        aluno?.setValue(dicionarioDeAluno["telefone"], forKey: "telefone")
        aluno?.setValue(dicionarioDeAluno["site"], forKey: "site")
        aluno?.setValue(dicionarioDeAluno["sincronizado"] as? Bool, forKey: "sincronizado")
        
        guard let nota = dicionarioDeAluno["nota"] else { return }
        if (nota is String) {
            aluno?.setValue((dicionarioDeAluno["nota"] as! NSString).doubleValue, forKey: "nota")
        } else {
            let conversaoDeNota = String(describing: nota)
            aluno?.setValue((conversaoDeNota as NSString).doubleValue, forKey: "nota")
        }
        
        
        //aluno.foto = imageAluno.image
        
        atualizaContexto()
        
    }
    
    func atualizaContexto() {
        do {
            try contexto.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deletaAluno(aluno: Aluno) {
        contexto.delete(aluno)
        atualizaContexto()
    }
}
