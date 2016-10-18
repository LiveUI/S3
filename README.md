# S3SignerAWS
Generates authorization headers and pre-signed URLs for authenticating AWS S3 REST API calls

I wrote the majority of this for personal use on the [Vapor Server](https://vapor.codes/) and found getting the signatures to work in a flexible and reusable way pretty painful and tedious. Hopefully this will save others some time. I tried to expand the uses beyond my specific needs, but this does not cover all use cases. It _does not_ cover chunked-uploads or POST requests(On AWS this is used for adding an object to a bucket using HTML forms). Anyone who would like to contribute is more than welcome.

**NOTE -** I tried to test this as much as possible, within reason, but It's hard to be sure with so many options and the signing process being so particular. If you encounter a bug, open up an issue and I'll be happy to look into it.

### Features
1. Pure Swift
2. All required headers generated automatically
3. Authorization methods currently supported:
  * V4 Authorization header
    * Supports PUT/GET/DELETE
  * V4 pre-signed URL
  * V2 pre-signed URL

## Table of Contents
  - [Integration](#integration)
  - [Usage](#usage)
    - [V4 Authorization Header](#v4-authorization-header)
    - [V4 Pre-Signed URL](#v4-pre-signed-url)
    - [V2 Pre-Signed URL](#v2-pre-signed-url)
  - [Known Limitations](#known-limitations)

## Integration
**Swift Package Manager**

To install with swift package manager, add the package to your `Package.swift` file:
```ruby

      Import PackageDescription

      let package = Package(
        name: "Your_Project_Name",
        targets: [],
        dependencies: [
            .Package(url: "https://github.com/JustinM1/S3SignerAWS.git", majorVersion: 1)
        ]
      )  
  ```
## Usage

**NOTE ABOUT PAYLOAD:**

Requests can either have a signed payload or an unsigned payload.
* _S3SignerAWS was built using `Vapor Server` frameworks and uses `Bytes` as the payload data type. `Bytes` is a typealias of `[UInt8]`_
For example, to convert a data object to bytes you do the following:
      ```ruby
      let bytes = try someDataObject.makeBytes()
      ```
* If you know the request will not have a payload, set the Payload property to none. This tells s3 that the signature was created with no payload intended
* If you are not sure what the exact payload will be, set payload property to unsigned. This tells s3 when you made the signature, there was a possibility of a payload but you weren't sure what specific object will be uploaded.
* `Payload` enum:

    ```ruby
        public enum Payload {
          case bytes(Bytes)
          case none
          case unsigned
        }
    ```
To begin working with the S3SignerAWS class, initialize an instance as shown below:

```ruby
    let s3Signer = S3SignerAWS(accessKey: "YOUR_AWS_PUBLIC_KEY", secretKey: "YOUR_AWS_SECRET_KEY", region: .usStandard_usEast1)  
```
**NOTE -** Hardcoding Secret Keys on client is _not_ recommended for security reasons.

### V4 Authorization Header
For both V4 Authorization Header and Pre-Signed URL, you can add additional headers as needed for your specific use case.

GET

```ruby
    do {
      let headers = try s3Signer.authHeaderV4(httpMethod: .get, urlString: "S3ImageURL", headers: [:], payload: .none)          
      guard let url = URL(string: "S3ImageURL") else { else throw someError }
      var request = URLRequest(url: url)
      request.httpMethod = HTTPMethod.get.rawValue
        for header in headers {
          request.setValue(header.key, forHTTPHeaderField: header.value)
          }
          // make network request
        } catch {
          //handle error
          }
        }
  ```
PUT

```ruby
    do {
      let bytesObject = try someDataObject.makeBytes()
      let headers = try s3Signer.authHeadersV4(httpMethod: .put, urlString: "S3ImageURL", headers: [:], payload: .bytes(bytesObject))
      guard let url = URL(string: "S3ImageURL") else { else throw someError }
      var request = URLRequest(url: url)
      request.httpMethod = HTTPMethod.put.rawValue
      request.httpBody = Data(bytes: bytesObject)
        for header in headers {
          request.setValue(header.key, forHTTPHeaderField: header.value)
          }
          // make network request
        } catch {
          //handle error
          }
        }
  ```
Delete

```ruby
    do {
      let headers = try s3Signer.authHeadersV4(httpMethod: .delete, urlString: "S3ImageURL", headers: [:], payload: .none)
      guard let url = URL(string: "S3ImageURL") else { else throw someError }
      var request = URLRequest(url: url)
      request.httpMethod = HTTPMethod.delete.rawValue
        for header in headers {
          request.setValue(header.key, forHTTPHeaderField: header.value)
          }
          // make network request
        } catch {
          //handle error
        }
      }
```
**Vapor PUT example**

```ruby
    drop.put("uploadTestImage") { request in

    let signer = S3SignerAWS(accessKey: "key", secretKey: "secretKey", region: .usStandard_usEast1)
    
    guard let bodyBytes = request.body.bytes, let url = URL(string: "https://s3.amazonaws.com/bucketName/testUploadImage.png") else { return "Bad Request" }
    
    let headers = try signer.authHeaderV4(httpMethod: .put, urlString: url.absoluteString, headers: [:], payload: .bytes(bodyBytes))

    var request = URLRequest(url: url)
    request.httpMethod = HTTPMethod.put.rawValue
    request.httpBody = Data(bytes: bodyBytes)
    
    for header in headers {
        request.setValue(header.value, forHTTPHeaderField: header.key)
    }
    
    let session = URLSession(configuration: .default)
    
    let task = session.dataTask(with: request, completionHandler: { data, response, error in
        print("ERROR: \(error)")
        
        print("RESPONSE: \(response)")
    })
    task.resume()

    return task.response?.description ?? "request complete"
    
}
```

### V4 Pre-Signed URL

Similar to the ease of generating authentication headers, to generate a pre-signed url:
```ruby
      let presignedURL = signer.presignedURLV4(httpMethod: HTTPMethod, urlString: String, expiration: TimeFromNow, headers: [String:String]) -> URLV4Returnable

      let urlString = presignedURL.urlString
      let headers = presignedURL.headers
  ```
### V2 Pre-Signed URL

V4 is the only authorization accepted by all s3 regions, however, since I had the implementation complete I decided to include V2 as well.

```ruby
    let presignedURL = presignedURLV2(urlString: String, expiration: TimeFromNow) throws -> String
```
### Known Limitations
- bucket names that contain "-" may get a 403 response("Signature does not match") from AWS.
