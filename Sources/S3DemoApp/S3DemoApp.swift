import Foundation
import Vapor
@testable import S3


public func routes(_ router: RoutesBuilder, s3: S3Client) throws {
    
    // Get all available buckets
    router.get("buckets")  { req -> EventLoopFuture<BucketsInfo> in
        return s3.buckets(on: req.eventLoop)
    }
    
    // Create new bucket
    router.put("bucket")  { req -> EventLoopFuture<String> in
        return s3.create(bucket: "api-created-bucket", region: .euCentral1, on: req.eventLoop).map {
            return ":)"
        }.recover { error in
            if let error = error.s3ErrorMessage() {
                return error.message
            }
            return ":("
        }
    }
    
    // Delete bucket
    router.delete("bucket")  { req -> EventLoopFuture<String> in
        return s3.delete(bucket: "api-created-bucket", region: .euCentral1, on: req.eventLoop).map {
            return ":)"
        }.recover { error in
            if let error = error.s3ErrorMessage() {
                return error.message
            }
            return ":("
        }
    }
    
    // Delete bucket
    router.get("files")  { req -> EventLoopFuture<BucketResults> in
        return s3.list(bucket: "booststore", region: .usEast1, headers: [:], on: req.eventLoop).flatMapErrorThrowing { error in
            if let error = error.s3ErrorMessage() {
                print(error.message)
            }

            throw error
        }
    }
    
    // Bucket location
    router.get("bucket/location")  { req -> EventLoopFuture<String> in
        return s3.location(bucket: "adfasdfasdfasdf", on: req.eventLoop).map { region in
            return region.hostUrlString()
        }.recover { error -> String in
            if let error = error as? S3.Error {
                switch error {
                case .errorResponse(_, let error):
                    return error.message
                default:
                    return "S3 :("
                }
            }
            return ":("
        }
    }
    
    // Demonstrate work with files
    router.get("files/test") { req -> EventLoopFuture<String> in
        let string = "Content of my example file"
        
        let fileName = "file-hu.txt"
        return s3.put(string: string, destination: fileName, access: .publicRead, on: req.eventLoop).flatMap { putResponse -> EventLoopFuture<String> in
            print("PUT response:")
            print(putResponse)
            return s3.get(file: fileName, on: req.eventLoop).flatMap { getResponse in
                print("GET response:")
                print(getResponse)
                print(String(data: getResponse.data, encoding: .utf8) ?? "Unknown content!")

                return s3.get(fileInfo: fileName, on: req.eventLoop).flatMap { infoResponse in
                    print("HEAD/Info response:")
                    print(infoResponse)

                    return s3.delete(file: fileName, on: req.eventLoop).flatMapThrowing { response in
                        print("DELETE response:")
                        print(response)
                        let json = try JSONEncoder().encode(infoResponse)
                        return String(data: json, encoding: .utf8) ?? "Unknown content!"
                    }.recover { error -> (String) in
                        if let error = error.s3ErrorMessage() {
                            return error.message
                        }
                        return ":("
                    }
                }
            }
        }.recover { error -> (String) in
            if let error = error.s3ErrorMessage() {
                return error.message
            }
            return ":("
        }
    }
}


public func configure(env: inout Vapor.Environment, _ services: inout Services) throws {
    services.extend(RoutesBuilder.self) { router, container in
        try routes(router, s3: container.makeS3Client())
    }
    
    // Get API key and secret from environmental variables
    guard let key = Environment.get("S3_ACCESS_KEY"), let secret = Environment.get("S3_SECRET") else {
        fatalError("Missing AWS API key/secret")
    }
    
    
    let config = S3Signer.Config(accessKey: key, secretKey: secret, region: Region.euWest2)
    try S3(defaultBucket: "s3-liveui-test", config: config, services: &services)
    
}
