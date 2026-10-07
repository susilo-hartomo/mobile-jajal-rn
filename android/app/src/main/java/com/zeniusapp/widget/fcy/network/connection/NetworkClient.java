package com.zeniusapp.widget.fcy.network.connection;

import com.google.gson.Gson;
import java.io.IOException;
import java.lang.reflect.Type;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class NetworkClient {
    private static NetworkClient instance;

    public static synchronized NetworkClient getInstance() {
        if (instance == null) {
            instance = new NetworkClient();
        }
        return instance;
    }

    public static NetworkClient getShared() {
        return getInstance();
    }

    private final String baseURL;
    private final OkHttpClient client;
    private final Gson gson;

    public NetworkClient() {
        this(8, 10, new Gson(), null);
    }

    public NetworkClient(long requestTimeoutSeconds, long resourceTimeoutSeconds, Gson gson, OkHttpClient customClient) {
        this.baseURL = Environment.getApiURL();
        this.gson = gson != null ? gson : new Gson();
        if (customClient != null) {
            this.client = customClient;
        } else {
            this.client = new OkHttpClient.Builder()
                .connectTimeout(requestTimeoutSeconds, TimeUnit.SECONDS)
                .readTimeout(resourceTimeoutSeconds, TimeUnit.SECONDS)
                .build();
        }
    }

    public <T> T request(Endpoint endpoint, Type typeToken) throws NetworkError {
        String url;
        if (endpoint.getPath() == null || endpoint.getPath().isEmpty()) {
            url = baseURL;
        } else {
            String cleanBase = baseURL.endsWith("/") ? baseURL.substring(0, baseURL.length() - 1) : baseURL;
            String cleanPath = endpoint.getPath().startsWith("/") ? endpoint.getPath() : "/" + endpoint.getPath();
            url = cleanBase + cleanPath;
        }

        Request.Builder requestBuilder = new Request.Builder().url(url);

        MediaType mediaType = MediaType.parse("application/json; charset=utf-8");
        byte[] bodyBytes = endpoint.getBody();
        RequestBody requestBody = bodyBytes != null ? RequestBody.create(mediaType, bodyBytes) : null;

        HTTPMethod method = endpoint.getMethod();
        if (method == HTTPMethod.GET) {
            requestBuilder.get();
        } else if (method == HTTPMethod.POST) {
            requestBuilder.post(requestBody != null ? requestBody : RequestBody.create(mediaType, ""));
        } else if (method == HTTPMethod.PUT) {
            requestBuilder.put(requestBody != null ? requestBody : RequestBody.create(mediaType, ""));
        } else if (method == HTTPMethod.PATCH) {
            requestBuilder.patch(requestBody != null ? requestBody : RequestBody.create(mediaType, ""));
        } else if (method == HTTPMethod.DELETE) {
            if (requestBody != null) {
                requestBuilder.delete(requestBody);
            } else {
                requestBuilder.delete();
            }
        }

        for (Map.Entry<String, String> entry : endpoint.getHeaders().entrySet()) {
            requestBuilder.header(entry.getKey(), entry.getValue());
        }

        Response response;
        try {
            response = client.newCall(requestBuilder.build()).execute();
        } catch (IOException e) {
            throw new NetworkError.TransportError(e);
        }

        int statusCode = response.code();
        byte[] responseBodyBytes = null;
        try {
            if (response.body() != null) {
                responseBodyBytes = response.body().bytes();
            }
        } catch (IOException e) {
            throw new NetworkError.TransportError(e);
        }

        if (!response.isSuccessful()) {
            throw new NetworkError.HttpError(statusCode, responseBodyBytes);
        }

        if (responseBodyBytes == null || responseBodyBytes.length == 0) {
            throw new NetworkError.InvalidResponse();
        }

        String jsonString = new String(responseBodyBytes, StandardCharsets.UTF_8);

        try {
            T decoded = gson.fromJson(jsonString, typeToken);
            if (decoded == null) {
                throw new NetworkError.DecodingError(new NullPointerException("Decoded object is null"));
            }
            return decoded;
        } catch (Exception e) {
            throw new NetworkError.DecodingError(e);
        }
    }
}
