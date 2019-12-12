var exec = require("cordova/exec");

module.exports = {
  translate: function(text, targetLang, sourceLang) {
    if (sourceLang == undefined) {
      cordova.exec(resolve, reject, "MLKitTranslate", "identifyTranslate", [
        text,
        targetLang
      ]);
    }
    cordova.exec(resolve, reject, "MLKitTranslate", "translate", [
      text,
      sourceLang,
      targetLang
    ]);
  },
  identify: function(text) {
    cordova.exec(resolve, reject, "MLKitTranslate", "identify", [text]);
  },
  getDownloadedModels: function(successCallback, errorCallback) {
    exec(
      successCallback,
      errorCallback,
      "MLKitTranslate",
      "getDownloadedModels"
    );
  },
  downloadLanguage: function(code, successCallback, errorCallback) {
    exec(successCallback, errorCallback, "MLKitTranslate", "downloadLanguage", [
      code
    ]);
  },
  deleteLanguage: function(code, successCallback, errorCallback) {
    exec(successCallback, errorCallback, "MLKitTranslate", "deleteLanguage", [
      code
    ]);
  },
  getAvailableModels: function(successCallback, errorCallback) {
    exec(
      successCallback,
      errorCallback,
      "MLKitTranslate",
      "getAvailableModels"
    );
  }
};
