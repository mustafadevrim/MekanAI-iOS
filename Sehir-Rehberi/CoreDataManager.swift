//
//  CoreDataManager.swift
//  Sehir-Rehberi
//
//  Created by Mustafa Devrim Yıldız on 2.05.2026.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CityGuideModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data yüklenemedi: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveFavorite(name: String, latitude: Double, longitude: Double) {
        let favorite = FavoriteLocation(context: context)
        favorite.id = UUID()
        favorite.name = name
        favorite.latitude = latitude
        favorite.longitude = longitude
        
        do {
            try context.save()
            print("Başarıyla favorilere kaydedildi: \(name)")
        } catch {
            print("Kaydetme hatası: \(error.localizedDescription)")
        }
    }
    
    func fetchFavorites() -> [FavoriteLocation] {
        let request: NSFetchRequest<FavoriteLocation> = FavoriteLocation.fetchRequest()
        
        do {
            return try context.fetch(request)
        } catch {
            print("Veri çekme hatası: \(error.localizedDescription)")
            return []
        }
    }
    //eğer aynı favori varsa eklememek için kullandığımız fonksiyon
    func checkIfFavorite(name: String) -> Bool {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<FavoriteLocation> = FavoriteLocation.fetchRequest()
        
        // İsme göre veritabanında arama yapıyoruz
        request.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("Hata kontrolü yapılamadı: \(error)")
            return false
        }
    }
    func deleteFavoriteByName(name: String) {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<FavoriteLocation> = FavoriteLocation.fetchRequest()
        
        // SQL'deki WHERE mantığı gibi, ismi eşleşen kaydı arıyoruz
        request.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let results = try context.fetch(request)
            // Eğer o isimde bir kayıt bulduysa, ilkini al ve sil
            if let objectToDelete = results.first {
                context.delete(objectToDelete)
                try context.save() // Değişikliği veritabanına kaydet
                print("🗑️ '\(name)' veritabanından başarıyla silindi.")
            }
        } catch {
            print("Silme işlemi sırasında hata oluştu: \(error.localizedDescription)")
        }
    }
    func deleteFavorite(favorite: FavoriteLocation) {
        context.delete(favorite)
        do {
            try context.save()
            print("Favori silindi.")
        } catch {
            print("Silme hatası: \(error.localizedDescription)")
        }
    }
}
