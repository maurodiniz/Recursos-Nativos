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
        // se não existir um aluno, significa que é novo item. Se existir, é edição
        
        let aluno = Aluno(context: contexto)
        
        aluno.nome = dicionarioDeAluno["nome"] as? String
        aluno.endereco = dicionarioDeAluno["endereco"] as? String
        aluno.telefone = dicionarioDeAluno["telefone"] as? String
        aluno.site = dicionarioDeAluno["site"] as? String
        
        guard let nota = dicionarioDeAluno["nota"] else { return }
        if (nota is String) {
            aluno.nota = (dicionarioDeAluno["nota"] as! NSString).doubleValue
        } else {
            let conversaoDeNota = String(describing: nota)
            aluno.nota = (conversaoDeNota as NSString).doubleValue
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
}
