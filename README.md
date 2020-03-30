[![Build Status](https://travis-ci.com/lluuaapp/S3.svg?branch=tests)](https://travis-ci.com/lluuaapp/S3)

# S3 client for Vapor 3

## Functionality

- [x] Signing headers for any region
- [x] Listing buckets
- [x] Create bucket
- [x] Delete bucket
- [x] Locate bucket region
- [x] List objects
- [x] Upload file
- [x] Get file
- [x] Delete file
- [x] Copy file
- [x] Move file (copy then delete old one)
- [x] Object info (HEAD)
- [ ] Object info (ACL)
- [x] Parsing error responses

## Usage

Update dependencies and targets in Package.swift

```swift
dependencies: [
    ...
    .package(url: "https://github.com/LiveUI/S3.git", from: "4.0.0-rc.1"),
],
targets: [
    .target(name: "App", dependencies: [
        .package(name: "S3", package: "S3Kit") 
    ],
        ...
]
```

Configure S3 in your `configure` method:

```swift
app.s3.configuration = .init(accessKey: "<access_key>", secretKey: "<secret_key>", region: Region.euNorth1, defaultBucket: "my-bucket")
```

Using S3 inside your route handlers

```swift
import S3

app.get("buckets")  { req -> EventLoopFuture<BucketsInfo> in
    req.s3.buckets()
}
```

### Available methods

```swift
/// S3 client Protocol
public protocol S3Client: Service {
    
    /// Get list of objects
    func buckets(on: Container) -> EventLoopFuture<BucketsInfo>
    
    /// Create a bucket
    func create(bucket: String, region: Region?) -> EventLoopFuture<Void>
    
    /// Delete a bucket
    func delete(bucket: String, region: Region?) -> EventLoopFuture<Void>
    
    /// Get bucket location
    func location(bucket: String) -> EventLoopFuture<Region>
    
    /// Get list of objects
    func list(bucket: String, region: Region?) -> EventLoopFuture<BucketResults>
    
    /// Get list of objects
    func list(bucket: String, region: Region?, headers: [String: String]) -> EventLoopFuture<BucketResults>
    
    /// Upload file to S3
    func put(file: File.Upload, headers: [String: String]) throws -> EventLoopEventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(file url: URL, destination: String, access: AccessControlList) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(file url: URL, destination: String, bucket: String?, access: AccessControlList) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(file path: String, destination: String, access: AccessControlList) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(file path: String, destination: String, bucket: String?, access: AccessControlList) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(string: String, destination: String) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(string: String, destination: String, access: AccessControlList) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(string: String, mime: MediaType, destination: String) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(string: String, mime: MediaType, destination: String, access: AccessControlList) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(string: String, mime: MediaType, destination: String, bucket: String?, access: AccessControlList) -> EventLoopFuture<File.Response>
    
    /// Retrieve file data from S3
    func get(fileInfo file: LocationConvertible) -> EventLoopFuture<File.Info>
    
    /// Retrieve file data from S3
    func get(fileInfo file: LocationConvertible, headers: [String: String]) -> EventLoopFuture<File.Info>
    
    /// Retrieve file data from S3
    func get(file: LocationConvertible) -> EventLoopFuture<File.Response>
    
    /// Retrieve file data from S3
    func get(file: LocationConvertible, headers: [String: String]) -> EventLoopFuture<File.Response>
    
    /// Delete file from S3
    func delete(file: LocationConvertible) -> EventLoopFuture<Void>
    
    /// Delete file from S3
    func delete(file: LocationConvertible, headers: [String: String]) -> EventLoopFuture<Void>
}
```

### Example usage

```swift
public func routes(_ app: Application) throws {
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
```

## Support

Join our [Slack](http://bit.ly/2B0dEyt), channel <b>#help-boost</b> to ... well, get help :) 

## Einstore AppStore

Core package for <b>[Einstore](http://www.einstore.io)</b>, a completely open source enterprise AppStore written in Swift!
- Website: http://www.einstore.io
- Github: https://github.com/Einstore/Einstore

## Other core packages

* [EinstoreCore](https://github.com/Einstore/EinstoreCore/) - AppStore core module
* [ApiCore](https://github.com/LiveUI/ApiCore/) - API core module with users and team management
* [MailCore](https://github.com/LiveUI/MailCore/) - Mailing wrapper for multiple mailing services like MailGun, SendGrig or SMTP (coming)
* [DBCore](https://github.com/LiveUI/DbCore/) - Set of tools for work with PostgreSQL database
* [VaporTestTools](https://github.com/LiveUI/VaporTestTools) - Test tools and helpers for Vapor 3

## Code contributions

We love PR’s, we can’t get enough of them ... so if you have an interesting improvement, bug-fix or a new feature please don’t hesitate to get in touch. If you are not sure about something before you start the development you can always contact our dev and product team through our Slack.

## Credits

#### Author
Ondrej Rafaj (@rafiki270 on [Github](https://github.com/rafiki270), [Twitter](https://twitter.com/rafiki270), [LiveUI Slack](http://bit.ly/2B0dEyt) and [Vapor Slack](https://vapor.team/))

#### Thanks
Anthoni Castelli (@anthonycastelli on [Github](https://github.com/anthonycastelli), @anthony on [Vapor Slack](https://vapor.team/)) for his help on updating S3Signer for Vapor3

JustinM1 (@JustinM1 on [Github](https://github.com/JustinM1)) for his amazing original signer package

## License

See the LICENSE file for more info.
