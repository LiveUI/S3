import S3DemoApp
import Service
import Vapor

do {
    var env: Vapor.Environment = .testing
    let app = Application(environment: env, configure: { services in
        try S3DemoApp.configure(env: &env, &services)
    })

    try app.run()
} catch {
    print("Top-level failure: \(error)")
}

