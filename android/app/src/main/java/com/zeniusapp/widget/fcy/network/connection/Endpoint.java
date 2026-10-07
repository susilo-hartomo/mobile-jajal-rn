package com.zeniusapp.widget.fcy.network.connection;

import com.google.gson.Gson;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

public class Endpoint {
    private final String path;
    private final HTTPMethod method;
    private final Map<String, String> headers;
    private final byte[] body;

    public Endpoint() {
        this("", HTTPMethod.GET, new HashMap<String, String>(), null);
    }

    public Endpoint(String path, HTTPMethod method, Map<String, String> headers, byte[] body) {
        this.path = path != null ? path : "";
        this.method = method != null ? method : HTTPMethod.GET;
        this.headers = headers != null ? headers : new HashMap<String, String>();
        this.body = body;
    }

    public String getPath() {
        return path;
    }

    public HTTPMethod getMethod() {
        return method;
    }

    public Map<String, String> getHeaders() {
        return headers;
    }

    public byte[] getBody() {
        return body;
    }

    public static <T> Endpoint graphql(String query, T variables) {
        Gson gson = new Gson();
        GraphQLRequest<T> payload = new GraphQLRequest<T>(query, variables);
        String jsonString = gson.toJson(payload);
        byte[] bodyData = jsonString.getBytes(StandardCharsets.UTF_8);

        Map<String, String> headersMap = new HashMap<String, String>();
        headersMap.put("Content-Type", "application/json");
        headersMap.put("Accept", "application/json");

        return new Endpoint("", HTTPMethod.POST, headersMap, bodyData);
    }
}
