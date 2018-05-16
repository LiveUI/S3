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
- [x] Object info (HEAD)
- [ ] Object info (ACL)
- [x] Parsing error responses

## Usage

Register S3Client as a service in your configure method

```swift
try services.register(s3: S3Signer.Config(...), defaultBucket: "my-bucket")
```

use S3Client

```swift
import S3

let s3 = try req.makeS3Client() // or req.make(S3Client.self) as? S3
s3.put(...)
s3.get(...)
s3.delete(...)
```

if you only want to use the signer

```swift
import S3Signer

let s3 = try req.makeS3Signer() // or req.make(S3Signer.self)
s3.headers(...)
```

### Available methods

```swift
/// S3 client Protocol
public protocol S3Client: Service {
    
    /// Get list of objects
    func buckets(on: Container) throws -> Future<BucketsInfo>
    
    /// Create a bucket
    func create(bucket: String, region: Region?, on container: Container) throws -> Future<Void>
    
    /// Delete a bucket
    func delete(bucket: String, region: Region?, on container: Container) throws -> Future<Void>
    
    /// Get bucket location
    func location(bucket: String, on container: Container) throws -> Future<Region>
    
    /// Get list of objects
    func list(bucket: String, region: Region?, on container: Container) throws -> Future<BucketResults>
    
    /// Get list of objects
    func list(bucket: String, region: Region?, headers: [String: String], on container: Container) throws -> Future<BucketResults>
    
    /// Upload file to S3
    func put(file: File.Upload, headers: [String: String], on: Container) throws -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(file url: URL, destination: String, access: AccessControlList, on: Container) throws -> Future<File.Response>
    
    /// Upload file to S3
    func put(file url: URL, destination: String, bucket: String?, access: AccessControlList, on: Container) throws -> Future<File.Response>
    
    /// Upload file to S3
    func put(file path: String, destination: String, access: AccessControlList, on: Container) throws -> Future<File.Response>
    
    /// Upload file to S3
    func put(file path: String, destination: String, bucket: String?, access: AccessControlList, on: Container) throws -> Future<File.Response>
    
    /// Upload file to S3
    func put(string: String, destination: String, on: Container) throws -> Future<File.Response>
    
    /// Upload file to S3
    func put(string: String, destination: String, access: AccessControlList, on: Container) throws -> Future<File.Response>
    
    /// Upload file to S3
    func put(string: String, mime: MediaType, destination: String, on: Container) throws -> Future<File.Response>
    
    /// Upload file to S3
    func put(string: String, mime: MediaType, destination: String, access: AccessControlList, on: Container) throws -> Future<File.Response>
    
    /// Upload file to S3
    func put(string: String, mime: MediaType, destination: String, bucket: String?, access: AccessControlList, on: Container) throws -> Future<File.Response>
    
    /// Retrieve file data from S3
    func get(fileInfo file: LocationConvertible, on container: Container) throws -> Future<File.Info>
    
    /// Retrieve file data from S3
    func get(fileInfo file: LocationConvertible, headers: [String: String], on container: Container) throws -> Future<File.Info>
    
    /// Retrieve file data from S3
    func get(file: LocationConvertible, on: Container) throws -> Future<File.Response>
    
    /// Retrieve file data from S3
    func get(file: LocationConvertible, headers: [String: String], on: Container) throws -> Future<File.Response>
    
    /// Delete file from S3
    func delete(file: LocationConvertible, on: Container) throws -> Future<Void>
    
    /// Delete file from S3
    func delete(file: LocationConvertible, headers: [String: String], on: Container) throws -> Future<Void>
}
```

### Example usage

```swift
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
    
    // Locate bucket (get region)
    router.get("bucket/location")  { req -> Future<String> in
        let s3 = try req.makeS3Client()
        return try s3.location(bucket: "bucket-name", on: req).map(to: String.self) { region in
            return region.hostUrlString()
        }.catchMap({ (error) -> (String) in
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
    
    // Get list of objects
    router.get("files")  { req -> Future<BucketResults> in
        let s3 = try req.makeS3Client()
        return try s3.list(bucket: "booststore", region: .usEast1, headers: [:], on: req).catchMap({ (error) -> (BucketResults) in
            if let error = error.s3ErroMessage() {
                print(error.message)
            }
            throw error
        })
    }
    
    // Demonstrate work with files
    router.get("files/test") { req -> Future<String> in
        let string = "Content of my example file"
        
        let fileName = "file-hu.txt"
        
        let s3 = try req.makeS3Client()
        do {
            // Upload a file from string
            return try s3.put(string: string, destination: fileName, access: .publicRead, on: req).flatMap(to: String.self) { putResponse in
                print("PUT response:")
                print(putResponse)
                // Get the content of the newly uploaded file
                return try s3.get(file: fileName, on: req).flatMap(to: String.self) { getResponse in
                    print("GET response:")
                    print(getResponse)
                    print(String(data: getResponse.data, encoding: .utf8) ?? "Unknown content!")
                    // Get info about the file (HEAD)
                    return try s3.get(fileInfo: fileName, on: req).flatMap(to: String.self) { infoResponse in
                        print("HEAD/Info response:")
                        print(infoResponse)
                        // Delete the file
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
```

## Support

Join our [Slack](http://bit.ly/2B0dEyt), channel <b>#help-boost</b> to ... well, get help :) 

## Boost AppStore

Core package for <b>[Boost](http://www.boostappstore.com)</b>, a completely open source enterprise AppStore written in Swift!
- Website: http://www.boostappstore.com
- Github: https://github.com/LiveUI/Boost

## Other core packages

* [BoostCore](https://github.com/LiveUI/BoostCore/) - AppStore core module
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
