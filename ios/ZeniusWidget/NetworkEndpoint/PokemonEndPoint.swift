import Foundation

struct RandomPokemonVariables: Encodable {
  let offset: Int
}

struct PokemonDetailVariables: Encodable {
  let name: String
}

extension Endpoint {
  static func randomPokemon(
    offset: Int
  ) throws -> Endpoint {
    let request = GraphQLRequest(
      query: """
        query getRandomPokemon($offset: Int!) {
          pokemons(limit: 1, offset: $offset) {
            results {
              id
              name
              image
            }
          }
        }
        """,

      variables: RandomPokemonVariables(
        offset: offset
      )
    )

    return try .graphql(body: request)
  }

  static func pokemonDetail(
    name: String
  ) throws -> Endpoint {
    let request = GraphQLRequest(
      query: """
        query getPokemon($name: String!) {
          pokemon(name: $name) {
            sprites {
              front_default
            }
          }
        }
        """,

      variables: PokemonDetailVariables(
        name: name.lowercased()
      )
    )

    return try .graphql(body: request)
  }
}
 