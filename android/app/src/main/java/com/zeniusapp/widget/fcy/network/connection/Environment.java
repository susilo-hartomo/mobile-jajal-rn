package com.zeniusapp.widget.fcy.network.connection;

import com.zeniusapp.BuildConfig;

public class Environment {
    public static String getApiURL() {
        String url = BuildConfig.BASE_API_URL;
        if (url == null || url.trim().isEmpty()) {
            throw new IllegalStateException("BASE_API_URL tidak ditemukan di file .env");
        }
        return url;
    }
}
