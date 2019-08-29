//
//  HomeTableViewController.swift
//  Agenda
//
//  Created by Ândriu Coelho on 24/11/17.
//  Copyright © 2017 Alura. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    //MARK: - Variáveis
    
    let searchController = UISearchController(searchResultsController: nil)
    var alunoViewController: AlunoViewController?
    var alunos:Array<Aluno> = []
    
    // criando a variavel pullToRefresh
    lazy var pullToRefresh: UIRefreshControl = {
        let pullToRefresh = UIRefreshControl()
        //adicionando ação ao pullToRefresh
        pullToRefresh.addTarget(self, action: #selector(recarregaAlunos(_:)), for: UIControlEvents.valueChanged)
        
        return pullToRefresh
    }()
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        recuperaTodosAlunos()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configuraSearch()
        tableView.addSubview(pullToRefresh)
        
        NotificationCenter.default.addObserver(self, selector: #selector(atualizaAlunos), name: NSNotification.Name(rawValue: "atualizaAlunos"), object: nil)
    }
    
    // MARK: - Métodos
    
    @objc func recarregaAlunos(_ refreshControl: UIRefreshControl){
        guard let ultimaVersao = AlunoUserDefaults().recuperaUltimaVersao() else {return}
        if ultimaVersao == nil {
        // se a ultimaVersao for igual nil significa que o app não fez nenhuma requisição ao servidor e devemos preencher a lista com todos alunos
            recuperaTodosAlunos()
        } else {
            // todo: recuperar os ultimos alunos
            Repositorio().recuperaUltimosAlunos(ultimaVersao) {
                <#code#>
            }
        }
        
        refreshControl.endRefreshing()
    }
    
    // metodo chamado pelo NotificationCenter quando uma notificação com o rawValue = "atualizaAlunos" for disparada pela classe Firebase
    @objc func atualizaAlunos(){
        recuperaTodosAlunos()
    }
    
    func recuperaTodosAlunos(){
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
            
            guard let navigation = navigationController else {return}
            let menu = MenuDeOpcoes().configuraMenuDeOpcoesDoAluno(navigation: navigation, alunoSelecionado: alunoSelecionado)
            
            present(menu, animated: true, completion: nil)
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
                        // recuperando o aluno que está selecionado no momento para que eu possa extrair o id lá no Repositorio().deletaAluno()
                        let alunoSelecionado = self.alunos[indexPath.row]
                        Repositorio().deletaAluno(aluno: alunoSelecionado)
                        
                        // excluindo o aluno da lista e apagando a celula que ele estava
                        self.alunos.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
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
// delegate do searchbar para que eu possa buscar os alunos na lista
extension HomeTableViewController: UISearchBarDelegate {
    // ação quando o usuario clicar no botão de search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let texto = searchBar.text {
            alunos = Filtro().filtraAlunos(alunos, filtro: texto)
        }
        tableView.reloadData()
    }
    
    // ação quando o usuario clicar no botão de cancelar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        alunos = AlunoDAO().recuperaAlunos()
        tableView.reloadData()
    }
}
