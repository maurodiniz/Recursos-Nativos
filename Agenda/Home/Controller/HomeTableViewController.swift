//
//  HomeTableViewController.swift
//  Agenda
//
//  Created by Ândriu Coelho on 24/11/17.
//  Copyright © 2017 Alura. All rights reserved.
//

import UIKit
import CoreData
import SafariServices

class HomeTableViewController: UITableViewController {
    
    //MARK: - Variáveis
    
    // buscando o contexto que já existe no appDelegate
    var contexto: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    var alunoViewController: AlunoViewController?
    
    
    var mensagem = Mensagem()
    var alunos:Array<Aluno> = []
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        recuperaAlunos()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configuraSearch()
    }
    
    // MARK: - Métodos
    
    func recuperaAlunos(){
        Repositorio().recuperaAlunos { (listaDeAlunos) in
            self.alunos = listaDeAlunos
            self.tableView.reloadData()
        }
    }
    
    func configuraSearch() {
        self.searchController.searchBar.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.navigationItem.searchController = searchController
    }
    
    @objc func abrirActionSheet(_ longPress: UILongPressGestureRecognizer){
        if longPress.state == .began {
            // acessando o Aluno em que o usuario fez o longPress
            let alunoSelecionado = alunos[(longPress.view?.tag)!]
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
                    case .abrirPaginaWeb:
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
                        self.present(safariViewController, animated: true, completion: nil)
                        
                        break
                }
                
            }
            self.present(menu, animated: true, completion: nil)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alunos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celula-aluno", for: indexPath) as! HomeTableViewCell
        
        // cada linha da lista tera uma tag diferente, usada para identificar os registros individualmente
        cell.tag = indexPath.row
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(abrirActionSheet(_:)))
        
        let aluno = alunos[indexPath.row]
        
        cell.configuraCelula(aluno)
        cell.addGestureRecognizer(longPress)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            AutenticacaoLocal().autorizaUsuario { (autenticado) in
                if autenticado {
                    DispatchQueue.main.async {
                       /* guard let alunoSelecionado = self.gerenciadorDeResultados?.fetchedObjects![indexPath.row] else {return}
                        
                        self.contexto.delete(alunoSelecionado)
                        
                        do {
                            try self.contexto.save()
                        }catch {
                            print(error.localizedDescription)
                        } */
                    }
                    
                    
                }
            }
            
            
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // acessando a celula que o usuario clicou e enviando o conteudo para a variavel aluno do AlunoViewController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alunoSelecionado = alunos[indexPath.row]
        alunoViewController?.aluno = alunoSelecionado
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "editar" {
            alunoViewController = segue.destination as? AlunoViewController
        }
        
    }

    @IBAction func buttonCalculaMedia(_ sender: UIBarButtonItem) {
        
        // chamando a função de calculo de media passando o dicionario retornado da closure
        CalculaMediaAPI().calculaMediaGeralDosAlunos(alunos: alunos, sucesso: { (dicionario) in
            if let alerta = Notificacoes().exibeNotificacaoDeMediaDosAlunos(dicionario) {
                self.present(alerta, animated: true, completion: nil)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    @IBAction func buttonLocalizacaoGeral(_ sender: UIBarButtonItem) {
        // recuperando o viewController que queremos utilizar
        let mapa = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mapa") as! MapaViewController
        
        navigationController?.pushViewController(mapa, animated: true)
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

// delegate do searchbar para que eu possa buscar os alunos na lista
extension HomeTableViewController: UISearchBarDelegate {
    // ação quando o usuario clicar no botão de search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    // ação quando o usuario clicar no botão de cancelar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
