import FirebaseMLNLTranslate
import FirebaseMLNLLanguageID
import FirebaseCore
import FirebaseMLNLTranslate
import FirebaseMLNLLanguageID

@objc(MLKitTranslate) class MLKitTranslate : CDVPlugin {
    
    // Lazy initialization to prevent EXC_BAD_ACCESS
    lazy var downloadQueue:[String: String] = {
        return [String: String]()
    }()
    
    override func pluginInitialize() {
        FirebaseApp.configure()
        setupNotificationObservers()
    }
    
    func setupNotificationObservers(){
        NotificationCenter.default.addObserver(
            forName: .firebaseMLModelDownloadDidSucceed,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            guard let _ = self,
                let userInfo = notification.userInfo,
                let model = userInfo[ModelDownloadUserInfoKey.remoteModel.rawValue]
                    as? TranslateRemoteModel
                
                else {
                    print("some error")
                    return
            }
            // The model was downloaded and is available on the device
            print("downloaded model")
            let languageCode = model.language.toLanguageCode()
            
            guard let callbackId = self?.downloadQueue[languageCode],
                let langStr = Locale.current.localizedString(forLanguageCode: languageCode)
                else{
                    print("Callback not present in queue")
                    self?.downloadQueue.removeValue(forKey: languageCode)
                    return;
            }
            self?.downloadQueue.removeValue(forKey: languageCode)
            let lang = Language(code: languageCode, displayName: langStr)
            self?.sendResult(message: lang.asDictionary, status: CDVCommandStatus_OK, callbackId: callbackId)
        }
        
        NotificationCenter.default.addObserver(
            forName: .firebaseMLModelDownloadDidFail,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            guard let _ = self,
                let userInfo = notification.userInfo,
                let model = userInfo[ModelDownloadUserInfoKey.remoteModel.rawValue]
                    as? TranslateRemoteModel
                else {
                    print("something went wrong")
                    return
            }
            _ = userInfo[ModelDownloadUserInfoKey.error.rawValue]
            
            let languageCode = model.language.toLanguageCode()
            
            
            guard let callbackId = self?.downloadQueue[languageCode]
                else{
                    print("Callback not present in queue [errObsv]")
                    return;
            }
            
            print("Could not download language model")
            self?.sendResult(message: "Could not download language model", status: CDVCommandStatus_ERROR, callbackId: callbackId)
        }
    }
    
    func sendResult(message: String, status: CDVCommandStatus, callbackId: String){
        let pluginResult = CDVPluginResult(
            status: status,
            messageAs: message
        )
        
        self.commandDelegate!.send(
            pluginResult,
            callbackId: callbackId
        )
    }
    
    func sendResult(message: [String: Any], status: CDVCommandStatus, callbackId: String){
        let pluginResult = CDVPluginResult(
            status: status,
            messageAs: message
        )
        
        self.commandDelegate!.send(
            pluginResult,
            callbackId: callbackId
        )
    }
    
    func sendResult(message: [Any], status: CDVCommandStatus, callbackId: String){
        let pluginResult = CDVPluginResult(
            status: status,
            messageAs: message
        )
        
        self.commandDelegate!.send(
            pluginResult,
            callbackId: callbackId
        )
    }
    
    @objc(identifyLanguage:)
    func identifyLanguage(_ command: CDVInvokedUrlCommand) {
        self.commandDelegate.run {
            if command.arguments.count < 1 {
                self.sendResult(message: "Invalid parameters", status: CDVCommandStatus_ERROR, callbackId: command.callbackId)
                return
            }
            let text = command.arguments[0] as? String ?? ""
            
            let languageId = NaturalLanguage.naturalLanguage().languageIdentification()
            
            languageId.identifyLanguage(for: text) { (languageCode, error) in
                if let error = error {
                    print("Failed with error: \(error)")
                    
                    self.sendResult(message: "Failed with error \(error)", status: CDVCommandStatus_ERROR, callbackId: command.callbackId)
                    
                    return
                }
                if let languageCode = languageCode, languageCode != "und" {
                    print("Identified Language: \(languageCode)")
                    
                    let langStr = Locale.current.localizedString(forLanguageCode: languageCode) ?? "Unknown Language"
                    let lang = Language(code: languageCode, displayName: langStr)
                    
                    print("Result is => ", lang.asDictionary)
                    
                    self.sendResult(message: lang.asDictionary, status: CDVCommandStatus_OK, callbackId: command.callbackId)
                    
                } else {
                    print("Could not identify language")
                    
                    self.sendResult(message: "Could not identify language", status: CDVCommandStatus_ERROR, callbackId: command.callbackId)
                    
                }
            }
        }
    }
    
    @objc(downloadModel:)
    func downloadModel(_ command: CDVInvokedUrlCommand) {
        if command.arguments.count < 1 {
            self.sendResult(message: "Invalid parameters", status: CDVCommandStatus_ERROR, callbackId: command.callbackId)
            return
        }
        let languageCode = command.arguments[0] as? String ?? ""
        let language = TranslateLanguage.fromLanguageCode(languageCode)
        let model = TranslateRemoteModel.translateRemoteModel(language: language)
        
        let availableLanguages = _getAvailableModels()
        
        let filteredLangs = availableLanguages.filter { (lang: [String: Any]) -> Bool in
            return lang["code"] as! String == languageCode
        }
        
        if filteredLangs.count == 0 {
            self.sendResult(message: "Language \(languageCode) is not downloadable", status: CDVCommandStatus_ERROR, callbackId: command.callbackId)
            return
        }
        
        if self.downloadQueue.index(forKey: languageCode) == nil{
            self.downloadQueue[languageCode] = command.callbackId
        }
        
        print("Download queue is => ", self.downloadQueue)
        
        ModelManager.modelManager().download(
            model,
            conditions: ModelDownloadConditions(
                allowsCellularAccess: false,
                allowsBackgroundDownloading: true
            )
        )
    }
    
    @objc(deleteModel:)
    func deleteModel(_ command: CDVInvokedUrlCommand) {
        self.commandDelegate.run{
            if command.arguments.count < 1 {
                self.sendResult(message: "Invalid parameters", status: CDVCommandStatus_ERROR, callbackId: command.callbackId)
                return
            }
            let languageCode = command.arguments[0] as? String ?? ""
            let langStr = Locale.current.localizedString(forLanguageCode: languageCode) ?? "Unknown Language"
            let language = TranslateLanguage.fromLanguageCode(languageCode)
            let model = TranslateRemoteModel.translateRemoteModel(language: language)
            
            ModelManager.modelManager().deleteDownloadedModel(model) { error in
                guard error == nil else {
                    self.sendResult(message: "Could not delete language model", status: CDVCommandStatus_ERROR, callbackId: command.callbackId)
                    return
                }
                
                let lang = Language(code: languageCode, displayName: langStr)
                
                self.sendResult(message: lang.asDictionary, status: CDVCommandStatus_OK, callbackId: command.callbackId)
            }
        }
    }
    
    @objc(getDownloadedModels:)
    func getDownloadedModels(_ command: CDVInvokedUrlCommand) {
        self.commandDelegate.run{
            let localModels = ModelManager.modelManager().downloadedTranslateModels
            
            let result = localModels.map({ (model) -> [String: Any] in
                let languageCode = model.language.toLanguageCode()
                let langStr = Locale.current.localizedString(forLanguageCode: languageCode) ?? "Unknown Language"
                return Language(code: languageCode, displayName: langStr).asDictionary
            })
            
            self.sendResult(message: result, status: CDVCommandStatus_OK, callbackId: command.callbackId)
        }
    }
    
    func _getAvailableModels() -> [[String: Any]]{
        let allLanguages = TranslateLanguage.allLanguages()
        
        let result = allLanguages.map({ (langCode) -> [String: Any] in
            let languageCode = TranslateLanguage(rawValue: UInt(truncating: langCode))!.toLanguageCode()
            let langStr = Locale.current.localizedString(forLanguageCode: languageCode) ?? "Unknown Language"
            
            return Language(code: languageCode, displayName: langStr).asDictionary
        })
        
        return result
    }
    
    @objc(getAvailableModels:)
    func getAvailableModels(_ command: CDVInvokedUrlCommand) {
        let result = _getAvailableModels()
        self.sendResult(message: result, status: CDVCommandStatus_OK, callbackId: command.callbackId)
    }
    
    func translateText(text: String, sourceLang: String, targetLang: String, callbackId: String){
        let options = TranslatorOptions(sourceLanguage: TranslateLanguage.fromLanguageCode(sourceLang), targetLanguage: TranslateLanguage.fromLanguageCode(targetLang))
        
        let translator = NaturalLanguage.naturalLanguage().translator(options: options)
        
        let conditions = ModelDownloadConditions(
            allowsCellularAccess: false,
            allowsBackgroundDownloading: true
        )
        
        translator.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else {
                print("error downloading model")
                self.sendResult(message: "Could not download language model", status: CDVCommandStatus_ERROR, callbackId: callbackId)
                return
            }
            print("model downloaded")
            
            translator.translate(text) { translatedText, error in
                guard error == nil, let translatedText = translatedText else {
                    self.sendResult(message: "Translation failed", status: CDVCommandStatus_ERROR, callbackId: callbackId)
                    return
                }
                
                print("Success, translatedText is ", translatedText)
                self.sendResult(message: translatedText, status: CDVCommandStatus_OK, callbackId: callbackId)
            }
        }
        
    }
    
    @objc(translate:)
    func translate(_ command: CDVInvokedUrlCommand) {
        if command.arguments.count < 3 {
            self.sendResult(message: "Invalid parameters", status: CDVCommandStatus_ERROR, callbackId: command.callbackId)
            return
        }
        guard let text = command.arguments[0] as? String,
            let sourceLang = command.arguments[1] as? String,
            let targetLang = command.arguments[2] as? String
            else{
                self.sendResult(message: "Invalid parameters", status: CDVCommandStatus_ERROR, callbackId: command.callbackId)
                return
        }
        
        self.translateText(text: text, sourceLang: sourceLang, targetLang: targetLang, callbackId: command.callbackId)
    }
    
    @objc(identifyTranslate:)
    func identifyTranslate(_ command: CDVInvokedUrlCommand) {
        
        if command.arguments.count < 2 {
            self.sendResult(message: "Invalid parameters", status: CDVCommandStatus_ERROR, callbackId: command.callbackId)
            return
        }
        
        let text = command.arguments[0] as? String ?? ""
        let targetLang = command.arguments[1] as? String ?? ""
        
        let languageId = NaturalLanguage.naturalLanguage().languageIdentification()
        
        languageId.identifyLanguage(for: text) { (identifiedLang, error) in
            if let error = error {
                print("Failed with error: \(error)")
                self.sendResult(message: "Failed with error \(error)", status: CDVCommandStatus_ERROR, callbackId: command.callbackId)
                return
            }
            if let identifiedLang = identifiedLang, identifiedLang != "und" {
                print("Identified Language: \(identifiedLang)")
                
                self.translateText(text: text, sourceLang: identifiedLang, targetLang: targetLang, callbackId: command.callbackId)
                
            } else {
                print("Could not identify language")
                self.sendResult(message: "Could not identify language", status: CDVCommandStatus_ERROR, callbackId: command.callbackId)
            }
        }
    }
    
    struct Language {
        var code: String
        var displayName: String
        
        var asDictionary : [String:Any] {
            let mirror = Mirror(reflecting: self)
            let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?,value:Any) -> (String,Any)? in
                guard label != nil else { return nil }
                return (label!,value)
            }).compactMap{ $0 })
            return dict
        }
    }
}
