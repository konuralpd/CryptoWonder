//
//  ViewController.swift
//  CryptoTrack
//
//  Created by Jaf Crisologo on 2022-05-07.
//

import UIKit

// API Caller
// UI to show different cryptos
// MVVM

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(CryptoTableViewCell.self, forCellReuseIdentifier: CryptoTableViewCell.identifier)
       
        return tableView
    }()
    
    private var viewModels = [CryptoTableViewCellViewModel]()
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.allowsFloats = true
        formatter.numberStyle = .currency
        formatter.formatterBehavior = .default
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "CryptoWonder"
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        APICaller.shared.getAllCryptoData { [weak self] result in
            switch result {
            case .success(let models):
//                print(models.count)
                self?.viewModels = models.compactMap({ model in
                    // NumberFormatter
                    let price = model.price_usd ?? 0
                    let formatter = ViewController.numberFormatter
                    let priceString = formatter.string(from: NSNumber(value: price))
                    let iconUrl = URL(
                        string:
                            APICaller.shared.icons.filter({ icon in
                                icon.asset_id == model.asset_id
                            }).first?.url ?? ""
                    )
                    
                    return CryptoTableViewCellViewModel(
                        name: model.name ?? "",
                        symbol: model.asset_id,
                        price: priceString ?? "N/A",
                        iconUrl: iconUrl
                    )
                })
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Error \(error)")
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        tableView.backgroundColor = .green
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CryptoTableViewCell.identifier,
            for: indexPath
        ) as? CryptoTableViewCell else {
            fatalError()
        }
//        cell.textLabel?.text = "Hello World"
        cell.configure(with: viewModels[indexPath.row])
        cell.backgroundColor = .black
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}

