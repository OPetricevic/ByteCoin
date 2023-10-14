//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Omar Petričević on 08.03.2023..
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation
protocol CoinManagerDelegate{
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC" //url za API početni
    let apiKey = "0FFDDA99-5D0D-4D5C-8A42-BC6B561413C3" //vrijednost ključa
    
    var delegate: CoinManagerDelegate?
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for coinName: String) { // funkcija koja uzima coin u obliku stringa, i smješta ga u coinName
        let urlString = "\(baseURL)/\(coinName)?apikey=\(apiKey)" // URL u obliku stringa, od API (baseURL) + APIKeya(apiKey) + ImenaCoina (coinName)
        // #1 Napravi URL
        if let url = URL(string: urlString){ // Kreiramo URL od stringa odozgor pomocu "URL(string" što od stringa pravi, pravi URL
        // #2 Napravi Sesiju
            let session = URLSession(configuration: .default) //Sesija URL-a konfigurisana na default način, da omoguci rad.
        // #3 Napravi task
            let task = session.dataTask(with: url){(data, response, error) in //Kreiranje zadatka (task), da sesija ima bazni zadatak, SA "url" znači na tome url-u pored toga, daje nam "datu, response i error, zavisno od toga šta se desi.
                // Mi odlučujemo ispisat error pomocu printa.
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    let bitCoinPrice = self.parseJSON(safeData) // Zove JSON funkciju i prosljeduje cijenu.
                    
                    let priceString = String(format: "%.2f", bitCoinPrice!)
                     self.delegate?.didUpdatePrice(price: priceString, currency: coinName)
                }

                // print(parseJSON(dataAsString) as Any)
            }
            // #4 Započni Task
            task.resume()
            
        }
            
    }
    
    func parseJSON(_ bitData: Data) -> Double?{
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(BitData.self, from: bitData)
            let lastPrice = decodedData.rate
            
            print(lastPrice)
            return lastPrice
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
