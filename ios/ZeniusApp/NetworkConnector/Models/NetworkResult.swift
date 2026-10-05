//
//  NetworkResult.swift
//  ZeniusApp / NetworkConnector
//

import Foundation

public enum NetworkResult<T> {
    case success(T)
    case transportError(NetworkError)
    case graphQLErrors([GraphQLErrorItem])

    public var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }

    public var data: T? {
        if case .success(let data) = self { return data }
        return nil
    }

    public var error: NetworkError? {
        if case .transportError(let err) = self { return err }
        return nil
    }

    public var graphqlErrors: [GraphQLErrorItem]? {
        if case .graphQLErrors(let errs) = self { return errs }
        return nil
    }
}
