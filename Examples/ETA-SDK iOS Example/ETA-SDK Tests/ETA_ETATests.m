//
//  ETA_ETATests.m
//  ETA-SDK Tests
//
//  Created by Laurie Hufford on 7/10/13.
//
//

#import "ETA_ETATests.h"

#import "ETA.h"

@implementation ETA_ETATests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void) testETAInit
{
    [ETA initializeSDKWithAPIKey:nil apiSecret:nil baseURL:nil];
    
    STAssertNil(ETA.SDK, @"Invalid init must lead to nil ETA.SDK");
    
    NSString* key = @"TEST-API-KEY";
    NSString* secret = @"TEST-API-SECRET";
    NSURL* baseURL = [NSURL URLWithString:@"http://eta.dk"];
    
    [ETA initializeSDKWithAPIKey:key apiSecret:secret baseURL:baseURL];
    
    STAssertEqualObjects(ETA.SDK.apiKey, key, @"ETA.SDK API Key must match that used in initialization");
    STAssertEqualObjects(ETA.SDK.apiSecret, secret, @"ETA.SDK API Secret must match that used in initialization");
    STAssertEqualObjects(ETA.SDK.baseURL, baseURL, @"ETA.SDK baseURL must match that used in initialization");
    
    
    [ETA initializeSDKWithAPIKey:nil apiSecret:nil baseURL:nil];
    
    STAssertNotNil(ETA.SDK, @"Invalid init AFTER valid init must not lead to nil ETA.SDK");
}

- (void) testETAGeolocation
{
    ETA* eta = [ETA etaWithAPIKey:@"" apiSecret:@""];
    
    STAssertNil(eta.location, @"ETA.location must be nil when first created");
    STAssertNil(eta.distance, @"ETA.distance must be nil when first created");
    STAssertEquals(eta.isLocationFromSensor, NO, @"ETA.isLocationFromSensor must be NO when first created");
    
    
    [eta setLatitude:123.45 longitude:123.45 distance:10000 isFromSensor:YES];
    
    STAssertEquals(eta.location.coordinate.latitude, 123.45, @"eta.location.latitude must be set correctly");
    STAssertEquals(eta.location.coordinate.longitude, 123.45, @"eta.location.longitude must be set correctly");
    STAssertEqualObjects(eta.distance, @(10000), @"eta.location.distance must be set correctly");
    STAssertEquals(eta.isLocationFromSensor, YES, @"eta.location.isLocationFromSensor must be set correctly");
}

@end