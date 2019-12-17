var exec = require("cordova/exec");

module.exports = {
  translate: function(
    text,
    targetLang,
    sourceLang,
    successCallback,
    errorCallback
  ) {
    if (typeof sourceLang == "function") {
      errorCallback = successCallback;
      successCallback = sourceLang;
      cordova.exec(
        successCallback,
        errorCallback,
        "MLKitTranslate",
        "identifyTranslate",
        [text, targetLang]
      );
    } else {
      cordova.exec(
        successCallback,
        errorCallback,
        "MLKitTranslate",
        "translate",
        [text, sourceLang, targetLang]
      );
    }
  },
  identifyLanguage: function(text, successCallback, errorCallback) {
    cordova.exec(
      successCallback,
      errorCallback,
      "MLKitTranslate",
      "identifyLanguage",
      [text]
    );
  },
  getDownloadedModels: function(successCallback, errorCallback) {
    exec(
      successCallback,
      errorCallback,
      "MLKitTranslate",
      "getDownloadedModels"
    );
  },
  downloadModel: function(code, successCallback, errorCallback) {
    exec(successCallback, errorCallback, "MLKitTranslate", "downloadModel", [
      code
    ]);
  },
  deleteModel: function(code, successCallback, errorCallback) {
    exec(successCallback, errorCallback, "MLKitTranslate", "deleteModel", [
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
