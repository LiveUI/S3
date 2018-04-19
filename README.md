# S3

Register S3Client as a service

```swift
try services.register(s3 config: S3Signer.Config(...), defaultBucket: "my-bucket")
```

use S3Client

```swift
import S3

let s3 = try req.makeS3Client()
s3.put(...)
s3.get(...)
s3.delete(...)
```