import Foundation
import Vapor
@testable import S3


public func routes(_ router: Router) throws {
    // Get all available buckets
    router.get("buckets")  { req -> Future<BucketsInfo> in
        let s3 = try req.makeS3Client()
        return try s3.buckets(on: req)
    }
    
    // Create new bucket
    router.put("bucket")  { req -> Future<String> in
        let s3 = try req.makeS3Client()
        return try s3.create(bucket: "api-created-bucket", region: .euCentral1, on: req).map(to: String.self) {
            return ":)"
            }.catchMap({ (error) -> (String) in
                if let error = error.s3ErroMessage() {
                    return error.message
                }
                return ":("
            }
        )
    }
    
    // Delete bucket
    router.delete("bucket")  { req -> Future<String> in
        let s3 = try req.makeS3Client()
        return try s3.delete(bucket: "api-created-bucket", region: .euCentral1, on: req).map(to: String.self) {
            return ":)"
            }.catchMap({ (error) -> (String) in
                if let error = error.s3ErroMessage() {
                    return error.message
                }
                return ":("
                }
        )
    }
    
    // Delete bucket
    router.get("files")  { req -> Future<BucketResults> in
        let s3 = try req.makeS3Client()
        return try s3.list(bucket: "booststore", region: .usEast1, headers: [:], on: req).catchMap({ (error) -> (BucketResults) in
            if let error = error.s3ErroMessage() {
                print(error.message)
            }
            throw error
        })
    }
    
//    // Bucket location
//    router.get("bucket/location")  { req -> Future<String> in
//        let s3 = try req.makeS3Client()
//        return try s3.location(bucket: "api-created-bucket", on: req).map(to: String.self) { location in
//            return location.region
//        }.catchMap({ (error) -> (String) in
//                if let error = error as? S3.Error {
//                    switch error {
//                    case .errorResponse(_, let error):
//                        return error.message
//                    default:
//                        return "S3 :("
//                    }
//                }
//                return ":("
//            }
//        )
//    }
    
    // Demonstrate work with files
    router.get("files/test") { req -> Future<String> in
        let string = "Content of my example file"
        
        let fileName = "file-hu.txt"
        
        let s3 = try req.makeS3Client()
        do {
            return try s3.put(string: string, destination: fileName, access: .publicRead, on: req).flatMap(to: String.self) { putResponse in
                print("PUT response:")
                print(putResponse)
                return try s3.get(file: fileName, on: req).flatMap(to: String.self) { getResponse in
                    print("GET response:")
                    print(getResponse)
                    print(String(data: getResponse.data, encoding: .utf8) ?? "Unknown content!")
                    return try s3.get(fileInfo: fileName, on: req).flatMap(to: String.self) { infoResponse in
                        print("HEAD/Info response:")
                        print(infoResponse)
                        return try s3.delete(file: fileName, on: req).map() { response in
                            print("DELETE response:")
                            print(response)
                            let json = try JSONEncoder().encode(infoResponse)
                            return String(data: json, encoding: .utf8) ?? "Unknown content!"
                            }.catchMap({ error -> (String) in
                                if let error = error.s3ErroMessage() {
                                    return error.message
                                }
                                return ":("
                            }
                        )
                    }
                }
            }
        } catch {
            print(error)
            fatalError()
        }
    }
}


public func configure(_ config: inout Config, _ env: inout Vapor.Environment, _ services: inout Services) throws {
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    // Get API key and secret from environmental variables
    guard let key = Environment.get("S3_ACCESS_KEY"), let secret = Environment.get("S3_SECRET") else {
        fatalError("Missing AWS API key/secret")
    }
    
    
    let config = S3Signer.Config(accessKey: key, secretKey: secret, region: Region.euWest2)
    try S3(defaultBucket: "s3-liveui-test", config: config, services: &services)
    
}
