//
//  GraphQLRequest.swift
//  ZeniusApp / NetworkConnector
//

import Foundation

public enum GraphQLOperationType: String, Codable {
    case query
    case mutation
}

public struct GraphQLRequest: Encodable {
    public let operationName: String
    public let query: String
    public let variables: [String: AnyEncodable]?

    public init(operationName: String, query: String, variables: [String: Any]? = nil) {
        self.operationName = operationName
        self.query = query
        if let vars = variables {
            self.variables = vars.mapValues { AnyEncodable($0) }
        } else {
            self.variables = nil
        }
    }
}

public struct AnyEncodable: Encodable {
    public let value: Any

    public init(_ value: Any) {
        self.value = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let stringValue = value as? String {
            try container.encode(stringValue)
        } else if let intValue = value as? Int {
            try container.encode(intValue)
        } else if let doubleValue = value as? Double {
            try container.encode(doubleValue)
        } else if let boolValue = value as? Bool {
            try container.encode(boolValue)
        } else if let arrayValue = value as? [Any] {
            try container.encode(arrayValue.map { AnyEncodable($0) })
        } else if let dictValue = value as? [String: Any] {
            try container.encode(dictValue.mapValues { AnyEncodable($0) })
        } else {
            try container.encodeNil()
        }
    }
}

public struct GraphQLResponse<T: Decodable>: Decodable {
    public let data: T?
    public let errors: [GraphQLErrorItem]?
}
