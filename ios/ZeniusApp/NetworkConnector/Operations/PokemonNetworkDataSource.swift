//
//  PokemonNetworkDataSource.swift
//  ZeniusApp / NetworkConnector
//

import Foundation

public struct PokemonModel: Codable, Equatable {
    public let id: Int
    public let name: String
    public let image: String
}

public struct PokemonSprites: Codable, Equatable {
    public let front_default: String?
}

public struct PokemonDetailModel: Codable, Equatable {
    public let id: Int
    public let name: String
    public let sprites: PokemonSprites?
}

public final class PokemonNetworkDataSource {
    private let networkHandler: NetworkHandlerProtocol

    public init(networkHandler: NetworkHandlerProtocol = NetworkHandler(config: NetworkEnvironmentConfig.pokemonConfig())) {
        self.networkHandler = networkHandler
    }

    // MARK: - Fetch Single Pokemon Sprite for Widget Icon
    public func fetchPokemon(name: String) async -> NetworkResult<PokemonDetailModel> {
        let query = """
        query getPokemon($name: String!) {
          pokemon(name: $name) {
            id
            name
            sprites {
              front_default
            }
          }
        }
        """

        struct ResponseWrapper: Codable {
            let pokemon: PokemonDetailModel
        }

        let result: NetworkResult<ResponseWrapper> = await networkHandler.executeQuery(
            operationName: "getPokemon",
            query: query,
            variables: ["name": name.lowercased()]
        )

        switch result {
        case .success(let wrapper):
            return .success(wrapper.pokemon)
        case .transportError(let err):
            return .transportError(err)
        case .graphQLErrors(let errs):
            return .graphQLErrors(errs)
        }
    }

    // MARK: - Fetch Pokemon List for Widget Avatar Selector
    public func fetchPokemons(limit: Int = 10, offset: Int = 0) async -> NetworkResult<[PokemonModel]> {
        let query = """
        query getPokemons($limit: Int, $offset: Int) {
          pokemons(limit: $limit, offset: $offset) {
            results {
              id
              name
              image
            }
          }
        }
        """

        struct PokemonListContainer: Codable {
            let results: [PokemonModel]
        }

        struct ResponseWrapper: Codable {
            let pokemons: PokemonListContainer
        }

        let result: NetworkResult<ResponseWrapper> = await networkHandler.executeQuery(
            operationName: "getPokemons",
            query: query,
            variables: ["limit": limit, "offset": offset]
        )

        switch result {
        case .success(let wrapper):
            return .success(wrapper.pokemons.results)
        case .transportError(let err):
            return .transportError(err)
        case .graphQLErrors(let errs):
            return .graphQLErrors(errs)
        }
    }
}
