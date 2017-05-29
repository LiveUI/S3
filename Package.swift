//
//  Package.swift
//  S3
//
//  Created by Ondrej Rafaj on 24/11/2016.
//  Copyright © 2016 manGoweb UK Ltd. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "S3",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2),
        .Package(url: "https://github.com/vzsg/S3SignerAWS.git", majorVersion: 2),
        .Package(url: "https://github.com/manGoweb/MimeLib.git", majorVersion: 1)
    ],
    exclude: []
)
