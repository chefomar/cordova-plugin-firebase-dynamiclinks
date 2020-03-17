package by.chemerisuk.cordova.firebase;

import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import com.google.android.gms.tasks.Continuation;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.dynamiclinks.DynamicLink;
import com.google.firebase.dynamiclinks.DynamicLink.AndroidParameters;
import com.google.firebase.dynamiclinks.DynamicLink.GoogleAnalyticsParameters;
import com.google.firebase.dynamiclinks.DynamicLink.IosParameters;
import com.google.firebase.dynamiclinks.DynamicLink.ItunesConnectAnalyticsParameters;
import com.google.firebase.dynamiclinks.DynamicLink.NavigationInfoParameters;
import com.google.firebase.dynamiclinks.DynamicLink.SocialMetaTagParameters;
import com.google.firebase.dynamiclinks.FirebaseDynamicLinks;
import com.google.firebase.dynamiclinks.PendingDynamicLinkData;
import com.google.firebase.dynamiclinks.ShortDynamicLink;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.json.JSONException;
import org.json.JSONObject;

import by.chemerisuk.cordova.support.CordovaMethod;
import by.chemerisuk.cordova.support.ReflectiveCordovaPlugin;


public class FirebaseDynamicLinksPlugin extends ReflectiveCordovaPlugin {
    private static final String TAG = "FirebaseDynamicLinks";

    private FirebaseDynamicLinks firebaseDynamicLinks;
    private String domainUriPrefix;
    private CallbackContext dynamicLinkCallback;

    @Override
    protected void pluginInitialize() {
        Log.d(TAG, "Starting Firebase Dynamic Links plugin");

        this.firebaseDynamicLinks = FirebaseDynamicLinks.getInstance();
        this.domainUriPrefix = this.preferences.getString("DYNAMIC_LINK_URIPREFIX", "");
    }

    @Override
    public void onNewIntent(Intent intent) {
        if (this.dynamicLinkCallback != null) {
            respondWithDynamicLink(intent);
        }
    }

    @CordovaMethod
    private void onDynamicLink(CallbackContext callbackContext) {
        this.dynamicLinkCallback = callbackContext;

        respondWithDynamicLink(cordova.getActivity().getIntent());
    }

    private void respondWithDynamicLink(Intent intent) {
        this.firebaseDynamicLinks.getDynamicLink(intent)
                .continueWith(new Continuation<PendingDynamicLinkData, JSONObject>() {
                    @Override
                    public JSONObject then(Task<PendingDynamicLinkData> task) throws JSONException {
                        PendingDynamicLinkData data = task.getResult();

                        JSONObject result = new JSONObject();
                        result.put("deepLink", data.getLink());
                        result.put("clickTimestamp", data.getClickTimestamp());
                        result.put("minimumAppVersion", data.getMinimumAppVersion());

                        if (dynamicLinkCallback != null) {
                            PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, result);
                            pluginResult.setKeepCallback(true);
                            dynamicLinkCallback.sendPluginResult(pluginResult);
                        }

                        return result;
                    }
                });
    }
}
