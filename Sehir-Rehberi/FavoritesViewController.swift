//
//  FavoritesViewController.swift
//  Sehir-Rehberi
//
//  Created by Mustafa Devrim Yıldız on 2.05.2026.
//

import UIKit
import MapKit

class FavoritesViewController: UIViewController {
    var onFavoriteSelected: ((String, Double, Double) -> Void)?
    var didSelectFavorite: ((FavoriteLocation) -> Void)?
    let tableView = UITableView()
    var favorites: [FavoriteLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favorilerim"
        view.backgroundColor = .systemBackground
        
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FavCell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func loadFavorites() {
        self.favorites = CoreDataManager.shared.fetchFavorites()
        tableView.reloadData()
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if favorites.isEmpty {
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            emptyLabel.text = "Henüz favori mekanınız yok."
            emptyLabel.textAlignment = .center
            tableView.backgroundView = emptyLabel
            return 0
        } else {
            tableView.backgroundView = nil
            return favorites.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavCell", for: indexPath)
        let fav = favorites[indexPath.row]
        cell.textLabel?.text = fav.name
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Tıklanma animasyonunu (gri arka planı) kaldır
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Hangi hücreye tıklandığını bul
        let selectedFavorite = favorites[indexPath.row]
        let title = selectedFavorite.name ?? "Favori Mekan"
        
        // 1. Seçilen mekanın bilgilerini ana sayfadaki (ViewController) haberciye gönder
        onFavoriteSelected?(title, selectedFavorite.latitude, selectedFavorite.longitude)
        
        // 2. Favoriler sayfasını kapat ki ana sayfadaki o şık harita animasyonunu görebilelim!
        dismiss(animated: true)
    }
    
    // silme işlemi
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let favToDelete = favorites[indexPath.row]
            CoreDataManager.shared.deleteFavorite(favorite: favToDelete)
            
            favorites.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
