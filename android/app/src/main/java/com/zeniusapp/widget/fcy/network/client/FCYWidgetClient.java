package com.zeniusapp.widget.fcy.network.client;

import com.google.gson.annotations.SerializedName;
import com.google.gson.reflect.TypeToken;
import com.zeniusapp.widget.fcy.network.connection.Endpoint;
import com.zeniusapp.widget.fcy.network.connection.NetworkClient;
import com.zeniusapp.widget.fcy.network.endpoint.FcyRateEndpoint;
import com.zeniusapp.widget.fcy.network.utils.CurrencyFormatter;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.Executors;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

public class FCYWidgetClient {

    public interface Callback<T> {
        void onResult(T result);
    }

    public static class FcyRateItem {
        @SerializedName("_id")
        private String id;
        private String image;
        private String currency;
        private String retailRateType;
        private String retailRateDesc;
        private String buyRate;
        private String sellRate;
        private String revaluationRate;
        private String lastMaintainedAt;
        private String modifiedAt;
        private String createdAt;

        public String getId() { return id; }
        public String getImage() { return image; }
        public String getCurrency() { return currency; }
        public String getRetailRateType() { return retailRateType; }
        public String getRetailRateDesc() { return retailRateDesc; }
        public String getBuyRate() { return buyRate; }
        public String getSellRate() { return sellRate; }
        public String getRevaluationRate() { return revaluationRate; }
        public String getLastMaintainedAt() { return lastMaintainedAt; }
        public String getModifiedAt() { return modifiedAt; }
        public String getCreatedAt() { return createdAt; }
    }

    public static class FcyRateResponse {
        private String status;
        private String message;
        private List<FcyRateItem> data;

        public String getStatus() { return status; }
        public String getMessage() { return message; }
        public List<FcyRateItem> getData() { return data; }
    }

    // MARK: - Fetch Foreign Exchange Rates (REST GET)
    public static List<FcyRateItem> fetchForeignExchangeRates() {
        Endpoint endpoint = FcyRateEndpoint.foreignExchangeRates();

        // Attempt 1: Decode direct JSON Array [ { ... } ]
        try {
            Type arrayTypeToken = new TypeToken<List<FcyRateItem>>() {}.getType();
            List<FcyRateItem> items = NetworkClient.getShared().request(endpoint, arrayTypeToken);
            if (items != null) {
                System.out.println("[FCYWidgetClient] Direct array decoding succeeded, count: " + items.size());
                return sortRates(items);
            }
        } catch (Exception e) {
            System.out.println("[FCYWidgetClient] Direct array decoding failed: " + e.getLocalizedMessage());
        }

        // Attempt 2: Decode JSON Object wrapper { "data": [ { ... } ] } (Hanya jika Attempt 1 gagal)
        try {
            Type objectTypeToken = new TypeToken<FcyRateResponse>() {}.getType();
            FcyRateResponse response = NetworkClient.getShared().request(endpoint, objectTypeToken);
            if (response != null && response.getData() != null) {
                System.out.println("[FCYWidgetClient] Object wrapper decoding succeeded");
                return sortRates(response.getData());
            }
        } catch (Exception e) {
            System.out.println("[FCYWidgetClient] Object wrapper decoding failed: " + e.getLocalizedMessage());
        }

        return Collections.emptyList();
    }

    private static List<FcyRateItem> sortRates(List<FcyRateItem> items) {
        List<FcyRateItem> sorted = new ArrayList<FcyRateItem>(items);
        Collections.sort(sorted, new Comparator<FcyRateItem>() {
            @Override
            public int compare(FcyRateItem o1, FcyRateItem o2) {
                String c1 = o1.getCurrency() != null ? o1.getCurrency() : "";
                String c2 = o2.getCurrency() != null ? o2.getCurrency() : "";
                return c1.compareToIgnoreCase(c2);
            }
        });
        return sorted;
    }

    // MARK: - Download Image Helper
    public static byte[] fetchImage(String urlString) {
        if (urlString == null || urlString.trim().isEmpty()) return null;
        try {
            OkHttpClient client = new OkHttpClient();
            Request request = new Request.Builder().url(urlString).build();
            Response response = client.newCall(request).execute();
            if (response.isSuccessful() && response.body() != null) {
                return response.body().bytes();
            }
        } catch (Exception e) {
            System.out.println("[FCYWidgetClient] fetchImage failed: " + e.getLocalizedMessage());
        }
        return null;
    }

    public static List<WidgetFcyModel> getPlaceholderRates() {
        List<WidgetFcyModel> placeholders = new ArrayList<WidgetFcyModel>();
        placeholders.add(new WidgetFcyModel("USD", "USD", null, CurrencyFormatter.format("16078.0000000"), CurrencyFormatter.format("16240.0000000"), true));
        placeholders.add(new WidgetFcyModel("EUR", "EUR", null, CurrencyFormatter.format("17685.1400000"), CurrencyFormatter.format("17862.7500000"), true));
        placeholders.add(new WidgetFcyModel("SGD", "SGD", null, CurrencyFormatter.format("12117.0000000"), CurrencyFormatter.format("12241.0000000"), true));
        placeholders.add(new WidgetFcyModel("JPY", "JPY", null, CurrencyFormatter.format("112.9200000"), CurrencyFormatter.format("114.0600000"), true));
        placeholders.add(new WidgetFcyModel("AUD", "AUD", null, CurrencyFormatter.format("10792.0000000"), CurrencyFormatter.format("10904.0400000"), true));
        return placeholders;
    }

    public static List<WidgetFcyModel> getWidgetFcyRates() {
        List<FcyRateItem> items = fetchForeignExchangeRates();
        if (items.isEmpty()) return getPlaceholderRates();

        List<WidgetFcyModel> resultRates = new ArrayList<WidgetFcyModel>();
        for (FcyRateItem item : items) {
            byte[] imageData = item.getImage() != null ? fetchImage(item.getImage()) : null;
            String buyPrice = CurrencyFormatter.format(item.getBuyRate());
            String sellPrice = CurrencyFormatter.format(item.getSellRate());

            String id = item.getId() != null ? item.getId() : UUID.randomUUID().toString();
            String currency = item.getCurrency() != null ? item.getCurrency() : "N/A";

            resultRates.add(new WidgetFcyModel(id, currency, imageData, buyPrice, sellPrice, true));
        }

        return resultRates.isEmpty() ? getPlaceholderRates() : resultRates;
    }

    // Java Async Callback Helper
    public static void getWidgetFcyRatesAsync(final Callback<List<WidgetFcyModel>> callback) {
        Executors.newSingleThreadExecutor().execute(new Runnable() {
            @Override
            public void run() {
                final List<WidgetFcyModel> rates = getWidgetFcyRates();
                callback.onResult(rates);
            }
        });
    }
}
