//
//  ┌────┬─┐         ┌─────┐
//  │  ──┤ └─┬───┬───┤  ┌──┼─┬─┬───┐
//  ├──  │ ╷ │ · │ · │  ╵  │ ╵ │ ╷ │
//  └────┴─┴─┴───┤ ┌─┴─────┴───┴─┴─┘
//               └─┘
//
//  Copyright (c) 2018 ShopGun. All rights reserved.

import Foundation

extension Error {
    /// Use to check if the error is a cancellation error or not
    /// Note: use constraint extensions to make custom error types also respond to this correctly. eg.
    /// ```
    /// extension Error where Self == MY_ERROR_TYPE {
    ///   var isCancellationError: Bool {
    ///     return true
    ///   }
    /// }
    /// ```
    public var isCancellationError: Bool {
        switch ((self as NSError).domain, (self as NSError).code) {
        case (NSURLErrorDomain, NSURLErrorCancelled):
            return true
        default:
            return false
        }
    }
    
}

extension NSError {
    
    @objc
    public var isNetworkError: Bool {
        guard self.domain == NSURLErrorDomain else {
            return false
        }
        
        switch self.code {
        case NSURLErrorTimedOut,
             NSURLErrorCannotFindHost,
             NSURLErrorCannotConnectToHost,
             NSURLErrorNetworkConnectionLost,
             NSURLErrorDNSLookupFailed,
             NSURLErrorNotConnectedToInternet,
             NSURLErrorInternationalRoamingOff,
             NSURLErrorCallIsActive,
             NSURLErrorDataNotAllowed,
             NSURLErrorResourceUnavailable,
             NSURLErrorBadServerResponse,
             NSURLErrorFileDoesNotExist,
             NSURLErrorNoPermissionsToReadFile:
            return true
        default:
            return false
        }
    }
}
