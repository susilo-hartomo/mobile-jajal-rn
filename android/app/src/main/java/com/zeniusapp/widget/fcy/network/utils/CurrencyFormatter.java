package com.zeniusapp.widget.fcy.network.utils;

import java.text.NumberFormat;
import java.util.Locale;

public class CurrencyFormatter {

    public static String format(String value) {
        if (value == null || value.trim().isEmpty()) return "-";

        String cleaned = value.replace("Rp", "").trim();

        while (cleaned.endsWith(".") || cleaned.endsWith(",")) {
            cleaned = cleaned.substring(0, cleaned.length() - 1);
        }

        if (cleaned.isEmpty()) return "-";

        if (cleaned.contains(",") && !cleaned.contains(".")) {
            cleaned = cleaned.replace(",", ".");
        }

        int dotIndex = cleaned.indexOf('.');
        String integerPartString;
        String fractionPartString;

        if (dotIndex != -1) {
            integerPartString = cleaned.substring(0, dotIndex);
            fractionPartString = cleaned.substring(dotIndex + 1);
        } else {
            integerPartString = cleaned;
            fractionPartString = null;
        }

        String formattedInteger;
        try {
            double doubleInt = Double.parseDouble(integerPartString);
            NumberFormat numberFormat = NumberFormat.getNumberInstance(new Locale("id", "ID"));
            numberFormat.setMaximumFractionDigits(0);
            formattedInteger = numberFormat.format(doubleInt);
        } catch (Exception e) {
            formattedInteger = integerPartString;
        }

        if (fractionPartString != null && !fractionPartString.isEmpty()) {
            String maxTwo = fractionPartString.length() > 2 ? fractionPartString.substring(0, 2) : fractionPartString;
            String trimmed = maxTwo;
            while (trimmed.endsWith("0")) {
                trimmed = trimmed.substring(0, trimmed.length() - 1);
            }
            if (!trimmed.isEmpty()) {
                return "Rp " + formattedInteger + "," + trimmed;
            }
        }

        return "Rp " + formattedInteger;
    }
}
