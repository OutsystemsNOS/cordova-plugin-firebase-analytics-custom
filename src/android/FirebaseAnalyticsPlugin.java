package by.chemerisuk.cordova.firebase;

import android.content.Context;
import android.os.Bundle;
import android.util.Log;

import by.chemerisuk.cordova.support.CordovaMethod;
import by.chemerisuk.cordova.support.ReflectiveCordovaPlugin;

import com.google.firebase.analytics.FirebaseAnalytics;

import org.apache.cordova.CallbackContext;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONArray;

import java.util.Iterator;
import java.util.Map;
import java.util.EnumMap;


public class FirebaseAnalyticsPlugin extends ReflectiveCordovaPlugin {
    private static final String TAG = "FirebaseAnalyticsPlugin";

    private FirebaseAnalytics firebaseAnalytics;

    @Override
    protected void pluginInitialize() {
        Log.d(TAG, "Starting Firebase Analytics plugin");

        Context context = this.cordova.getActivity().getApplicationContext();

        this.firebaseAnalytics = FirebaseAnalytics.getInstance(context);
    }

    @CordovaMethod
    private void logEvent(String name, JSONObject params, CallbackContext callbackContext) throws JSONException {
        this.firebaseAnalytics.logEvent(name, parse(params));

        callbackContext.success();
    }
    
    @CordovaMethod
    private void setConsent(String consentTypeAnalyticsStorage, String consentTypeAdStorage, String consentTypeAdUserData, String consentTypeAdPersonalization, CallbackContext callbackContext) throws JSONException {

        Map<FirebaseAnalytics.ConsentType, FirebaseAnalytics.ConsentStatus> consentMap = new EnumMap<>(FirebaseAnalytics.ConsentType.class);
        mapConsentStringToMap(consentMap, FirebaseAnalytics.ConsentType.ANALYTICS_STORAGE, consentTypeAnalyticsStorage);
        mapConsentStringToMap(consentMap, FirebaseAnalytics.ConsentType.AD_STORAGE, consentTypeAdStorage);
        mapConsentStringToMap(consentMap, FirebaseAnalytics.ConsentType.AD_USER_DATA, consentTypeAdUserData);
        mapConsentStringToMap(consentMap, FirebaseAnalytics.ConsentType.AD_PERSONALIZATION, consentTypeAdPersonalization);

        this.firebaseAnalytics.setConsent(consentMap);

        callbackContext.success();
    }
    private void mapConsentStringToMap(Map<FirebaseAnalytics.ConsentType, FirebaseAnalytics.ConsentStatus> consentMap, FirebaseAnalytics.ConsentType consentType, String consentString) {
        FirebaseAnalytics.ConsentStatus consentStatus = "true".equalsIgnoreCase(consentString) ?
                FirebaseAnalytics.ConsentStatus.GRANTED : FirebaseAnalytics.ConsentStatus.DENIED;

        consentMap.put(consentType, consentStatus);
    }

    @CordovaMethod
    private void setUserId(String userId, CallbackContext callbackContext) {
        this.firebaseAnalytics.setUserId(userId);

        callbackContext.success();
    }

    @CordovaMethod
    private void setUserProperty(String name, String value, CallbackContext callbackContext) {
        this.firebaseAnalytics.setUserProperty(name, value);

        callbackContext.success();
    }

    @CordovaMethod
    private void resetAnalyticsData(CallbackContext callbackContext) {
        this.firebaseAnalytics.resetAnalyticsData();

        callbackContext.success();
    }

    @CordovaMethod
    private void setEnabled(boolean enabled, CallbackContext callbackContext) {
        this.firebaseAnalytics.setAnalyticsCollectionEnabled(enabled);

        callbackContext.success();
    }

    @CordovaMethod
    private void setCurrentScreen(String screenName, CallbackContext callbackContext) {
        Bundle bundle = new Bundle();
        bundle.putString(FirebaseAnalytics.Param.SCREEN_NAME, screenName);
        firebaseAnalytics.logEvent(FirebaseAnalytics.Event.SCREEN_VIEW, bundle);

        callbackContext.success();
    }  
    
    @CordovaMethod
    private void setScreenView(String screenName, String screenClass, String topic, CallbackContext callbackContext) {
        Bundle bundle = new Bundle();
        bundle.putString(FirebaseAnalytics.Param.SCREEN_NAME, screenName);
        bundle.putString(FirebaseAnalytics.Param.SCREEN_CLASS, screenClass);
        firebaseAnalytics.logEvent(FirebaseAnalytics.Event.SCREEN_VIEW, bundle);

        callbackContext.success();
    }

    @CordovaMethod
    private void setDefaultEventParameters(JSONObject params, CallbackContext callbackContext) throws JSONException {
        this.firebaseAnalytics.setDefaultEventParameters(parse(params));

        callbackContext.success();
    }

    @CordovaMethod
    private void requestTrackingAuthorization(JSONObject params, CallbackContext callbackContext) throws JSONException {
        //Does nothing. This is an iOS specific method.
        callbackContext.success();
    }

    private static Bundle parse(JSONObject params) throws JSONException {
        Bundle bundle = new Bundle();
        Iterator<String> it = params.keys();

        while (it.hasNext()) {
            String key = it.next();
            Object value = params.get(key);

            if (value instanceof String) {
                bundle.putString(key, (String)value);
            } else if (value instanceof Integer) {
                bundle.putInt(key, (Integer)value);
            } else if (value instanceof Double) {
                bundle.putDouble(key, (Double)value);
            } else if (value instanceof Long) {
                bundle.putLong(key, (Long)value);
            } else {
                Log.w(TAG, "Value for key " + key + " not one of (String, Integer, Double, Long)");
            }
        }

        return bundle;
    }
}
