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
    
    /**
     These are the set of reserved event types that the knows how to handle.
     */
    public enum EventType: Int {
        case dummy                          = 0
        case pagedPublicationOpened         = 1
        case pagedPublicationPageOpened     = 2
        case offerOpened                    = 3
        case clientSessionOpened            = 4
        case searched                       = 5
        case firstOfferOpenedAfterSearch    = 6
        case offerOpenedAfterSearch         = 7
        @available(*, deprecated, renamed: "incitoPublicationOpened_v2")
        case incitoPublicationOpened        = 8
        case searchResultsViewed            = 9
        case potentialLocalBusinessVisit    = 10
        case incitoPublicationOpened_v2     = 11
    }
    
    /**
     The dummy event used for testing purposes.
     - parameter timestamp: The date that the event occurred. Defaults to now.
     */
    internal static func dummy(timestamp: Date = Date()) -> Event {
        return Event(timestamp: timestamp,
                     type: EventType.dummy.rawValue)
    }
    
    /**
     The event when a paged publication has been "opened" by a user. In general, "opening" a paged publication means any action that results in the paged publication being presented for browsing, which would also result in a paged publication page event.
     - parameter publicationId: The uuid of the publication.
     - parameter timestamp: The date that the event occurred. Defaults to now.
     - parameter tokenizer: A Tokenizer for generating the unique view token. Defaults to the shared EventsTrackers's viewTokenizer.
     */
    internal static func pagedPublicationOpened(
        _ publicationId: CoreAPI.PagedPublication.Identifier,
        timestamp: Date = Date(),
        tokenizer: Tokenizer = EventsTracker.shared.viewTokenizer.tokenize
        ) -> Event {
        
        let payload: PayloadType = ["pp.id": .string(publicationId.rawValue)]
        
        return Event(timestamp: timestamp,
                     type: EventType.pagedPublicationOpened.rawValue,
                     payload: payload)
            .addingViewToken(content: publicationId.rawValue, tokenizer: tokenizer)
    }
    
    /**
     The event when a paged publication page has been "presented" to the user. "presented" in this context means any action that results in the paged publication page being drawn to the screen.
     - parameter publicationId: The uuid of the publication.
     - parameter pageNumber: The (1-indexed) number of the opened page.
     - parameter timestamp: The date that the event occurred. Defaults to now.
     - parameter tokenizer: A Tokenizer for generating the unique view token. Defaults to the shared EventsTrackers's viewTokenizer.
     */
    internal static func pagedPublicationPageOpened(
        _ publicationId: CoreAPI.PagedPublication.Identifier,
        pageNumber: Int,
        timestamp: Date = Date(),
        tokenizer: Tokenizer = EventsTracker.shared.viewTokenizer.tokenize
        ) -> Event {
        
        let payload: PayloadType = ["pp.id": .string(publicationId.rawValue),
                                    "ppp.n": .int(pageNumber)]
        
        let viewTokenContent: String = {
            var intAddr = UInt32(pageNumber).bigEndian
            let intData = Data(buffer: UnsafeBufferPointer(start: &intAddr, count: 1))
            return publicationId.rawValue + (String(data: intData, encoding: .utf8) ?? "")
        }()
        
        return Event(timestamp: timestamp,
                     type: EventType.pagedPublicationPageOpened.rawValue,
                     payload: payload)
            .addingViewToken(content: viewTokenContent, tokenizer: tokenizer)
    }
    
    /**
     The event when an offer has been "presented" to the user. "presented" in this context means any action that results in the offer information (often, but not necessarily the offer image) being drawn to the screen.
     - parameter offerId: The uuid of the offer.
     - parameter timestamp: The date that the event occurred. Defaults to now.
     - parameter tokenizer: A Tokenizer for generating the unique view token. Defaults to the shared EventsTrackers's viewTokenizer.
     */
    internal static func offerOpened(
        _ offerId: CoreAPI.Offer.Identifier,
        timestamp: Date = Date(),
        tokenizer: Tokenizer = EventsTracker.shared.viewTokenizer.tokenize
        ) -> Event {
        
        let payload: PayloadType = ["of.id": .string(offerId.rawValue)]
        
        return Event(timestamp: timestamp,
                     type: EventType.offerOpened.rawValue,
                     payload: payload)
            .addingViewToken(content: offerId.rawValue, tokenizer: tokenizer)
    }
    
    /**
     The event when the application is brought to the foreground. For phone apps this is every time the app is opened/resumed.
     - parameter timestamp: The date that the event occurred. Defaults to now.
     */
    internal static func clientSessionOpened(timestamp: Date = Date()) -> Event {
        return Event(timestamp: timestamp,
                     type: EventType.clientSessionOpened.rawValue)
    }
    
    /**
     The event when a search is performed against the system.
     - parameter query: The search query as entered by the user.
     - parameter languageCode: The language the user is searching with (2-character ISO-639-1 code, or nil if no language can be detected)
     - parameter timestamp: The date that the event occurred. Defaults to now.
     - parameter tokenizer: A Tokenizer for generating the unique view token. Defaults to the shared EventsTrackers's viewTokenizer.
     */
    internal static func searched(
        for query: String,
        languageCode: String?,
        timestamp: Date = Date(),
        tokenizer: Tokenizer = EventsTracker.shared.viewTokenizer.tokenize
        ) -> Event {
        
        var payload: PayloadType = ["sea.q": .string(query)]
        if let lang = languageCode {
            payload["sea.l"] = .string(lang)
        }
        
        return Event(timestamp: timestamp,
                     type: EventType.searched.rawValue,
                     payload: payload)
            .addingViewToken(content: query, tokenizer: tokenizer)
    }
    
    /**
     The event when a search is performed against the system, and that search leads to an offer being opened. This is only triggered for the _first_ offer to be interacted with.
     - parameter offerId: The Id of the offer that was opened.
     - parameter precedingOfferIds: An ordered list of offer ids that were shown above the offer that was interacted with. Empty list if only one offer was retrieved and clicked. This includes results from pagination. Internally, this list is prefixed (prefixed, not suffixed!) to 100 items.
     - parameter query: The search query, as entered by the user, that lead to the offer being opened.
     - parameter languageCode: The language the user is searching with (2-character ISO-639-1 code, or nil if no language can be detected)
     - parameter timestamp: The date that the event occurred. Defaults to now.
     */
    internal static func firstOfferOpenedAfterSearch(
        offerId: CoreAPI.Offer.Identifier,
        precedingOfferIds: [CoreAPI.Offer.Identifier],
        query: String,
        languageCode: String?,
        timestamp: Date = Date()
        ) -> Event {
        
        var payload: PayloadType = [
            "sea.q": .string(query),
            "of.id": .string(offerId.rawValue),
            "of.ids": .array(precedingOfferIds
                .prefix(100)
                .map { .string($0.rawValue) })
        ]
        
        if let lang = languageCode {
            payload["sea.l"] = .string(lang)
        }
        
        return Event(timestamp: timestamp,
                     type: EventType.firstOfferOpenedAfterSearch.rawValue,
                     payload: payload)
    }
    
    /**
     The event when a search is performed against the system, and that search leads to an offer being opened.
     - parameter offerId: The Id of the offer that was opened.
     - parameter query: The search query, as entered by the user, that lead to the offer being opened.
     - parameter languageCode: The language the user is searching with (2-character ISO-639-1 code, or nil if no language can be detected)
     - parameter timestamp: The date that the event occurred. Defaults to now.
     */
    internal static func offerOpenedAfterSearch(
        offerId: CoreAPI.Offer.Identifier,
        query: String,
        languageCode: String?,
        timestamp: Date = Date()
        ) -> Event {
        
        var payload: PayloadType = [
            "sea.q": .string(query),
            "of.id": .string(offerId.rawValue)
        ]
        
        if let lang = languageCode {
            payload["sea.l"] = .string(lang)
        }
        
        return Event(timestamp: timestamp,
                     type: EventType.offerOpenedAfterSearch.rawValue,
                     payload: payload)
    }
    
    /**
     The event when an incito publication has been "opened" by a user. In general, "opening" an incito publication means any action that results in the incito's contents being presented for browsing.
     - parameter incitoId: The uuid of the incito.
     - parameter pagedPublicationId: The (optional) uuid of the pagedPublication related to this incito, if known.
     - parameter timestamp: The date that the event occurred. Defaults to now.
     - parameter tokenizer: A Tokenizer for generating the unique view token. Defaults to the shared EventsTrackers's viewTokenizer.
     */
    @available(*, deprecated, renamed: "incitoPublicationOpened(_:isAlsoPagedPublication:timestamp:tokenizer:)")
    internal static func incitoPublicationOpened(
        _ incitoId: IncitoGraphIdentifier,
        pagedPublicationId: PagedPublicationCoreAPIIdentifier?,
        timestamp: Date = Date(),
        tokenizer: Tokenizer = EventsTracker.shared.viewTokenizer.tokenize
        ) -> Event {
        
        let payload: PayloadType = ["ip.id": .string(incitoId.rawValue)]
        
        var event = Event(timestamp: timestamp,
                          type: EventType.incitoPublicationOpened.rawValue,
                          payload: payload)
            .addingViewToken(content: incitoId.rawValue, tokenizer: tokenizer)
        
        if let pagedPubId = pagedPublicationId {
            event = event.addingViewToken(content: pagedPubId.rawValue, key: "pp.vt", tokenizer: tokenizer)
        }
        
        return event
    }
    
    internal static func incitoPublicationOpened(
        _ incitoPublicationId: PagedPublicationCoreAPIIdentifier,
        isAlsoPagedPublication: Bool,
        timestamp: Date = Date(),
        tokenizer: Tokenizer = EventsTracker.shared.viewTokenizer.tokenize
        ) -> Event {
        
        let payload: PayloadType = [
            "ip.id": .string(incitoPublicationId.rawValue),
            "ip.paged": .bool(isAlsoPagedPublication)
        ]
        
        let event = Event(timestamp: timestamp,
                          type: EventType.incitoPublicationOpened_v2.rawValue,
                          payload: payload)
            .addingViewToken(content: incitoPublicationId.rawValue, tokenizer: tokenizer)
        
        return event
    }
    
    /**
     The event when a search is performed against the system, the user views the search results, and then the users leaves the search results screen.
     - parameter query: The search query, as entered by the user, that lead to the offer results being shown.
     - parameter languageCode: The language the user is searching with (2-character ISO-639-1 code, or nil if no language can be detected)
     - parameter resultsViewedCount: The total number of unique results seen by the user before they leave the screen. Cannot be < 1.
     - parameter timestamp: The date that the event occurred. Defaults to now.
     */
    internal static func searchResultsViewed(
        query: String,
        languageCode: String?,
        resultsViewedCount: Int,
        timestamp: Date = Date()
        ) -> Event {

        var payload: PayloadType = [
            "sea.q": .string(query),
            "sea.v": .int(resultsViewedCount)
        ]
        
        if let lang = languageCode {
            payload["sea.l"] = .string(lang)
        }
        
        return Event(timestamp: timestamp,
                     type: EventType.searchResultsViewed.rawValue,
                     payload: payload)
    }
    
    /**
     The event when a user opened the app close to a store. The event is only triggered if gps traking is enabled, user gps location has accuracy below a specified radial distance and closest store is within a specified radial distance.
     - parameter storeId: The id of the closest store, within specified radial distance.
     - parameter dealerId: The id of the business to which the store belongs to.
     - parameter horizontalAccuracy: Device's horizontal accuracy of its geolocation information in meters.
     - parameter distanceToStore: Estimated distance between device and store, in meters.
     - parameter timeSinceLastInteraction: Time passed (in secs) since the content interaction and the potential local business visit. Nil if no interaction was recorded.
     - parameter timestamp: The date that the event occurred. Defaults to now.
     - parameter tokenizer: A Tokenizer for generating the unique view token. Defaults to the shared EventsTrackers's viewTokenizer.
     */
    internal static func potentialLocalBusinessVisit(
        for storeId: CoreAPI.Store.Identifier,
        dealerId: CoreAPI.Dealer.Identifier,
        horizontalAccuracy: Double,
        distanceToStore: Double,
        timeSinceLastInteraction: TimeInterval?,
        timestamp: Date = Date(),
        tokenizer: Tokenizer = EventsTracker.shared.viewTokenizer.tokenize
        ) -> Event {
        
        var payload: PayloadType = [
            "l.hac": .int(Int(horizontalAccuracy)),
            "lb.id": .string(storeId.rawValue),
            "lb.dis": .int(Int(distanceToStore)),
            "lb.bid": .string(dealerId.rawValue)
        ]
        
        if let secs = timeSinceLastInteraction {
            payload["b.cin"] = .bool(true)
            payload["b.cint"] = .int(Int(secs / 3600))
        } else {
            payload["b.cin"] = .bool(false)
        }
        
        return Event(timestamp: timestamp, type: EventType.potentialLocalBusinessVisit.rawValue, payload: payload)
            .addingViewToken(content: storeId.rawValue, tokenizer: tokenizer)
    }
}

extension Event {
    
    public static func offerOpened(_ offerId: CoreAPI.Offer.Identifier) -> Event {
        return offerOpened(
            offerId,
            timestamp: Date()
        )
    }
    
    public static func searched(
        for query: String,
        languageCode: String?
        ) -> Event {
        return searched(for: query, languageCode: languageCode, timestamp: Date())
    }
    
    public static func firstOfferOpenedAfterSearch(
        offerId: CoreAPI.Offer.Identifier,
        precedingOfferIds: [CoreAPI.Offer.Identifier],
        query: String,
        languageCode: String?
        ) -> Event {
        return firstOfferOpenedAfterSearch(offerId: offerId, precedingOfferIds: precedingOfferIds, query: query, languageCode: languageCode, timestamp: Date())
    }
    public static func offerOpenedAfterSearch(
        offerId: CoreAPI.Offer.Identifier,
        query: String,
        languageCode: String?
        ) -> Event {
        return offerOpenedAfterSearch(offerId: offerId, query: query, languageCode: languageCode, timestamp: Date())
    }
    
    @available(*, deprecated, renamed: "incitoPublicationOpened(_:isAlsoPagedPublication:)")
    public static func incitoPublicationOpened(
        _ incitoId: IncitoGraphIdentifier,
        pagedPublicationId: PagedPublicationCoreAPIIdentifier?
        ) -> Event {
        return incitoPublicationOpened(
            incitoId,
            pagedPublicationId: pagedPublicationId,
            timestamp: Date()
        )
    }
    
    public static func incitoPublicationOpened(
        _ incitoPublicationId: PagedPublicationCoreAPIIdentifier,
        isAlsoPagedPublication: Bool
        ) -> Event {
        return incitoPublicationOpened(
            incitoPublicationId,
            isAlsoPagedPublication: isAlsoPagedPublication,
            timestamp: Date()
        )
    }
    
    public static func searchResultsViewed(
        query: String,
        languageCode: String?,
        resultsViewedCount: Int
        ) -> Event {
        return searchResultsViewed(query: query, languageCode: languageCode, resultsViewedCount: resultsViewedCount, timestamp: Date())
    }
    
    public static func potentialLocalBusinessVisit(
        for storeId: CoreAPI.Store.Identifier,
        dealerId: CoreAPI.Dealer.Identifier,
        horizontalAccuracy: Double,
        distanceToStore: Double,
        timeSinceLastInteraction: TimeInterval?
        ) -> Event {
        
        return potentialLocalBusinessVisit(for: storeId, dealerId: dealerId, horizontalAccuracy: horizontalAccuracy, distanceToStore: distanceToStore, timeSinceLastInteraction: timeSinceLastInteraction, timestamp: Date())
    }
}
