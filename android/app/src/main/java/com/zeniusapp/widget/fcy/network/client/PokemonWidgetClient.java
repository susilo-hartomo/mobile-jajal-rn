package com.zeniusapp.widget.fcy.network.client;

import com.google.gson.reflect.TypeToken;
import com.zeniusapp.widget.fcy.network.connection.NetworkClient;
import com.zeniusapp.widget.fcy.network.endpoint.PokemonEndpoint;
import java.lang.reflect.Type;
import java.util.List;
import java.util.Random;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

public class PokemonWidgetClient {

    public static class PokemonDetailResponse {
        private Payload data;
        public Payload getData() { return data; }

        public static class Payload {
            private Pokemon pokemon;
            public Pokemon getPokemon() { return pokemon; }
        }
        public static class Pokemon {
            private Sprites sprites;
            public Sprites getSprites() { return sprites; }
        }
        public static class Sprites {
            private String front_default;
            public String getFront_default() { return front_default; }
        }
    }

    public static class RandomPokemonResponse {
        private PokemonData data;
        public PokemonData getData() { return data; }

        public static class PokemonData {
            private PokemonResult pokemons;
            public PokemonResult getPokemons() { return pokemons; }
        }
        public static class PokemonResult {
            private List<PokemonItem> results;
            public List<PokemonItem> getResults() { return results; }
        }
        public static class PokemonItem {
            private Integer id;
            private String name;
            private String image;

            public Integer getId() { return id; }
            public String getName() { return name; }
            public String getImage() { return image; }
        }
    }

    public static class RandomPokemonResult {
        private final String name;
        private final String imageURL;

        public RandomPokemonResult(String name, String imageURL) {
            this.name = name;
            this.imageURL = imageURL;
        }

        public String getName() { return name; }
        public String getImageURL() { return imageURL; }
    }

    // MARK: - Fetch Random Gen-1 Pokemon
    public static RandomPokemonResult fetchRandomPokemon() {
        try {
            int offset = new Random().nextInt(151);
            Type typeToken = new TypeToken<RandomPokemonResponse>() {}.getType();
            RandomPokemonResponse response = NetworkClient.getShared().request(
                PokemonEndpoint.randomPokemon(offset),
                typeToken
            );

            if (response != null && response.getData() != null && response.getData().getPokemons() != null) {
                List<RandomPokemonResponse.PokemonItem> results = response.getData().getPokemons().getResults();
                if (results != null && !results.isEmpty()) {
                    RandomPokemonResponse.PokemonItem item = results.get(0);
                    if (item.getImage() != null && !item.getImage().isEmpty()) {
                        return new RandomPokemonResult(item.getName(), item.getImage());
                    }
                }
            }
        } catch (Exception e) {
            System.out.println("[PokemonWidgetClient] fetchRandomPokemon failed: " + e.getLocalizedMessage());
        }
        return null;
    }

    // MARK: - Fetch Pokemon Sprite URL by Name
    public static String fetchSpriteURL(String name) {
        try {
            Type typeToken = new TypeToken<PokemonDetailResponse>() {}.getType();
            PokemonDetailResponse response = NetworkClient.getShared().request(
                PokemonEndpoint.pokemonDetail(name),
                typeToken
            );

            if (response != null && response.getData() != null && response.getData().getPokemon() != null) {
                PokemonDetailResponse.Sprites sprites = response.getData().getPokemon().getSprites();
                if (sprites != null) {
                    return sprites.getFront_default();
                }
            }
        } catch (Exception e) {
            System.out.println("[PokemonWidgetClient] fetchSpriteURL failed: " + e.getLocalizedMessage());
        }
        return null;
    }

    // MARK: - Download Image Data
    public static byte[] downloadImageData(String urlString) {
        try {
            OkHttpClient client = new OkHttpClient();
            Request request = new Request.Builder().url(urlString).build();
            Response response = client.newCall(request).execute();
            if (response.isSuccessful() && response.body() != null) {
                byte[] bytes = response.body().bytes();
                if (bytes.length <= 500_000) {
                    return bytes;
                }
            }
        } catch (Exception e) {
            System.out.println("[PokemonWidgetClient] downloadImageData failed: " + e.getLocalizedMessage());
        }
        return null;
    }
}
