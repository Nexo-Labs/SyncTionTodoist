// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

/*
This file is part of SyncTion and is licensed under the GNU General Public License version 3.
SyncTion is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import PackageDescription

let package = Package(
    name: "SyncTionTodoist",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SyncTionTodoist",
            targets: ["SyncTionTodoist"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Fiser12/PreludePackage", from: "0.0.3"),
        .package(url: "https://github.com/Fiser12/SyncTionCore", from: "0.2.1")
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SyncTionTodoist",
            dependencies: ["SyncTionCore", "PreludePackage"]),
        .testTarget(
            name: "SyncTionTodoistTests",
            dependencies: ["SyncTionTodoist"]),
    ]
)
