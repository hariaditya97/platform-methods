package com.example.battery_level;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import org.apache.commons.codec.binary.Base64;

import java.io.IOException;
import java.util.*;

import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.util.Log;
//import android.util.Base64;
//import java.util.Base64.Decoder;
//import java.util.Base64.Encoder;

//import android.content.Intent;
//import android.os.Bundle;
//import io.flutter.plugin.common.MethodChannel;
//import io.flutter.plugins.GeneratedPluginRegistrant;

import com.facebook.ads.*;

//import java.util.Stack;


public class MainActivity extends FlutterActivity {
    private static final String CHANNEL_BATTERY = "samples.flutter.dev/battery";
    private static final String CHANNEL_MESSAGE= "samples.flutter.dev/message";
    private static final String CHANNEL_INIT = "samples.flutter.dev/initialize_facebook_audience_network";
    private static final String CHANNEL_NATIVE = "samples.flutter.dev/native_ad";
    

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_BATTERY)
                .setMethodCallHandler(
                        (call, result) -> {
                            // Note: this method is invoked on the main thread.
                            if (call.method.equals("getBatteryLevel")) {
                                int batteryLevel = getBatteryLevel();
                                if (batteryLevel != -1) {
                                    result.success(batteryLevel);
                                } else {
                                    result.error("UNAVAILABLE", "Battery level not available.", null);
                                }
                            } else {
                                result.notImplemented();
                            }
                        }
                );
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_MESSAGE)
                .setMethodCallHandler(
                        (call, result) -> {
                            // Note: this method is invoked on the main thread.
                            if (call.method.equals("getPlatformMessage")) {
                                Map<String, String> adMap = new HashMap<String, String>();
                                adMap.put("ok", "hi there!");
                                result.success(adMap);
                            } else {
                                result.notImplemented();
                            }
                        }
                );
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_INIT)
                .setMethodCallHandler(
                        (call, result) -> {
                            // Note: this method is invoked on the main thread.
                            if (call.method.equals("initializeFacebookAudienceNetwork")) {
                                // Initialize the Audience Network SDK
                                AudienceNetworkAds.initialize(this);
                                result.success(true);
                            } else {
                                result.notImplemented();
                            }
                        }
                );
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_NATIVE)
                .setMethodCallHandler(
                        (call, result) -> {
                            // Note: this method is invoked on the main thread.
                            if (call.method.equals("getNativeAd")) {
                                // Initialize the Audience Network SDK
                                final String TAG = "NativeAdActivity".getClass().getSimpleName();

                                NativeAd nativeAd;
                                nativeAd = new NativeAd(this, "294326469073882_295783815594814");

                                NativeAdListener nativeAdListener = new NativeAdListener() {
                                    @Override
                                    public void onMediaDownloaded(Ad ad) {
                                        // Native ad finished downloading all assets
                                    }

                                    @Override
                                    public void onError(Ad ad, AdError adError) {
                                        // Native ad failed to load
                                    }

                                    @Override
                                    public void onAdLoaded(Ad ad) {
                                        // Native ad is loaded and ready to be displayed
                                        if (nativeAd != null && nativeAd == ad) {
                                            Log.d(TAG, "Native Ad successfully loaded from: " + nativeAd.getAdvertiserName());
                                            Map<String, Object> adMap = new HashMap<String, Object>();
                                            adMap.put("title", nativeAd.getAdvertiserName());
                                            adMap.put("body", nativeAd.getAdUntrimmedBodyText());
                                            adMap.put("coverImage", nativeAd.getAdCoverImage().getUrl());
                                            adMap.put("iconImage", nativeAd.getAdIcon().getUrl());
                                            final MethodChannel channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), MainActivity.CHANNEL_NATIVE);
                                            channel.invokeMethod("message", adMap);
                                        }
                                    }

                                    @Override
                                    public void onAdClicked(Ad ad) {
                                        // Native ad clicked
                                    }

                                    @Override
                                    public void onLoggingImpression(Ad ad) {
                                        // Native ad impression
                                    }
                                };

                                // Request an ad
                                nativeAd.loadAd(
                                        nativeAd.buildLoadAdConfig()
                                                .withAdListener(nativeAdListener)
                                                .build());
                                result.success("No Advertisement Found!");
                            } else {
                                result.notImplemented();
                            }
                        }
                );

    }

    private int getBatteryLevel() {
        int batteryLevel = -1;
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
        } else {
            Intent intent = new ContextWrapper(getApplicationContext()).
                    registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
            batteryLevel = (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100) /
                    intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        }

        return batteryLevel;
    }

//    private static String encodeFileToBase64Binary(File file) throws Exception{
//        FileInputStream fileInputStreamReader = new FileInputStream(file);
//        byte[] bytes = new byte[(int)file.length()];
//        fileInputStreamReader.read(bytes);
//        return new String(Base64.encodeBase64(bytes), "UTF-8");
//    }


}

