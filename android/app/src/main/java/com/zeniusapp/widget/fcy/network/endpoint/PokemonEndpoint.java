package com.zeniusapp.widget.fcy.network.endpoint;

import com.zeniusapp.widget.fcy.network.connection.Endpoint;
import java.util.HashMap;
import java.util.Map;

public class PokemonEndpoint {
    public static Endpoint randomPokemon(int offset) {
        String query = "query getPokemons($limit: Int, $offset: Int) {\n" +
                "  pokemons(limit: $limit, offset: $offset) {\n" +
                "    results {\n" +
                "      id\n" +
                "      name\n" +
                "      image\n" +
                "    }\n" +
                "  }\n" +
                "}";
        Map<String, Object> variables = new HashMap<String, Object>();
        variables.put("limit", 1);
        variables.put("offset", offset);
        return Endpoint.graphql(query, variables);
    }

    public static Endpoint pokemonDetail(String name) {
        String query = "query getPokemon($name: String!) {\n" +
                "  pokemon(name: $name) {\n" +
                "    sprites {\n" +
                "      front_default\n" +
                "    }\n" +
                "  }\n" +
                "}";
        Map<String, Object> variables = new HashMap<String, Object>();
        variables.put("name", name != null ? name.toLowerCase() : "");
        return Endpoint.graphql(query, variables);
    }
}
