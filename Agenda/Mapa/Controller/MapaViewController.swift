//
//  MapaViewController.swift
//  Agenda
//
//  Created by Mauro Augusto Diniz on 12/06/19.
//  Copyright © 2019 Alura. All rights reserved.
//

import UIKit
import MapKit // classe usada para criar pinos

class MapaViewController: UIViewController {
    
    // MARK: - Variavel
    var aluno : Aluno?
    
    // MARK: - IBOutlets
    @IBOutlet weak var mapa: MKMapView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = getTitulo()
        localizacaoInicial()
        localizarAluno()
    }
    
    // MARK: - Métodos
    func getTitulo() -> String {
        return "Localizar Alunos"
    }
    
    // setando uma localização inicial padrão para ser exibido no mapa
    func localizacaoInicial() {
        Localizacao().ConverteEnderecoEmCoordenadas(" Caelum - São Paulo") { (localizacaoEncontrada) in
            // criando um pino
            let pino = self.configuraPino(titulo: "Caelum", localizacao: localizacaoEncontrada)
            
            // criando uma região onde o pino será exibido
            let regiao = MKCoordinateRegionMakeWithDistance(pino.coordinate, 5000, 5000)
            // setando a região no mapa
            self.mapa.setRegion(regiao, animated: true)
            // adicionando o pino no mapa
            self.mapa.addAnnotation(pino)
            
        }
    }
 
    func configuraPino(titulo:String, localizacao: CLPlacemark) -> MKPointAnnotation {
        let pino = MKPointAnnotation()
        
        pino.title = titulo
        pino.coordinate = localizacao.location!.coordinate
        
        return pino
    }
    
    func localizarAluno() {
        if let aluno = aluno {
            Localizacao().ConverteEnderecoEmCoordenadas(aluno.endereco!) { (localizacaoEncontrada) in
                let pino = self.configuraPino(titulo: aluno.nome!, localizacao: localizacaoEncontrada)
                
                self.mapa.addAnnotation(pino)
            }
        }
        
    }

}
