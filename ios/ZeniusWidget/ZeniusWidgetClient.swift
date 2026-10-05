import WidgetKit
import UIKit

struct ZeniusWidgetClient {
  struct PokemonDetailResponse: Decodable {
    let data: Payload?

    struct Payload: Decodable {
      let pokemon: Pokemon?
    }
    struct Pokemon: Decodable {
      let sprites: Sprites?
    }
    struct Sprites: Decodable {
      let front_default: String?
    }
  }

  struct RandomPokemonResponse: Decodable {
    let data: PokemonData?

    struct PokemonData: Decodable {
      let pokemons: PokemonResult?
    }
    struct PokemonResult: Decodable {
      let results: [PokemonItem]?
    }
    struct PokemonItem: Decodable {
      let id: Int?
      let name: String
      let image: String?
    }
  }

  // MARK: - Fetch Random Gen-1 Pokemon
  static func fetchRandomPokemon() async -> (name: String, imageURL: URL)? {
    do {
      let offset = Int.random(in: 0...150)
      let response: RandomPokemonResponse = try await NetworkClient.shared.request(
        .randomPokemon(offset: offset)
      )

      guard
        let pokemon = response.data?.pokemons?.results?.first,
        let imageURL = URL(string: pokemon.image ?? ""),
        imageURL.scheme == "https"
      else {
        return nil
      }
      print("pokemon data \(pokemon)")

      return (name: pokemon.name, imageURL: imageURL)
    } catch {
      print("[ZeniusWidgetClient] fetchRandomPokemon failed:", error)
      return nil
    }
  }

  // MARK: - Fetch Pokemon Sprite URL by Name
  static func fetchSpriteURL(name: String) async -> URL? {
    do {
      let response: PokemonDetailResponse = try await NetworkClient.shared.request(
        .pokemonDetail(name: name)
      )

      guard
        let urlString = response.data?.pokemon?.sprites?.front_default,
        let url = URL(string: urlString),
        url.scheme == "https"
      else {
        return nil
      }

      return url
    } catch {
      print("[ZeniusWidgetClient] fetchSpriteURL failed:", error)
      return nil
    }
  }

  // MARK: - Download Image Data
  static func downloadImageData(from url: URL) async -> Data? {
    do {
      let (data, response) = try await URLSession.shared.data(from: url)
      guard
        let http = response as? HTTPURLResponse,
        http.statusCode == 200,
        data.count <= 500_000,
        UIImage(data: data) != nil
      else {
        return nil
      }
      return data
    } catch {
      print("[ZeniusWidgetClient] downloadImageData failed:", error)
      return nil
    }
  }
}