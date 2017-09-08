import Foundation

public enum S3SignerError: Error {
	case badURL
	case putRequestRequiresPayloadData
	case unableToEncodeSignature
	case unableToEncodeStringToSign
	case unableToEncodeURLPath
	case unableToEncodeCredentialScope
}
