//
//  SSLPinningDelegate.swift
//  ZeniusApp / NetworkConnector
//

import Foundation
import Security
import CommonCrypto

public final class SSLPinningDelegate: NSObject, URLSessionDelegate {
    private let primaryPin: String
    private let backupPin: String

    public init(primaryPin: String, backupPin: String) {
        self.primaryPin = primaryPin
        self.backupPin = backupPin
        super.init()
    }

    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Evaluate Server Trust
        var secResult = SecTrustResultType.invalid
        let status = SecTrustEvaluate(serverTrust, &secResult)

        guard status == errSecSuccess else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Get Server Public Key Pin
        guard let serverPublicKeyPin = extractPublicKeyPin(from: serverTrust) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let cleanPrimary = primaryPin.replacingOccurrences(of: "sha256/", with: "")
        let cleanBackup = backupPin.replacingOccurrences(of: "sha256/", with: "")

        // Compare with Primary and Backup Pin
        if serverPublicKeyPin == cleanPrimary || serverPublicKeyPin == cleanBackup {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            // STRICT SECURITY REQUIREMENT: Reject request on failure. NO insecure fallback!
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    private func extractPublicKeyPin(from trust: SecTrust) -> String? {
        guard let chain = SecTrustCopyCertificateChain(trust) as? [SecCertificate],
              let leafCertificate = chain.first else {
            return nil
        }

        guard let publicKey = SecCertificateCopyKey(leafCertificate),
              let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data? else {
            return nil
        }

        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        publicKeyData.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(publicKeyData.count), &hash)
        }

        return Data(hash).base64EncodedString()
    }
}
