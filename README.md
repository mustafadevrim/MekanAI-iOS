--------------------MekanAI - Akıllı Şehir Rehberi-----------------------------

MekanAI, kullanıcıların anlık konumlarına ve kişisel tercihlerine göre yapay zeka destekli mekan önerileri sunan, iOS platformu için geliştirilmiş modern bir şehir keşif uygulamasıdır. Bu proje, karmaşık veri yönetimi, yapay zeka entegrasyonu ve kullanıcı dostu harita deneyimini bir araya getirmektedir.


--------------------Öne Çıkan Özellikler-----------------------------

Yapay Zeka Destekli Arama: Gemini AI entegrasyonu sayesinde doğal dil işleme ile (Örn: "Sakin bir çalışma ortamı olan kafe") nokta atışı mekan önerileri.

Dinamik Harita Deneyimi: Apple MapKit kullanarak mekanların iğnelenmesi, kullanıcı konumu takibi ve otomatik kadrajlama.

Akıllı Yol Tarifi: Seçilen mekanlar için anlık mesafe ve yürüme/araç süresi hesaplama (ETA), Apple Maps üzerinden navigasyon başlatma.

Favori Yönetimi: Core Data altyapısı kullanılarak favori mekanların kalıcı olarak saklanması, mükerrer kayıt kontrolü ve offline erişim.

Akıllı Arayüz Animasyonları: Sohbet ekranı ve harita görünümü arasında yumuşak geçişler sağlayan dinamik UI/UX tasarımı.


--------------------Teknolojiler ve Araçlar-----------------------------

Dil: Swift

Frameworkler: UIKit, MapKit, Core Data, Core Location

Yapay Zeka: Google Generative AI (Gemini 1.5 Flash)

Mimari: Service & Manager Patterns ile güçlendirilmiş MVC (Model-View-Controller)

Versiyon Kontrol: Git & GitHub


--------------------Mimari Yapı-----------------------------

Proje, "Massive View Controller" sorununu önlemek ve test edilebilirliği artırmak için modüler bir yapıda kurgulanmıştır:

Service Katmanı (AIService): Network istekleri ve AI model yönetimini encapsulate eder.

Manager Katmanı (CoreDataManager): Veri tabanı CRUD işlemlerini ve veri tutarlılığını yönetir.

Controller Katmanı: Kullanıcı etkileşimlerini ve görünüm katmanları arasındaki koordinasyonu sağlar.

Haberleşme: Nesneler arası iletişimde Closure ve Delegation tasarım kalıpları kullanılmıştır.


--------------------Kurulum-----------------------------

Bu depoyu klonlayın: git clone https://github.com/mustafadevrim/MekanAI-iOS

AIService.swift dosyasını açın.

Kendi Google AI Studio API anahtarınızı ilgili alana yapıştırın.

MekanAI.xcodeproj dosyasını Xcode ile açın ve çalıştırın.
