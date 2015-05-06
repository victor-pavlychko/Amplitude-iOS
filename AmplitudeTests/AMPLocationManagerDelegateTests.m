//
//  AMPLocationManagerDelegateTests.m
//  AMPLocationManagerDelegateTests
//
//  Created by Curtis on 1/3/2015.
//  Copyright (c) 2015 Amplitude. All rights reserved.
//

#import <XCTest/XCTest.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif // TARGET_OS_IPHONE

#import <OCMock/OCMock.h>
#import "AMPLocationManagerDelegate.h"


@interface AMPLocationManagerDelegateTests : XCTestCase

@end

@implementation AMPLocationManagerDelegateTests

AMPLocationManagerDelegate *locationManagerDelegate;
CLLocationManager *locationManager;

- (void)setUp {
    [super setUp];
    locationManager = [[CLLocationManager alloc] init];
    locationManagerDelegate = [[AMPLocationManagerDelegate alloc] init];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testDidFailWithError {
    [locationManagerDelegate locationManager:locationManager didFailWithError:nil];
    
}

- (void)testDidUpdateToLocation {
    [locationManagerDelegate locationManager:locationManager didUpdateToLocation:nil fromLocation:nil];
    
}

- (void)testDidChangeAuthorizationStatus {
    [locationManagerDelegate locationManager:locationManager
                didChangeAuthorizationStatus:kCLAuthorizationStatusAuthorized];
#if TARGET_OS_IPHONE
    [locationManagerDelegate locationManager:locationManager
                didChangeAuthorizationStatus:kCLAuthorizationStatusAuthorizedAlways];
    [locationManagerDelegate locationManager:locationManager
                didChangeAuthorizationStatus:kCLAuthorizationStatusAuthorizedWhenInUse];
#else
    [locationManagerDelegate locationManager:locationManager
                didChangeAuthorizationStatus:kCLAuthorizationStatusAuthorized];
#endif
    
}
@end
