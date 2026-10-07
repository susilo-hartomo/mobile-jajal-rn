package com.zeniusapp.widget.fcy.network.connection;

public class NetworkError extends Exception {

    public static class InvalidURL extends NetworkError {
        public InvalidURL() {
            super("URL tidak valid");
        }
    }

    public static class InvalidResponse extends NetworkError {
        public InvalidResponse() {
            super("Response server tidak valid.");
        }
    }

    public static class HttpError extends NetworkError {
        private final int statusCode;
        private final byte[] data;

        public HttpError(int statusCode, byte[] data) {
            super("Request gagal dengan status code " + statusCode + ".");
            this.statusCode = statusCode;
            this.data = data;
        }

        public int getStatusCode() {
            return statusCode;
        }

        public byte[] getData() {
            return data;
        }
    }

    public static class EncodingError extends NetworkError {
        public EncodingError(Throwable cause) {
            super("Encoding error " + (cause != null ? cause.getLocalizedMessage() : ""), cause);
        }
    }

    public static class DecodingError extends NetworkError {
        public DecodingError(Throwable cause) {
            super("Gagal decode response: " + (cause != null ? cause.getLocalizedMessage() : ""), cause);
        }
    }

    public static class TransportError extends NetworkError {
        public TransportError(Throwable cause) {
            super("Network error: " + (cause != null ? cause.getLocalizedMessage() : ""), cause);
        }
    }

    public NetworkError(String message) {
        super(message);
    }

    public NetworkError(String message, Throwable cause) {
        super(message, cause);
    }
}
