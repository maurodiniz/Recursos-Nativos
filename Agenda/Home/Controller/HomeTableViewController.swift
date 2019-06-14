//
//  HomeTableViewController.swift
//  Agenda
//
//  Created by Ândriu Coelho on 24/11/17.
//  Copyright © 2017 Alura. All rights reserved.
//

import UIKit
import CoreData

class HomeTableViewController: UITableViewController, UISearchBarDelegate {
    
    //MARK: - Variáveis
    
    // busncando o contexto que já existe no appDelegate
    var contexto: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    var alunoViewController: AlunoViewController?
    
    // NSFetchedResultsController é responsavel por interagir com o core data para acessar os dados
    var gerenciadorDeResultados: NSFetchedResultsController<Aluno>?
    
    var mensagem = Mensagem()
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        recuperaAluno()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configuraSearch()
    }
    
    // MARK: - Métodos
    
    func configuraSearch() {
        self.searchController.searchBar.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.navigationItem.searchController = searchController
    }
    
    func recuperaAluno(){
        // criando o request
        let pesquisaAluno: NSFetchRequest<Aluno> = Aluno.fetchRequest()
        
        // criando o sort para ordenar por ordem alfabética
        let ordenaPorNome = NSSortDescriptor(key: "nome", ascending: true)
        
        pesquisaAluno.sortDescriptors = [ordenaPorNome]
        
        gerenciadorDeResultados = NSFetchedResultsController(fetchRequest: pesquisaAluno, managedObjectContext: contexto, sectionNameKeyPath: nil, cacheName: nil)
        gerenciadorDeResultados?.delegate = self
        
        do{
            try gerenciadorDeResultados?.performFetch()
        }catch {
            print(error.localizedDescription)
        }
    }
    
    @objc func abrirActionSheet(_ longPress: UILongPressGestureRecognizer){
        if longPress.state == .began {
            // acessando o Aluno em que o usuario fez o longPress
            guard let alunoSelecionado = gerenciadorDeResultados?.fetchedObjects?[(longPress.view?.tag)!] else {return}
            let menu = MenuDeOpcoes().configuraMenuDeOpcoesDoAluno { (opcao) in
                switch opcao {
                    case .sms:
                        if let componenteMensagem = self.mensagem.configuraSMS(alunoSelecionado) {
                            componenteMensagem.messageComposeDelegate = self.mensagem
                            self.present(componenteMensagem, animated: true, completion: nil)
                    }
                    break
                    case .ligacao:
                        guard let numeroDoAluno = alunoSelecionado.telefone else {return}
                        // através do UIAplication consigo acessar apps externos, como o telefone por exemplo
                        if let url = URL(string: "tel://\(numeroDoAluno)"), UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                        break
                    case .waze:
                        // verificando se o usuario tem waze e se podemos acessa-lo
                        if UIApplication.shared.canOpenURL(URL(string: "waze://")!) {
                            // recuperando o endereço do aluno
                            guard let enderecoDoAluno = alunoSelecionado.endereco else {return}
                            
                            
                            Localizacao().ConverteEnderecoEmCoordenadas(enderecoDoAluno, local: { (localizacaoEncontrada) in
                                // recuperando a latitude e longitude e convertendo em string
                                let latitude = String(describing: localizacaoEncontrada.location!.coordinate.latitude)
                                let longitude = String(describing: localizacaoEncontrada.location!.coordinate.longitude)
                                
                                // montando a url com a localização que será enviada para o waze
                                let url:String = "waze://?ll=\(latitude),\(longitude)&navigate=yes"
                                
                                UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
                            })
                        }
                        break
                    case .mapa:
                        // selecionando o viewController de mapas e chamando a tela
                        let mapa = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mapa") as! MapaViewController
                        mapa.aluno = alunoSelecionado
                        self.navigationController?.pushViewController(mapa, animated: true)
                        
                        break
                }
                
            }
            self.present(menu, animated: true, completion: nil)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let contadorDeAlunos = gerenciadorDeResultados?.fetchedObjects?.count else {return 0}
        
        return contadorDeAlunos
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celula-aluno", for: indexPath) as! HomeTableViewCell
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(abrirActionSheet(_:)))
        
        guard let aluno = gerenciadorDeResultados?.fetchedObjects![indexPath.row] else { return cell }
        
        cell.configuraCelula(aluno)
        cell.addGestureRecognizer(longPress)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let alunoSelecionado = gerenciadorDeResultados?.fetchedObjects![indexPath.row] else {return}
            
            contexto.delete(alunoSelecionado)
            
            do {
                try contexto.save()
            }catch {
                print(error.localizedDescription)
            }
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // acessando a celula que o usuario clicou e enviando o conteudo para a variavel aluno do AlunoViewController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let alunoSelecionado = gerenciadorDeResultados?.fetchedObjects![indexPath.row] else { return }
        alunoViewController?.aluno = alunoSelecionado
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "editar" {
            alunoViewController = segue.destination as? AlunoViewController
        }
        
    }

    @IBAction func buttonCalculaMedia(_ sender: UIBarButtonItem) {
        CalculaMediaAPI().calculaMediaGeralDosAlunos()
    }
    
    
}

// MARK: - Extensions
extension HomeTableViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            guard let indexPath = indexPath else {return}
            tableView.deleteRows(at: [indexPath], with: .fade)
            break
        default:
            tableView.reloadData()
        }
    }
}
