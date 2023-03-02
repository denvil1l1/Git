//
//  ViewController.swift
//  TestExercise
//
//  Created by Владислав Куликов on 02.03.2023.
//


import Foundation
import Firebase

// MARK: - Welcome
struct Welcome: Codable {
    let data: DataClass
}

// MARK: - DataClass
struct DataClass: Codable {
    let activeCryptocurrencies, upcomingIcos, ongoingIcos, endedIcos: Int
    let markets: Int
    let totalMarketCap, totalVolume, marketCapPercentage: [String: Double]
    let marketCapChangePercentage24HUsd: Double
    let updatedAt: Int

    enum CodingKeys: String, CodingKey {
        case activeCryptocurrencies = "active_cryptocurrencies"
        case upcomingIcos = "upcoming_icos"
        case ongoingIcos = "ongoing_icos"
        case endedIcos = "ended_icos"
        case markets
        case totalMarketCap = "total_market_cap"
        case totalVolume = "total_volume"
        case marketCapPercentage = "market_cap_percentage"
        case marketCapChangePercentage24HUsd = "market_cap_change_percentage_24h_usd"
        case updatedAt = "updated_at"
    }
}

import UIKit

class ViewController: UIViewController {

    var ref = Database.database().reference()
    
    private lazy var parse: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.setTitle("Parse", for: .normal)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 13
        button.addTarget(self, action: #selector(onTapParse), for: .touchDown)
        button.layer.borderColor = UIColor.black.cgColor
        return button
    }()
    
    private lazy var show: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.setTitle("Show", for: .normal)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 13
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(onTapShow), for: .touchDown)
        return button
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 13
        label.layer.borderColor = UIColor.black.cgColor
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        layoutConstraint()
    }
    
    private func layoutConstraint() {
        view.addSubview(parse)
        view.addSubview(show)
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 220),
            view.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 30),
            label.bottomAnchor.constraint(equalTo: label.topAnchor ,constant: 50),
            
            parse.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 30),
            parse.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 90),
            view.trailingAnchor.constraint(equalTo: parse.trailingAnchor, constant: 30),
            parse.bottomAnchor.constraint(equalTo: parse.topAnchor ,constant: 50),
            
            show.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 30),
            show.topAnchor.constraint(equalTo: parse.bottomAnchor, constant: 30),
            view.trailingAnchor.constraint(equalTo: show.trailingAnchor, constant: 30),
            show.bottomAnchor.constraint(equalTo: show.topAnchor ,constant: 50)
        ])
    }
    
    @objc
    func onTapParse() {
        let urlString = "https://api.coingecko.com/api/v3/global"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response,  error in
            
            guard let data = data else { return }
            do{
                let id = "btc"
                let array = try JSONDecoder().decode(Welcome.self, from: data)
                self.ref.child("info").setValue(["btc": id, "value": array.data.marketCapPercentage[id]  ?? ""])
            } catch {
                print(error)
            }
        }.resume()
    }
    
    @objc
    func onTapShow() {
        Database.database().reference().child("info").observeSingleEvent(of: .value, with: { snapshot in
            
          let value = snapshot.value as? NSDictionary
            let valueValute = value?["value"] as? Double ?? 0
            let nameValute = value?["btc"] as? String ?? ""
            self.label.text = ("\(nameValute) = \(valueValute)")
            
        }) { error in
          print(error.localizedDescription)
        }
    }
}

