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
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 1),
        .Package(url: "https://github.com/JustinM1/S3SignerAWS.git", majorVersion: 1, minor: 1)
    ],
    exclude: [
        
    ]
)

