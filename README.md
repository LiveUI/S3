# S3 client for Vapor 3


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
s3.put(...)
s3.get(...)
s3.delete(...)
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
