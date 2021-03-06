//
//  ┌────┬─┐         ┌─────┐
//  │  ──┤ └─┬───┬───┤  ┌──┼─┬─┬───┐
//  ├──  │ ╷ │ · │ · │  ╵  │ ╵ │ ╷ │
//  └────┴─┴─┴───┤ ┌─┴─────┴───┴─┴─┘
//               └─┘
//
//  Copyright (c) 2018 ShopGun. All rights reserved.

import XCTest
@testable import ShopGunSDK

class EventsTrackerTests: XCTestCase {

    func testLegacyPoolCleaner() {
        
        let legacyCacheFilename = "legacyCache.plist"

        // clear legacy cache
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        try? FileManager.default.removeItem(at: directory!.appendingPathComponent(legacyCacheFilename))
        
        let legacyCacheWriter = EventsCache_v1(fileName: legacyCacheFilename)
        legacyCacheWriter.write(toTail: [("a", Data()),
                                         ("b", Data())])
        
        let expectLegacyCacheEmptied = expectation(description: "Cache should be emptied")
        
        // wait for the cache to save to disk
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            
            EventsTracker.legacyPoolCleaner(cacheFileName: legacyCacheFilename,
                                            dispatchInterval: 1,
                                            baseURL: URL(string: "https://events.service-staging.shopgun.com")!,
                                            enabled: false) { (shippedCount) in
                XCTAssertEqual(shippedCount, 2)
                // TODO: make sure the cache has been cleared
                expectLegacyCacheEmptied.fulfill()
            }
        }
        
        waitForExpectations(timeout: 15)
    }
}
