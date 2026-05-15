//
//  ViewController.swift
//  Sehir-Rehberi
//
//  Created by Mustafa Devrim Yıldız on 18.12.2025.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // MARK: - 1. ARAYÜZ ELEMANLARI (UI)
    
    let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    let openChatButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "sparkles.tv.fill") ?? UIImage(systemName: "message.fill"), for: .normal)
        btn.backgroundColor = .systemBlue
        btn.tintColor = .white
        btn.layer.cornerRadius = 25
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.3
        btn.layer.shadowOffset = CGSize(width: 0, height: 3)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    let favoritesButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Favoriler", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    let zoomInButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "plus"), for: .normal)
        btn.backgroundColor = .systemBackground
        btn.tintColor = .systemBlue
        btn.layer.cornerRadius = 20
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.2
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    let zoomOutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "minus"), for: .normal)
        btn.backgroundColor = .systemBackground
        btn.tintColor = .systemBlue
        btn.layer.cornerRadius = 20
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.2
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    // --- SOHBET ARAYÜZÜ ELEMANLARI ---
    
    let chatView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let chatTableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        return tv
    }()
    
    let userTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Nasıl bir yer arıyorsun?..."
        tf.borderStyle = .roundedRect
        tf.backgroundColor = .systemGray6
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        btn.tintColor = .systemBlue
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - 2. DEĞİŞKENLER
    var chatMessages: [String] = ["AI: Merhaba! Bugün nereye gitmek istersin? "]
    let locationManager = CLLocationManager()
    let aiService = AIService()
    
    // MARK: - 3. YAŞAM DÖNGÜSÜ (LIFECYCLE)
    override func viewDidLoad() {
        super.viewDidLoad()
            view.backgroundColor = .systemBackground
            
            // Konum yöneticisi ayarları
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization() // Kullanıcıya izin soran popup!
            locationManager.startUpdatingLocation()
            
            mapView.showsUserLocation = true
            mapView.delegate = self
        
            setupUI()
            setupConstraints()
            setupActions()
            aiService.startNewChat()
        
        // TableView Ayarları
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChatCell")
        
        let istanbulLocation = CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784)
        let region = MKCoordinateRegion(center: istanbulLocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: false)
    }
    
    // MARK: - 4. KURULUM FONKSİYONLARI
    private func setupUI() {
        // (map sayfası)
        view.addSubview(mapView)
        view.addSubview(favoritesButton)
        view.addSubview(zoomInButton)
        view.addSubview(zoomOutButton)
        
        // (chat sayfası)
        view.addSubview(openChatButton)
        view.addSubview(chatView)
        chatView.addSubview(chatTableView)
        chatView.addSubview(userTextField)
        chatView.addSubview(sendButton)
        view.bringSubviewToFront(favoritesButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            //KONUM KODLARI
            // Yaklaşma (+) Butonu Kısıtlamaları
            zoomInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            zoomInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            zoomInButton.widthAnchor.constraint(equalToConstant: 40),
            zoomInButton.heightAnchor.constraint(equalToConstant: 40),

            // Uzaklaşma (-) Butonu Kısıtlamaları
            zoomOutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            zoomOutButton.topAnchor.constraint(equalTo: zoomInButton.bottomAnchor, constant: 10),
            zoomOutButton.widthAnchor.constraint(equalToConstant: 40),
            zoomOutButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Chat açma butonu
            openChatButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            openChatButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            openChatButton.widthAnchor.constraint(equalToConstant: 50),
            openChatButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Harita Kısıtlamaları
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Favoriler Butonu
            favoritesButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            favoritesButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            favoritesButton.widthAnchor.constraint(equalToConstant: 90),
            favoritesButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Chat ekranı
            chatView.topAnchor.constraint(equalTo: view.topAnchor),
            chatView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            chatView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Yazı alanı
            userTextField.bottomAnchor.constraint(equalTo: chatView.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            userTextField.leadingAnchor.constraint(equalTo: chatView.leadingAnchor, constant: 16),
            userTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            userTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Gönder Butonu
            sendButton.centerYAnchor.constraint(equalTo: userTextField.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: chatView.trailingAnchor, constant: -16),
            sendButton.widthAnchor.constraint(equalToConstant: 50),
            sendButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Table View
            chatTableView.topAnchor.constraint(equalTo: chatView.safeAreaLayoutGuide.topAnchor, constant: 20),
            chatTableView.leadingAnchor.constraint(equalTo: chatView.leadingAnchor, constant: 16),
            chatTableView.trailingAnchor.constraint(equalTo: chatView.trailingAnchor, constant: -16),
            chatTableView.bottomAnchor.constraint(equalTo: userTextField.topAnchor, constant: -10)
        ])
    }
    //BUTON AKSİYONLARI
    private func setupActions() {
        favoritesButton.addTarget(self, action: #selector(showFavorites), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        zoomInButton.addTarget(self, action: #selector(zoomInTapped), for: .touchUpInside)
        zoomOutButton.addTarget(self, action: #selector(zoomOutTapped), for: .touchUpInside)
        openChatButton.addTarget(self, action: #selector(openChatTapped), for: .touchUpInside)
    }
    
    // MARK: - 5. AKSİYONLAR VE BUTON TIKLAMALARI
    @objc private func showFavorites() {
        let favVC = FavoritesViewController()
        
        favVC.onFavoriteSelected = { [weak self] (title, latitude, longitude) in
            guard let self = self else { return }
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            // 1. Chat ekranını aşağı kaydırarak kapat
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.chatView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
            })
            
            // 2. Haritadaki eski iğneleri temizle ve sadece favori mekanı ekle
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            let destinationAnnotation = MKPointAnnotation()
            destinationAnnotation.coordinate = coordinate
            destinationAnnotation.title = title
            self.mapView.addAnnotation(destinationAnnotation)
            
            // 3. Haritayı kadrajla (Sahte iğne yaratmak yerine haritanın kendi mavi noktasını kullanıyoruz!)
            var annotationsToFrame: [MKAnnotation] = [destinationAnnotation]
            
            // Eğer haritada kullanıcının mavi noktası aktifse, onu da kadraja dahil et
            if self.mapView.userLocation.coordinate.latitude != 0.0 {
                annotationsToFrame.append(self.mapView.userLocation)
            }
            
            // Ekranı her iki noktayı görecek şekilde kaydır/uzaklaştır
            self.mapView.showAnnotations(annotationsToFrame, animated: true)
        }
        
        let navController = UINavigationController(rootViewController: favVC)
        self.present(navController, animated: true)
    }
    
    @objc private func sendTapped() {
        guard let text = userTextField.text, !text.isEmpty else { return }
        
        // 1. Kullanıcının mesajını ekrana bas
        chatMessages.append("Sen: \(text)")
        userTextField.text = ""
        chatTableView.reloadData()
        scrollToBottom()
        
        // 2. Mesajı Gemini AI'a gönder ve cevabı bekle
        aiService.sendMessageToAI(userText: text) { [weak self] (aiReply, category) in
            guard let self = self else { return }
            
            // AI'ın cevabını ekrana bas
            self.chatMessages.append("AI: \(aiReply)")
            self.chatTableView.reloadData()
            self.scrollToBottom()
            
            // 3. Eğer AI ne arayacağını anladıysa (Kategori döndürdüyse) haritaya geçiş yap
            if let targetCategory = category {
                self.transitionToMap(with: targetCategory)
            }
        }
    }
    @objc private func zoomInTapped() {
        var region = mapView.region
        region.span.latitudeDelta /= 2.0
        region.span.longitudeDelta /= 2.0
        mapView.setRegion(region, animated: true)
    }

    @objc private func zoomOutTapped() {
        var region = mapView.region
        region.span.latitudeDelta *= 2.0
        region.span.longitudeDelta *= 2.0
        mapView.setRegion(region, animated: true)
    }
    
    @objc private func openChatTapped() {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.chatView.transform = .identity
        })
    }
    
    // Tabloyu her mesajda en alta kaydırmak için yardımcı fonksiyon
    private func scrollToBottom() {
        let indexPath = IndexPath(row: chatMessages.count - 1, section: 0)
        chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
    }
    private func transitionToMap(with category: String) {
        // Kullanıcıya AI'ın mesajını okuması için 3 saniye ver
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.chatView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
            }) { _ in
                print(" AI Kararı haritaya iletildi: \(category)")
                
                // GİZLİ FONKSİYONU BURADA ÇAĞIRIYORUZ!
                self.performSearch(keyword: category)
            }
        }
    }
}
    // MARK: - 6. TABLEVIEW (MESAJ LİSTESİ) DELEGELERİ
    extension ViewController: UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return chatMessages.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath)
            let message = chatMessages[indexPath.row]
            
            cell.textLabel?.text = message
            cell.textLabel?.numberOfLines = 0
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            // Kullanıcı ve AI mesajlarını renklendirme
            if message.hasPrefix("Sen:") {
                cell.textLabel?.textColor = .systemBlue
                cell.textLabel?.textAlignment = .right
            } else {
                cell.textLabel?.textColor = .black
                cell.textLabel?.textAlignment = .left
            }
            
            return cell
        }
        private func performSearch(keyword: String) {
            // Eski iğneleri temizle
            mapView.removeAnnotations(mapView.annotations)
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = keyword
            
            // Aramayı KESİNLİKLE kullanıcının etrafındaki 30 dakikalık yürüme mesafesine (3 km) kilitle
            if let userLocation = locationManager.location?.coordinate {
                let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 3000, longitudinalMeters: 3000)
                request.region = region
            }
            
            let search = MKLocalSearch(request: request)
            search.start { [weak self] response, error in
                guard let self = self, let response = response else {
                    print("Sonuç bulunamadı veya hata: \(error?.localizedDescription ?? "")")
                    return
                }
                
                var bulunanIgneler: [MKPointAnnotation] = []
                
                for item in response.mapItems {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    bulunanIgneler.append(annotation)
                    self.mapView.addAnnotation(annotation)
                }
                
                if !bulunanIgneler.isEmpty {
                    self.mapView.showAnnotations(bulunanIgneler, animated: true)
                }
            }
        }
    }
// MARK: - 7. MAPVIEW DELEGATE (HARİTA TIKLAMALARI)
extension ViewController {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Tıklanan şey kullanıcının kendi mavi noktasıysa işlem yapma
        guard let annotation = view.annotation, !(annotation is MKUserLocation) else { return }
        
        let title = annotation.title ?? "Bilinmeyen Yer"
        let coordinate = annotation.coordinate
        
        // 1. ADIM: Mekanın favorilerde olup olmadığını CoreDataManager'a sor
        let isAlreadyFavorite = CoreDataManager.shared.checkIfFavorite(name: title!)

        let alertController = UIAlertController(title: title, message: "Bu mekan için ne yapmak istersin?", preferredStyle: .actionSheet)

        // Yol Tarifi Seçeneği
        let routeAction = UIAlertAction(title: "Yol Tarifi Al", style: .default) { _ in
            self.calculateAndShowETA(title: title!, destination: coordinate)
        }
        alertController.addAction(routeAction)

        // 2. ADIM: Dinamik Favori Mantığı
        if isAlreadyFavorite {
            let removeAction = UIAlertAction(title: "Favorilerden Çıkar", style: .destructive) { _ in
                // 409. satırı bununla değiştir:
                CoreDataManager.shared.deleteFavoriteByName(name: title ?? "")
                
                // Kullanıcıya geri bildirim ver
                let alert = UIAlertController(title: "Silindi", message: "\(title ?? "") favorilerinden çıkarıldı.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Tamam", style: .default))
                self.present(alert, animated: true)
            }
            alertController.addAction(removeAction)
        } else {
            // Favorilerde yoksa EKLEME seçeneğini göster
            let addAction = UIAlertAction(title: "Favorilere Ekle", style: .default) { _ in
                self.saveToFavorites(title: title ?? "", coordinate: coordinate)
            }
            alertController.addAction(addAction)
        }

        // Vazgeç Seçeneği
        let cancelAction = UIAlertAction(title: "Vazgeç", style: .cancel) { _ in
            mapView.deselectAnnotation(annotation, animated: true)
        }
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
        mapView.deselectAnnotation(annotation, animated: true)
    }
    
    // MARK: - APPLE MAPS VE FAVORİ FONKSİYONLARI BURADA
    private func openInAppleMaps(title: String, coordinate: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    private func calculateAndShowETA(title: String, destination: CLLocationCoordinate2D) {
        guard let userLocation = locationManager.location?.coordinate else {
            // Eğer konum bulunamazsa direkt haritalara at
            self.openInAppleMaps(title: title, coordinate: destination)
            return
        }
        
        let sourceItem = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        let destItem = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        
        // Rota İstekleri Oluştur (Biri Araba, Biri Yürüyüş için)
        let driveRequest = MKDirections.Request()
        driveRequest.source = sourceItem
        driveRequest.destination = destItem
        driveRequest.transportType = .automobile
        
        let walkRequest = MKDirections.Request()
        walkRequest.source = sourceItem
        walkRequest.destination = destItem
        walkRequest.transportType = .walking
        
        let group = DispatchGroup()
        var driveTime: TimeInterval = 0
        var walkTime: TimeInterval = 0
        
        // Araba süresini hesapla
        group.enter()
        MKDirections(request: driveRequest).calculateETA { response, _ in
            driveTime = response?.expectedTravelTime ?? 0
            group.leave()
        }
        
        // Yürüyüş süresini hesapla
        group.enter()
        MKDirections(request: walkRequest).calculateETA { response, _ in
            walkTime = response?.expectedTravelTime ?? 0
            group.leave()
        }
        
        // İki hesaplama da bitince Bildiri Ekranını (Alert) göster
        group.notify(queue: .main) {
            let driveStr = driveTime > 0 ? "\(Int(driveTime / 60)) dk" : "Bilinmiyor"
            let walkStr = walkTime > 0 ? "\(Int(walkTime / 60)) dk" : "Bilinmiyor"
            
            let message = "Arabayla: \(driveStr)\n Yürüyerek: \(walkStr)"
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            // Tamam Butonu (Sadece ekranı kapatır, haritada kalır)
            alert.addAction(UIAlertAction(title: "Tamam", style: .cancel))
            
            // Navigasyona Git Butonu (Apple Maps'i açar)
            alert.addAction(UIAlertAction(title: "Navigasyona Git", style: .default, handler: { _ in
                self.openInAppleMaps(title: title, coordinate: destination)
            }))
            
            self.present(alert, animated: true)
        }
    }

    private func saveToFavorites(title: String, coordinate: CLLocationCoordinate2D) {
        print("'\(title)' veritabanına kaydedilmek üzere tetiklendi.")
        
        CoreDataManager.shared.saveFavorite(name: title, latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        let successAlert = UIAlertController(title: "Başarılı!", message: "\(title) favorilerine eklendi.", preferredStyle: .alert)
        successAlert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(successAlert, animated: true)
    }
}
