# S3 client for Vapor 3

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
s3.put(...)
s3.get(...)
s3.delete(...)
```
