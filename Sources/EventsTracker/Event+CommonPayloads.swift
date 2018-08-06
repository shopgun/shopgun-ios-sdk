//
//  ┌────┬─┐         ┌─────┐
//  │  ──┤ └─┬───┬───┤  ┌──┼─┬─┬───┐
//  ├──  │ ╷ │ · │ · │  ╵  │ ╵ │ ╷ │
//  └────┴─┴─┴───┤ ┌─┴─────┴───┴─┴─┘
//               └─┘
//
//  Copyright (c) 2018 ShopGun. All rights reserved.

import Foundation

extension Event {
    
    fileprivate enum CommonPayloadKeys: String {
        case appId                  = "_a" // NOTE: AppId is a semi-special case. For shipping events it is required, but not for constructing events.
        case locationHash           = "l.h"
        case locationHashTimestamp  = "l.ht"
        case locationCountryCode    = "l.c"
        case viewToken              = "vt"
    }
    
    func addingAppIdentifier(_ appId: EventsTracker.AppIdentifier) -> Event {
        var event = self
        event.mergePayload([CommonPayloadKeys.appId.rawValue: .string(appId.rawValue)])
        return event
    }
    
    func addingLocation(geohash: String, timestamp: Date) -> Event {
        var event = self
        event.mergePayload([CommonPayloadKeys.locationHash.rawValue: .string(geohash),
                            CommonPayloadKeys.locationHashTimestamp.rawValue: .int(timestamp.eventTimestamp)])
        return event
    }
    
    func addingCountryCode(_ countryCode: String) -> Event {
        var event = self
        event.mergePayload([CommonPayloadKeys.locationCountryCode.rawValue: .string(countryCode)])
        return event
    }
    
    func addingViewToken(contentId: String, tokenizer: Tokenizer = UniqueViewTokenizer.shared.tokenize) -> Event {
        var event = self
        event.mergePayload([CommonPayloadKeys.viewToken.rawValue: .string(tokenizer(contentId))])
        return event
    }
}
