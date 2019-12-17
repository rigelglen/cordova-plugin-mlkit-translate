package com.rigelglen;

import android.util.Log;

import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.ml.common.modeldownload.FirebaseModelDownloadConditions;
import com.google.firebase.ml.common.modeldownload.FirebaseModelManager;
import com.google.firebase.ml.naturallanguage.FirebaseNaturalLanguage;
import com.google.firebase.ml.naturallanguage.languageid.FirebaseLanguageIdentification;
import com.google.firebase.ml.naturallanguage.translate.FirebaseTranslateLanguage;
import com.google.firebase.ml.naturallanguage.translate.FirebaseTranslateRemoteModel;
import com.google.firebase.ml.naturallanguage.translate.FirebaseTranslator;
import com.google.firebase.ml.naturallanguage.translate.FirebaseTranslatorOptions;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.Set;

import androidx.annotation.NonNull;

public class MLKitTranslate extends CordovaPlugin {
    private FirebaseModelManager modelManager;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        FirebaseApp.initializeApp(cordova.getContext());
        modelManager = FirebaseModelManager.getInstance();
    }

    private void getDownloadedModels(final CallbackContext callbackContext) {
        modelManager.getDownloadedModels(FirebaseTranslateRemoteModel.class).addOnSuccessListener(remoteModels -> {
            List<Language> modelCodes = new ArrayList<>(remoteModels.size());
            for (FirebaseTranslateRemoteModel model : remoteModels) {
                modelCodes.add(new Language(model.getLanguageCode()));
            }
            Collections.sort(modelCodes);
            JSONArray result = arrayToJSON(modelCodes);
            callbackContext.success(result);
        });
    }

    private void getAvailableModels(final CallbackContext callbackContext) {
        final List<Language> languages = new ArrayList<>();
        final Set<Integer> languageIds = FirebaseTranslateLanguage.getAllLanguages();
        for (final Integer languageId : languageIds) {
            String langCode = FirebaseTranslateLanguage.languageCodeForLanguage(languageId);
            Language language = new Language(langCode);
            Log.i("abc", "langCode => " + langCode + " displayName => " + new Locale(langCode).getDisplayName());
            languages.add(language);
        }
        Log.i("abc", languageIds.toString());
        Log.i("abc", languages.toString());
        final JSONArray result = arrayToJSON(languages);
        callbackContext.success(result);
    }

    private FirebaseTranslateRemoteModel getModel(final Integer languageCode) {
        return new FirebaseTranslateRemoteModel.Builder(languageCode).build();
    }

    private void downloadModel(final Language language, final CallbackContext callbackContext) {
        final FirebaseTranslateRemoteModel model = getModel(
                FirebaseTranslateLanguage.languageForLanguageCode(language.getCode()));
        modelManager.download(model, new FirebaseModelDownloadConditions.Builder().build())
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful())
                        callbackContext.success(language.getJSONObject());
                    else
                        callbackContext.error("Could not download language model");
                }).addOnFailureListener(err -> callbackContext.error("Could not download language model"));
    }

    // Deletes a locally stored translation model.
    private void deleteModel(final Language language, final CallbackContext callbackContext) {
        final FirebaseTranslateRemoteModel model = getModel(
                FirebaseTranslateLanguage.languageForLanguageCode(language.getCode()));
        modelManager.deleteDownloadedModel(model).addOnCompleteListener(task -> {
            if (task.isSuccessful())
                callbackContext.success(language.getJSONObject());
            else
                callbackContext.error("Could not delete language model");
        }).addOnFailureListener(err -> callbackContext.error("Could not delete language model"));
    }

    private void translate(String text, Language target, CallbackContext callbackContext) {
        identify(text).addOnSuccessListener(s -> {
            if (!s.equals("und")) {
                Language source = new Language(s);
                translate(text, source, target, callbackContext);
            } else {
                callbackContext.error("Could not identify language");
            }
        }).addOnFailureListener(e -> {
            e.printStackTrace();
            callbackContext.error("Could not identify language");
        });
    }

    private void identifyLanguage(String text, CallbackContext callbackContext) {
        identify(text).addOnSuccessListener(s -> {
            if (!s.equals("und")) {
                Language source = new Language(s);
                callbackContext.success(source.getJSONObject());
            } else {
                callbackContext.error("Could not identify language");
            }
        }).addOnFailureListener(e -> {
            e.printStackTrace();
            callbackContext.error("Could not identify language");
        });

    }

    private Task<String> identify(String text) {
        FirebaseLanguageIdentification languageIdentifier = FirebaseNaturalLanguage.getInstance()
                .getLanguageIdentification();
        return languageIdentifier.identifyLanguage(text);
    }

    @SuppressWarnings("ConstantConditions")
    private void translate(String text, Language source, Language target, CallbackContext callbackContext) {
        try {
            if (source == null || target == null || text == null || text.isEmpty()) {
                callbackContext.error("Invalid parameters");
                return;
            }
            int sourceLangCode = FirebaseTranslateLanguage.languageForLanguageCode(source.getCode());
            int targetLangCode = FirebaseTranslateLanguage.languageForLanguageCode(target.getCode());

            FirebaseTranslatorOptions options = new FirebaseTranslatorOptions.Builder()
                    .setSourceLanguage(sourceLangCode).setTargetLanguage(targetLangCode).build();

            final FirebaseTranslator translator = FirebaseNaturalLanguage.getInstance().getTranslator(options);

            final Task<String> translateText = translator.downloadModelIfNeeded().continueWithTask(task -> {
                if (task.isSuccessful()) {
                    return translator.translate(text);
                } else {
                    Exception e = task.getException();
                    if (e == null) {
                        e = new Exception("Unknown Error");
                    }
                    return Tasks.forException(e);
                }
            });

            translateText.addOnCompleteListener(task -> {
                if (task.isSuccessful()) {
                    callbackContext.success(task.getResult());
                } else {
                    callbackContext.error("Translation failed");
                }
            });

        } catch (Exception e) {
            e.printStackTrace();
            callbackContext.error(e.getMessage());
        }
    }

    private JSONArray arrayToJSON(List<Language> arrayList) {
        JSONArray jsonArray = new JSONArray();
        for (int i = 0; i < arrayList.size(); i++) {
            jsonArray.put(arrayList.get(i).getJSONObject());
        }
        return jsonArray;
    }

    @Override
    public boolean execute(final String action, final JSONArray args, final CallbackContext callbackContext) {
        switch (action) {
        case "identifyLanguage":
            cordova.getThreadPool().execute(() -> {
                try {
                    String text = args.getString(0);
                    identifyLanguage(text, callbackContext);
                } catch (Exception e) {
                    e.printStackTrace();
                    callbackContext.error("Invalid parameters");
                }
            });
            return true;
        case "identifyTranslate":
            cordova.getThreadPool().execute(() -> {
                try {
                    String text = args.getString(0);
                    String targetLang = args.getString(1);
                    Language target = new Language(targetLang);
                    translate(text, target, callbackContext);
                } catch (Exception e) {
                    e.printStackTrace();
                    callbackContext.error("Invalid parameters");
                }
            });
            return true;
        case "translate":
            cordova.getThreadPool().execute(() -> {
                try {
                    String text = args.getString(0);
                    String sourceLang = args.getString(1);
                    Language source = new Language(sourceLang);
                    String targetLang = args.getString(2);
                    Language target = new Language(targetLang);
                    translate(text, source, target, callbackContext);
                } catch (Exception e) {
                    e.printStackTrace();
                    callbackContext.error("Invalid parameters");
                }
            });
            return true;
        case "getDownloadedModels":
            cordova.getThreadPool().execute(() -> getDownloadedModels(callbackContext));
            return true;
        case "downloadModel":
            cordova.getThreadPool().execute(() -> {
                try {
                    final String langCode = args.getString(0);
                    final Language language = new Language(langCode);
                    downloadModel(language, callbackContext);
                } catch (final Exception e) {
                    callbackContext.error("Invalid parameters");
                    final PluginResult r = new PluginResult(PluginResult.Status.ERROR);
                    callbackContext.sendPluginResult(r);
                }
            });
            return true;
        case "deleteModel":
            cordova.getThreadPool().execute(() -> {

                try {
                    final String langCode = args.getString(0);
                    final Language language = new Language(langCode);
                    deleteModel(language, callbackContext);
                } catch (final Exception e) {
                    callbackContext.error("Invalid parameters");
                    final PluginResult r = new PluginResult(PluginResult.Status.ERROR);
                    callbackContext.sendPluginResult(r);
                }
            });
            return true;
        case "getAvailableModels":
            cordova.getThreadPool().execute(() -> {
                try {
                    getAvailableModels(callbackContext);
                } catch (final Exception e) {
                    e.printStackTrace();
                    callbackContext.error(e.getMessage());
                }
            });
            return true;
        }

        return false;
    }

    static class Language implements Comparable<Language>, Serializable {
        private final String code;
        private final String displayName;
        private static final long serialVersionUID = 1L;

        Language(final String code) {
            this.code = code;
            this.displayName = new Locale(this.code).getDisplayName();
        }

        String getDisplayName() {
            return displayName;
        }

        String getCode() {
            return code;
        }

        public boolean equals(final Object o) {
            if (o == this) {
                return true;
            }

            if (!(o instanceof Language)) {
                return false;
            }

            final Language otherLang = (Language) o;
            return otherLang.code.equals(code);
        }

        @NonNull
        public String toString() {
            return code + " - " + getDisplayName();
        }

        JSONObject getJSONObject() {
            JSONObject obj = new JSONObject();
            try {
                obj.put("code", code);
                obj.put("displayName", displayName);
            } catch (JSONException e) {
                Log.i("abc", "DefaultListItem.toString JSONException: " + e.getMessage());
            }
            return obj;
        }

        @Override
        public int hashCode() {
            return code.hashCode();
        }

        @Override
        public int compareTo(@NonNull final Language o) {
            return this.getDisplayName().compareTo(o.getDisplayName());
        }

    }

}
