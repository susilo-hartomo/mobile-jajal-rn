package com.zeniusapp.widget.fcy.network.client;

import java.util.Arrays;
import java.util.Objects;

public class WidgetFcyModel {
    private final String id;
    private final String currency;
    private final byte[] imageData;
    private final String buyPrice;
    private final String sellPrice;
    private final boolean isActive;

    public WidgetFcyModel(String id, String currency, byte[] imageData, String buyPrice, String sellPrice, boolean isActive) {
        this.id = id;
        this.currency = currency;
        this.imageData = imageData;
        this.buyPrice = buyPrice;
        this.sellPrice = sellPrice;
        this.isActive = isActive;
    }

    public String getId() {
        return id;
    }

    public String getCurrency() {
        return currency;
    }

    public byte[] getImageData() {
        return imageData;
    }

    public String getBuyPrice() {
        return buyPrice;
    }

    public String getSellPrice() {
        return sellPrice;
    }

    public boolean isActive() {
        return isActive;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        WidgetFcyModel that = (WidgetFcyModel) o;
        return isActive == that.isActive &&
                Objects.equals(id, that.id) &&
                Objects.equals(currency, that.currency) &&
                Arrays.equals(imageData, that.imageData) &&
                Objects.equals(buyPrice, that.buyPrice) &&
                Objects.equals(sellPrice, that.sellPrice);
    }

    @Override
    public int hashCode() {
        int result = Objects.hash(id, currency, buyPrice, sellPrice, isActive);
        result = 31 * result + Arrays.hashCode(imageData);
        return result;
    }
}
