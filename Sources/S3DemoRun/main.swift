import Vapor
import S3Provider


let DEFAULT_BUCKET = "s3-lib-test.einstore.mgw.cz"


func routes(_ router: Routes, _ c: Container) throws {
    guard let key = Environment.get("S3_ACCESS_KEY"), let secret = Environment.get("S3_SECRET") else {
        fatalError("Missing AWS API key/secret")
    }
    
    let config = S3Signer.Config(accessKey: key, secretKey: secret, region: Region.euCentral1)
    let s3: S3Client = try S3(defaultBucket: DEFAULT_BUCKET, config: config)
    
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
        return s3.list(bucket: DEFAULT_BUCKET, region: .euCentral1, headers: [:], on: req.eventLoop).flatMapErrorThrowing { error in
            if let error = error.s3ErrorMessage() {
                print(error.message)
            }

            throw error
        }
    }
    
    // Bucket location
    router.get("bucket", "location")  { req -> EventLoopFuture<String> in
        return s3.location(bucket: DEFAULT_BUCKET, on: req.eventLoop).map { region in
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
    router.get("files", "test") { req -> EventLoopFuture<String> in
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

/// Called before your application initializes.
func configure(_ s: inout Services) throws {
    /// Register routes
    s.extend(Routes.self) { r, c in
        try routes(r, c)
    }

    /// Register middleware
    s.register(MiddlewareConfiguration.self) { c in
        // Create _empty_ middleware config
        var middlewares = MiddlewareConfiguration()
        
        // Serves files from `Public/` directory
        /// middlewares.use(FileMiddleware.self)
        
        // Catches errors and converts to HTTP response
        try middlewares.use(c.make(ErrorMiddleware.self))
        
        return middlewares
    }
}

func boot(_ app: Application) throws {
    try LoggingSystem.bootstrap(from: &app.environment)
    try app.boot()
}

public func app(_ environment: Environment) throws -> Application {
    let app = Application.init(environment: environment) { s in
        try configure(&s)
    }
    try boot(app)
    return app
}

try app(.detect()).run()
