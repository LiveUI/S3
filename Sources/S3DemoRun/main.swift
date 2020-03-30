import Vapor
import S3Provider

let DEFAULT_BUCKET = "test-bucket-s3-vapor"

func routes(_ app: Application) throws {
    guard let key = Environment.get("S3_ACCESS_KEY"), let secret = Environment.get("S3_SECRET") else {
        fatalError("Missing AWS API key/secret")
    }
    
    app.s3.configuration = .init(accessKey: key, secretKey: secret, region: Region.euNorth1, defaultBucket: DEFAULT_BUCKET)
    
    // Get all available buckets
    app.get("buckets")  { req -> EventLoopFuture<BucketsInfo> in
        req.s3.buckets()
    }
    
    // Create new bucket
    app.put("bucket")  { req -> EventLoopFuture<String> in
        return req.s3.create(bucket: "api-created-bucket", region: .euCentral1).map {
            return ":)"
        }.recover { error in
            if let error = error.s3ErrorMessage() {
                return error.message
            }
            return ":("
        }
    }

    // Delete bucket
    app.delete("bucket")  { req -> EventLoopFuture<String> in
        return req.s3.delete(bucket: "api-created-bucket", region: .euCentral1).map {
            return ":)"
        }.recover { error in
            if let error = error.s3ErrorMessage() {
                return error.message
            }
            return ":("
        }
    }

    // List files
    app.get("files")  { req -> EventLoopFuture<BucketResults> in
        return req.s3.list(bucket: DEFAULT_BUCKET, region: .euCentral1, headers: [:]).flatMapErrorThrowing { error in
            if let error = error.s3ErrorMessage() {
                print(error.message)
            }

            throw error
        }
    }

    // Bucket location
    app.get("bucket", "location")  { req -> EventLoopFuture<String> in
        return req.s3.location(bucket: DEFAULT_BUCKET).map { region in
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
    app.get("files", "test") { req -> EventLoopFuture<String> in
        let string = "Content of my example file"

        let fileName = "file-hu.txt"
        return req.s3.put(string: string, destination: fileName, access: .publicRead).flatMap { putResponse -> EventLoopFuture<String> in
            print("PUT response:")
            print(putResponse)
            return req.s3.get(file: fileName).flatMap { getResponse in
                print("GET response:")
                print(getResponse)
                print(String(data: getResponse.data, encoding: .utf8) ?? "Unknown content!")

                return req.s3.get(fileInfo: fileName).flatMap { infoResponse in
                    print("HEAD/Info response:")
                    print(infoResponse)

                    return req.s3.delete(file: fileName).flatMapThrowing { response in
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

/// Called before your application initializes.
func configure(_ app: Application) throws {    
    try routes(app)
}

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }
try configure(app)
try app.run()
