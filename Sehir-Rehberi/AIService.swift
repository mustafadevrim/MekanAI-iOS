//
//  AIService.swift
//  Sehir-Rehberi
//
//  Created by Mustafa Devrim Yıldız on 18.12.2025.

import Foundation
import GoogleGenerativeAI

class AIService {
    
    // MARK: - 1. Model ve Chat Tanımlamaları
    let model = GenerativeModel(name: "gemini-2.5-flash", apiKey: "BURAYA KENDİ APİ KEYİNİ YAZ")
    var chat: Chat?
    
    // MARK: - 2. Sohbeti Başlatma ve AI'a Rol Verme
    func startNewChat() {
        chat = model.startChat(history: [])
        
        let systemPrompt = """
        Sen kısa, öz ve samimi bir mekan öneri asistanısın. 
        ASLA uzun listeler, maddeler (1., 2. gibi) veya kalın yazılar (markdown) kullanma. Cevapların EN FAZLA 1 veya 2 cümle olmalı!

        KESİN KURALLAR:
        1. Uygulama zaten GPS ile konum alıyor. ASLA kullanıcıya "Hangi şehir, hangi semt, neresi olsun?" diye SORMA!
        2. Saat, bütçe, kişi sayısı gibi detayları ASLA SORMA.
        3. Kullanıcı genel bir şey isterse (Örn: "Yemek yemek istiyorum"), ona sadece NE TÜR bir yemek istediğini kısaca sor. (Örn: "Harika! Hamburger mi yiyelim yoksa İtalyan mutfağı mı?")
        4. Kullanıcı net bir şey söylediğinde (Örn: "Kebap"), onaylayıp cümlenin sonuna SADECE aranacak kelimeyi [KATEGORİ: AranacakKelime] formatında ekle.
        
        Örnek Sohbet:
        Kullanıcı: Acıktım, yemek yiyelim.
        Sen: Afiyet olsun! Ne tür bir şeyler çekiyor canın? Fast food mu, ev yemeği mi?
        Kullanıcı: Fast food.
        Sen: Hemen sana en yakın fast food mekanlarını buluyorum. [KATEGORİ: Fast food]
        """
        
        Task {
            do {
                _ = try await chat?.sendMessage(systemPrompt)
                print("AI Asistan sohbet için hazır!")
            } catch {
                print("AI Başlatma Hatası: \(error)")
            }
        }
    }
    
    // MARK: - 3. Mesaj Gönderme ve Kategoriyi Yakalama
    func sendMessageToAI(userText: String, completion: @escaping (String, String?) -> Void) {
        guard let chat = chat else {
            completion("Sohbet başlatılamadı.", nil)
            return
        }
        
        Task {
            do {
                let response = try await chat.sendMessage(userText)
                guard let text = response.text else { return }
                
                // AI'ın cevabında etiket var mı diye kontrol ettiği yer
                if text.contains("[KATEGORİ:") {
                    let parts = text.components(separatedBy: "[KATEGORİ:")
                    let aiMessage = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    var category = parts[1].replacingOccurrences(of: "]", with: "")
                    category = category.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    DispatchQueue.main.async {
                        completion(aiMessage, category) // Kategori bulunan yer
                    }
                } else {
                    
                    DispatchQueue.main.async {
                        completion(text, nil)
                    }
                }
                
            } catch {
                
                print(" AI API Hatası: \(error.localizedDescription)")
                
                DispatchQueue.main.async {
                    completion("Bir hata oluştu, tekrar dener misin?", nil)
                }
            
            }
        }
    }
}
