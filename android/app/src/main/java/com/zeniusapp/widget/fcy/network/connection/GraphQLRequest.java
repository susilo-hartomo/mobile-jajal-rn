package com.zeniusapp.widget.fcy.network.connection;

public class GraphQLRequest<V> {
    private final String query;
    private final V variables;

    public GraphQLRequest(String query, V variables) {
        this.query = query;
        this.variables = variables;
    }

    public String getQuery() {
        return query;
    }

    public V getVariables() {
        return variables;
    }
}
