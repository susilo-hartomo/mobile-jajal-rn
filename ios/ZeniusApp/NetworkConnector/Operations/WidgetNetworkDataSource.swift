//
//  WidgetNetworkDataSource.swift
//  ZeniusApp / NetworkConnector
//

import Foundation

public struct WidgetDataModel: Codable, Equatable {
    public let id: String
    public let activeSubject: String
    public let streakDays: Int
    public let dailyProgress: Double
    public let minutesLearned: Int
}

public struct UpdateWidgetActionResponse: Codable, Equatable {
    public let success: Bool
    public let message: String
}

public final class WidgetNetworkDataSource {
    private let networkHandler: NetworkHandlerProtocol

    public init(networkHandler: NetworkHandlerProtocol) {
        self.networkHandler = networkHandler
    }

    public func fetchWidgetData(userId: String) async -> NetworkResult<WidgetDataModel> {
        let query = """
        query GetWidgetData($userId: ID!) {
          widgetData(userId: $userId) {
            id
            activeSubject
            streakDays
            dailyProgress
            minutesLearned
          }
        }
        """

        struct ResponseWrapper: Codable {
            let widgetData: WidgetDataModel
        }

        let result: NetworkResult<ResponseWrapper> = await networkHandler.executeQuery(
            operationName: "GetWidgetData",
            query: query,
            variables: ["userId": userId]
        )

        switch result {
        case .success(let wrapper):
            return .success(wrapper.widgetData)
        case .transportError(let err):
            return .transportError(err)
        case .graphQLErrors(let errs):
            return .graphQLErrors(errs)
        }
    }

    public func updateWidgetAction(actionId: String, enabled: Bool) async -> NetworkResult<UpdateWidgetActionResponse> {
        let mutation = """
        mutation UpdateWidgetAction($input: UpdateWidgetActionInput!) {
          updateWidgetAction(input: $input) {
            success
            message
          }
        }
        """

        let input: [String: Any] = [
            "actionId": actionId,
            "enabled": enabled
        ]

        struct ResponseWrapper: Codable {
            let updateWidgetAction: UpdateWidgetActionResponse
        }

        let result: NetworkResult<ResponseWrapper> = await networkHandler.executeMutation(
            operationName: "UpdateWidgetAction",
            mutation: mutation,
            variables: ["input": input]
        )

        switch result {
        case .success(let wrapper):
            return .success(wrapper.updateWidgetAction)
        case .transportError(let err):
            return .transportError(err)
        case .graphQLErrors(let errs):
            return .graphQLErrors(errs)
        }
    }
}
