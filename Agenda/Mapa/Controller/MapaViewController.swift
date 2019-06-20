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
    lazy var localizacao = Localizacao()
    lazy var gerenciadorDeLocalizacao = CLLocationManager()
    
    // MARK: - IBOutlets
    @IBOutlet weak var mapa: MKMapView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = getTitulo()
        verificaAutorizacaoDoUsuario()
        localizacaoInicial()
        
        
        // definindo o delegate como localizacao pois foi lá que eu implementei o MKMapViewDelegate
        mapa.delegate = localizacao
        
        gerenciadorDeLocalizacao.delegate = self
    }
    
    // MARK: - Métodos
    func getTitulo() -> String {
        return "Localizar Alunos"
    }
    
    func verificaAutorizacaoDoUsuario() {
        // se tiver autorizado o uso de localização
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .authorizedWhenInUse: // se o usuario entrou na feature e já autorizou anteriormente
                    let botao = Localizacao().configuraBotaoLocalizacaoAtual(mapa: mapa)
                    mapa.addSubview(botao)
                    gerenciadorDeLocalizacao.startUpdatingLocation()
                    break
                case .notDetermined: // se a autorizacao não está determinada (normalamente cai aqui quando usado pela 1a vez)
                    gerenciadorDeLocalizacao.requestWhenInUseAuthorization()
                    break
                case .denied: // se autorização foi negada
                    break
                default:
                    break
            }
        }
    }
    
    // setando uma localização inicial padrão para ser exibido no mapa
    func localizacaoInicial() {
        Localizacao().ConverteEnderecoEmCoordenadas(" Caelum - São Paulo") { (localizacaoEncontrada) in
            // criando um pino
            //let pino = self.configuraPino(titulo: "Caelum", localizacao: localizacaoEncontrada)
            let pino = Localizacao().configuraPino(titulo: "Caelum", localizacao: localizacaoEncontrada, cor: .black, icone: UIImage(named: "icon_caelum")) // imagem nao disponibilizada no curso, porém se estivesse era só adicionala ao projeto e ela seria exibida
            
            // criando uma região onde o pino será exibido
            let regiao = MKCoordinateRegionMakeWithDistance(pino.coordinate, 5000, 5000)
            // setando a região no mapa
            self.mapa.setRegion(regiao, animated: true)
            // adicionando o pino no mapa
            self.mapa.addAnnotation(pino)
            
            self.localizarAluno()
            
        }
    }
 
    // Para usar o pino padrão, uso um MKPointAnnotation (refatorei para usar um pino personalizado)
   /* func configuraPino(titulo:String, localizacao: CLPlacemark) -> MKPointAnnotation {
        let pino = MKPointAnnotation()
        
        pino.title = titulo
        pino.coordinate = localizacao.location!.coordinate
        
        return pino
    } */
    
    
    func localizarAluno() {
        if let aluno = aluno {
            Localizacao().ConverteEnderecoEmCoordenadas(aluno.endereco!) { (localizacaoEncontrada) in
                //let pino = self.configuraPino(titulo: aluno.nome!, localizacao: localizacaoEncontrada)
                let pino = Localizacao().configuraPino(titulo: aluno.nome!, localizacao: localizacaoEncontrada, cor: nil, icone: nil)
                
                self.mapa.addAnnotation(pino)
                self.mapa.showAnnotations(self.mapa.annotations, animated: true)
            }
        }
        
    }

}

extension MapaViewController: CLLocationManagerDelegate {
    // metodo chamado quando o usuario trocar de status de autorização
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            let botao = Localizacao().configuraBotaoLocalizacaoAtual(mapa: mapa)
            mapa.addSubview(botao)
            gerenciadorDeLocalizacao.startUpdatingLocation()
            break
        default:
            break
        }
    }
    
    // função chamada quando a localização do usuario é alterada (usada para monitoramento em tempo real)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
}
