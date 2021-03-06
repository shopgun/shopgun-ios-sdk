ShopGunSDK
==========

[![Build Status](https://travis-ci.org/shopgun/shopgun-ios-sdk.svg?branch=master)](https://travis-ci.org/shopgun/shopgun-ios-sdk)
[![Version](https://img.shields.io/cocoapods/v/ShopGunSDK.svg?style=flat)](http://cocoapods.org/pods/ShopGunSDK)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE.md)
[![Swift](http://img.shields.io/badge/swift-4.2-brightgreen.svg)](https://swift.org)

## Introduction

This is a framework for interacting with the ShopGun APIs from within your own apps. The SDK has been split into several components:

| Component | Description |
| :--- | :--- |
| **`PagedPublicationView`** | A view for fetching, rendering, and interacting with, a catalog. |
| **`IncitoPublication`** | A view controller for fetching, rendering, and interacting with, a digital catalog (an "[Incito](https://github.com/shopgun/incito-ios)"). |
| 🤝 **`CoreAPI`** | Simplifies auth & communication with the ShopGun REST API. |
| 🔗 **`GraphAPI`** | An interface for easily making requests to ShopGun's GraphQL API. |
| 📡 **`EventsTracker`** | An events tracker for efficiently sending analytics events. |


## Guides

#### 💾 [Installation](Guides/Installation.md) 

#### 💡[Getting Started](Guides/Getting-Started.md)

#### 📚 [API Documentation](http://shopgun.github.io/shopgun-ios-sdk/) 

### Detailed Guides
- [Configuration](Guides/Configuration.md)
- [PagedPublicationView](Guides/PagedPublicationView.md)
- [IncitoPublication](Guides/IncitoPublication.md)
- [CoreAPI](Guides/CoreAPI.md)
- [GraphAPI](Guides/GraphAPI.md)
- [EventsTracker](Guides/EventsTracker.md)
- [Logging](Guides/Logging.md)

## Quick Start

### Requirements

- iOS 9.3+
- Xcode 9.0+
- Swift 4.2+

### Installation

The preferred way to install the `ShopGunSDK` framework into your own app is using [CocoaPods](https://cocoapods.org/). Add the following to your `Podfile`:

```ruby
pod 'ShopGunSDK'
```

For more detailed instructions, see the [Installation](Guides/Installation.md) guide.

### Examples

The repo uses a swift playground to demonstrate example uses of the components. 

- Download/checkout this repo.
- Make sure you recursively checkout all the submodules in the `External` folder.
- Open the `ShopGunSDK.xcodeproj`, and build the ShopGunSDK scheme (using a simulator destination)
- Open the `ShopGunSDK.playground` that is referenced inside the project. From here, you will be able experiment with the SDK.

> **Note:** In order to use the components properly they must be configured with the correct API keys. Set the values in the playground's `Resources/ShopGunSDK-Config.plist` file with your own API keys (accessible from the [ShopGun Developer page](https://shopgun.com/developers))
> 
> **Also Note:** Xcode Playgrounds can be a bit flaky when it comes to importing external frameworks. If it complains, try cleaning the build folder and rebuilding the SDK (targetting a simulator), and if it continues, restart Xcode. Also sometimes commenting out contents of the `playgroundLogHandler.swift` file, and then uncommenting again, helps.

For a more detailed guide, see the [Getting Started](Guides/Getting-Started.md) guide.


## Changelog
For a history of changes to the SDK, see the [CHANGES](CHANGES.md) file.

## License
The `ShopGunSDK` is released under the MIT license. See [LICENSE](LICENSE.md) for details.