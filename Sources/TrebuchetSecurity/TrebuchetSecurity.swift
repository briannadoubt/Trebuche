// TrebuchetSecurity.swift
// Production-grade security for Trebuchet distributed actors
//
// This module provides comprehensive security features including:
// - Authentication (JWT with HS256/RS256/ES256 signature validation, API keys)
// - Authorization (RBAC)
// - Rate limiting (token bucket, sliding window)
// - Request validation
//
// Example usage:
// ```swift
// // HS256 JWT authentication (symmetric secret)
// let auth = JWTAuthenticator(configuration: .init(
//     issuer: "https://auth.example.com",
//     audience: "my-app",
//     signingKey: .hs256(secret: "your-256-bit-secret")
// ))
// let principal = try await auth.authenticate(credentials)
//
// // RS256 JWT authentication (RSA public key)
// import _CryptoExtras
// let rsaKey = try _RSA.Signing.PublicKey(pemRepresentation: pemString)
// let auth = JWTAuthenticator(configuration: .init(
//     issuer: "https://auth.example.com",
//     signingKey: .rs256(publicKey: rsaKey)
// ))
//
// // ES256 JWT authentication (P-256 public key)
// import Crypto
// let ecKey = try P256.Signing.PublicKey(pemRepresentation: pemString)
// let auth = JWTAuthenticator(configuration: .init(
//     issuer: "https://auth.example.com",
//     signingKey: .es256(publicKey: ecKey)
// ))
//
// // Authorization
// let policy = RoleBasedPolicy(rules: [
//     .init(role: "admin", actorType: "*", method: "*")
// ])
// let allowed = try await policy.authorize(principal, action: action, resource: resource)
// ```

@_exported import struct Foundation.UUID
@_exported import struct Foundation.Date

/// TrebuchetSecurity provides production-grade security for distributed actors.
///
/// This module includes:
/// - **Authentication**: JWT (HS256, RS256, ES256) and API key validation with full signature verification
/// - **Authorization**: Role-based access control (RBAC)
/// - **Rate Limiting**: Token bucket and sliding window algorithms
/// - **Validation**: Request size limits and malformed envelope detection
///
/// ## JWT Features
/// - HS256 (HMAC-SHA256) signature validation
/// - RS256 (RSA PKCS#1 v1.5 with SHA-256) signature validation
/// - ES256 (ECDSA P-256) signature validation
/// - Issuer, audience, and expiration claim validation
/// - Not-before (nbf) claim validation
/// - JWT ID (jti) replay protection
/// - Configurable clock skew tolerance
public enum TrebuchetSecurity {
    /// Current version of the security module
    public static let version = "1.3.0"
}
