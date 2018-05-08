import S3DemoApp
import Service
import Vapor

do {
    var config = Config.default()
    var env = try Environment.detect()
    var services = Services.default()
    
    try S3DemoApp.configure(&config, &env, &services)
    
    let app = try Application(
        config: config,
        environment: env,
        services: services
    )
    
    try app.run()
} catch {
    print("Top-level failure: \(error)")
}

