//
//  Localizacao.swift
//  Agenda
//
//  Created by Mauro Augusto Diniz on 12/06/19.
//  Copyright © 2019 Alura. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class Localizacao: NSObject {

    func ConverteEnderecoEmCoordenadas(_ endereco: String, local:@escaping (_ local: CLPlacemark) -> Void) {
        // para conseguirmos converter um local em coordenadas temos que usar a classe CLGeoCoder, que faz parte do CoreLocation
        let conversor = CLGeocoder()
        conversor.geocodeAddressString(endereco) { (listaDeLocalizacoes, error) in
            if let localizacao = listaDeLocalizacoes?.first {
                local(localizacao)
            }
        }
        
    }
    
    func configuraPino(titulo:String, localizacao: CLPlacemark, cor: UIColor?, icone: UIImage?) -> Pino {
        let pino = Pino(coordinate: localizacao.location!.coordinate)
        
        pino.title = titulo
        pino.color = cor
        pino.icon = icone
        
        return pino
    }
    
    // botao de localização atual é aquele que aparece no canto superior esquerdo da tela e que, quando clicado, mostra onde o usuario está
    func configuraBotaoLocalizacaoAtual(mapa: MKMapView) -> MKUserTrackingButton {
        let botao = MKUserTrackingButton(mapView: mapa)
        botao.frame.origin.x = 10
        botao.frame.origin.y = 10
        
        return botao
    }
    
    func localizaAlunoNoWaze(_ alunoSelecionado: Aluno) {
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
    }
    
}

extension Localizacao: MKMapViewDelegate {
    // metodo usado para substituir o pino padrão pelo personalizado
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is Pino {
            let annotationView = annotation as! Pino
            var pinoView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationView.title!) as? MKMarkerAnnotationView
            
            pinoView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationView.title!)
            
            pinoView?.annotation = annotationView
            pinoView?.glyphImage = annotationView.icon
            pinoView?.markerTintColor = annotationView.color
            
            return pinoView
        }
        return nil // se não entrar no if acima ele retornará nil e usar ao pino padrão do ios
    }
}
