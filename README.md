# Cordova MLKit Translation

[![npm](https://img.shields.io/npm/v/cordova-plugin-mlkit-translate?style=for-the-badge)](https://www.npmjs.com/package/cordova-plugin-mlkit-translate)
[![npm](https://img.shields.io/npm/dt/cordova-plugin-mlkit-translate?style=for-the-badge)](https://www.npmjs.com/package/cordova-plugin-mlkit-translate)
[![NPM](https://img.shields.io/npm/l/cordova-plugin-mlkit-translate?style=for-the-badge)](LICENSE)

Cordova Plugin that implements MLKit Translation and Language Identification features.

Supports both iOS and Android.

#### Table of Contents

 - [Installation](#installation)
 	- [Version support](#version-support)
 	- [Dependencies](#dependencies)
 - [Variables](#variables)
 - [API](#api)
 	- [translate](#translate)
 	- [identifyLanguage](#identifylanguage) 	 	
 	- [getDownloadedModels](#getdownloadedmodels)
 	- [getAvailableModels](#getavailablemodels)
 	- [downloadModel](#downloadmodel)
 	- [deleteModel](#deletemodel)


## Installation

- Install the plugin by adding it to your project's config.xml:

```
<plugin name="cordova-plugin-mlkit-translate" spec="latest" />
```

or run

```
cordova plugin add cordova-plugin-mlkit-translate
```

- *(Optional) If you're using ionic, make sure you use the Ionic native wrapper.*
```
npm install @ionic-native/mlkit-translate
```

- **Make sure you have your google-services.json or GoogleService-Info.plist file in your project's root folder.**

### Version Support

- cordova `>=9`
- cordova-android `>=8`
- cordova-ios `>=5`

### Dependencies

This plugin depends on [cordova-plugin-firebasex](https://github.com/dpa99c/cordova-plugin-firebasex) on android.


## Variables
These variables are android only

|                  Variable                  | Default |
| :----------------------------------------: | :-----: |
|    FIREBASE_ML_NATURAL_LANGUAGE_VERSION    | 22.0.0  |
| FIREBASE_ML_NATURAL_LANGUAGE_MODEL_VERSION | 20.0.7  |
|  FIREBASE_ML_NATURAL_LANGUAGE_ID_VERSION   | 20.0.7  |

## API

You can access all these methods via the window["MLKitTranslate"] object. 

If you're using the Ionic Native wrapper, then add the plugin to your module

```
import { MLKitTranslate } from '@ionic-native/mlkit-translate/ngx';
@NgModule({
  declarations: [AppComponent],
  entryComponents: [],
  imports: [
    ...
  ],
  providers: [
    ...
    MLKitTranslate,
    ...
  ],
  bootstrap: [AppComponent]
})
export class AppModule {}
```

And then inject it into the component you want.

```
import { MLKitTranslate } from '@ionic-native/ml-kit-translate';

constructor(private mlkitTranslate: MLKitTranslate) { }
...
```

#### translate

Translates text from one language to another. Requires the source and target languages need to be downloaded. If not the languages are downloaded in the background automatically.

##### Parameters

- {string} text - text to be translated
- {string} targetLanguage - language code of the language to translate to
- {string} sourceLanguage - (optional) language code of the language to translate from, if not present the language is inferred.
- {function} success - (promisified in ionic native wrapper) callback function which takes a parameter data which will be invoked on success
- {function} error - (promisified in ionic native wrapper) callback function which takes a parameter err which will be invoked on failure

##### Example

```
window["MLKitTranslate"].translate("hello", "es", "en",
    (data)=>console.log(`Translated text is ${data}`),
    (err)=>console.log("Something went wrong with the translation")
})
// prints Translated text is hola
```

with Ionic Native

```
this.mlkitTranslate.translate("hello", "es", "en").then(translatedText=>{
    console.log(console.log(`Translated text is ${translatedText}`))
})
// prints Translated text is hola
```

#### identifyLanguage

Determines the language of a string of text.

##### Parameters

- {string} text - text to be identified
- {function} success - (promisified in ionic native wrapper) callback function which takes a parameter data which will be invoked on success
- {function} error - (promisified in ionic native wrapper) callback function which takes a parameter err which will be invoked on failure

#### Data format

Success data will be a language object with two properties

- {string} code - [BCP-47](https://en.wikipedia.org/wiki/IETF_language_tag) language code
- {string} displayName - Name of the language

##### Example

```
window["MLKitTranslate"].identifyLanguage("hello",
    (data)=>console.log("Identified text is",  data),
    (err)=>console.log("Something went wrong with the translation")
})

// prints Identified text is {"code": "en", "displayName": "English"}
```

or with Ionic Native

```
this.mlkitTranslate.identifyLanguage("hello").then(lang=>{
    console.log("Identified text is ", lang);
})

// prints Identified text is {"code": "en", "displayName": "English"}
```

#### getDownloadedModels

List of language models that have been downloaded to the device.

##### Parameters

- {function} success - (promisified in ionic native wrapper) callback function which takes a parameter data which will be invoked on success
- {function} error - (promisified in ionic native wrapper) callback function which takes a parameter err which will be invoked on failure

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

or with Ionic Native

```
this.mlkitTranslate.getDownloadedModels().then(langs=>{
    console.log(langs);
})

// prints [{"code": "en", "displayName": "English"}]
```

#### getAvailableModels

List of language models that can be downloaded.

##### Parameters

- {function} success - (promisified in ionic native wrapper) callback function which takes a parameter data which will be invoked on success
- {function} error - (promisified in ionic native wrapper) callback function which takes a parameter err which will be invoked on failure

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

or with Ionic Native

```
this.mlkitTranslate.getAvailableModels().then(langs=>{
    console.log(langs);
})

// prints [{"code": "en", "displayName": "English"}, {"code", "es", "displayName": "Spanish"}, ...]
```

#### downloadModel

Downloads a specified language model.

##### Parameters

- {string} code - [BCP-47](https://en.wikipedia.org/wiki/IETF_language_tag) language code of the language to download
- {function} success - (promisified in ionic native wrapper) callback function which takes a parameter data which will be invoked on success
- {function} error - (promisified in ionic native wrapper) callback function which takes a parameter err which will be invoked on failure

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

or with Ionic Native

```
this.mlkitTranslate.downloadModel("es").then(lang=>{
    console.log(langs);
})

// prints {"code", "es", "displayName": "Spanish"}
```

#### deleteModel

Delete a specified language model.

##### Parameters

- {string} code - [BCP-47](https://en.wikipedia.org/wiki/IETF_language_tag) language code of the language to delete
- {function} success - (promisified in ionic native wrapper) callback function which takes a parameter data which will be invoked on success
- {function} error - (promisified in ionic native wrapper) callback function which takes a parameter err which will be invoked on failure

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

or with Ionic Native

```
this.mlkitTranslate.deleteModel("es").then(lang=>{
    console.log(langs);
})

// prints {"code", "es", "displayName": "Spanish"}
```

## LICENSE

This plugin is licensed under the [MIT License](LICENSE)
