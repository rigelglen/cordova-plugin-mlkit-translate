# Cordova MLKit Translation

Cordova Plugin that implements MLKit Translation and Language Identification features.

Supports both iOS and Android.

### Version Support

- cordova `>=9`
- cordova-android `>=8`
- cordova-ios `>=5`

### Dependencies

This plugin depends on [cordova-plugin-firebasex](https://github.com/dpa99c/cordova-plugin-firebasex) on android.

## Installation

- Install the plugin by adding it to your project's config.xml:

```
<plugin name="cordova-plugin-mlkit-translate" spec="latest" />
```

or run

```
cordova plugin add cordova-plugin-mlkit-translate
```

- Make sure you have your google-services.json file in your project's root folder.

## Variables (android only)

|                  Variable                  | Default |
| :----------------------------------------: | :-----: |
|    FIREBASE_ML_NATURAL_LANGUAGE_VERSION    | 22.0.0  |
| FIREBASE_ML_NATURAL_LANGUAGE_MODEL_VERSION | 20.0.7  |
|  FIREBASE_ML_NATURAL_LANGUAGE_ID_VERSION   | 20.0.7  |

## API

You can access all these methods via the window["MLKitTranslate"] object. Ionic Native wrapper WIP.

#### translate

Translates text from one language to another. Requires the source and target languages need to be downloaded. If not the languages are downloaded in the background automatically.

##### Parameters

- {string} text - text to be translated
- {string} targetLanguage - language code of the language to translate to
- {string} sourceLanguage - (optional) language code of the language to translate from, if not present the language is inferred.
- {function} success - callback function which takes a parameter data which will be invoked on success
- {function} error - callback function which takes a parameter err which will be invoked on failure

##### Example

```
window["MLKitTranslate"].translate("hello", "en", "es",
        (data)=>console.log(`Translated text is ${data}`),
        (err)=>console.log("Something went wrong with the translation")
})
```

#### identifyLanguage

Determines the language of a string of text.

##### Parameters

- {string} text - text to be translated
- {function} success - callback function which takes a parameter data which will be invoked on success
- {function} error - callback function which takes a parameter err which will be invoked on failure

#### Data format

Success data will be a language object with two properties

- {string} code - [BCP-47](https://en.wikipedia.org/wiki/IETF_language_tag) language code
- {function} displayName - Name of the language

##### Example

```
window["MLKitTranslate"].identifyLanguage("hello",
        (data)=>console.log("Identified text is",  data),
        (err)=>console.log("Something went wrong with the translation")
})

// prints Identified text is {"code": "en", "displayName": "English"}
```

#### getDownloadedModels

List of language models that have been downloaded to the device.

##### Parameters

- {function} success - callback function which takes a parameter data which will be invoked on success
- {function} error - callback function which takes a parameter err which will be invoked on failure

##### Data format

Success data will be an array with language objects (see above)

##### Example

```
window["MLKitTranslate"].getDownloadedModels(
        (data)=>console.log(data),
        (err)=>console.log(err)
})

// prints [{"code": "en", "displayName": "English"}]
```

#### getAvailableModels

List of language models that can be downloaded.

##### Parameters

- {function} success - callback function which takes a parameter data which will be invoked on success
- {function} error - callback function which takes a parameter err which will be invoked on failure

##### Data format

Success data will be an array with language objects (see above)

##### Example

```
window["MLKitTranslate"].getAvailableModels(
        (data)=>console.log(data),
        (err)=>console.log(err)
})

// prints [{"code": "en", "displayName": "English"}, {"code", "es", "displayName": "Spanish"}, ...]
```

#### downloadModel

Downloads a specified language model.

##### Parameters

- {string} code - [BCP-47](https://en.wikipedia.org/wiki/IETF_language_tag) language code of the language to download
- {function} success - callback function which takes a parameter data which will be invoked on success
- {function} error - callback function which takes a parameter err which will be invoked on failure

##### Data format

Success data will be a language object of the downloaded language.

##### Example

```
window["MLKitTranslate"].downloadModel("es",
        (data)=>console.log(data),
        (err)=>console.log(err)
})

// prints {"code", "es", "displayName": "Spanish"}
```

#### deleteModel

Delete a specified language model.

##### Parameters

- {string} code - [BCP-47](https://en.wikipedia.org/wiki/IETF_language_tag) language code of the language to delete
- {function} success - callback function which takes a parameter data which will be invoked on success
- {function} error - callback function which takes a parameter err which will be invoked on failure

##### Data format

Success data will be a language object of the deleted language.

##### Example

```
window["MLKitTranslate"].deleteModel("es",
        (data)=>console.log(data),
        (err)=>console.log(err)
})

// prints {"code", "es", "displayName": "Spanish"}
```

## LICENSE

This plugin is licensed under the [MIT License](LICENSE.md)
