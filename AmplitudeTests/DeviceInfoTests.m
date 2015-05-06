//
//  DeviceInfoTests.m
//  DeviceInfoTests
//
//  Created by Allan on 4/21/15.
//  Copyright (c) 2015 Amplitude. All rights reserved.
//

#import <XCTest/XCTest.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif // TARGET_OS_IPHONE

#import <OCMock/OCMock.h>
#import "Amplitude.h"
#import "AMPConstants.h"
#import "Amplitude+Test.h"
#import "BaseTestCase.h"
#import "AMPDeviceInfo.h"

@interface DeviceInfoTests : BaseTestCase

@end

@implementation DeviceInfoTests {
    AMPDeviceInfo *_deviceInfo;
}

- (void)setUp {
    [super setUp];
    _deviceInfo = [[AMPDeviceInfo alloc] init];
}

- (void)tearDown {
    [super tearDown];
    _deviceInfo = nil;
}

- (void) testAppVersion {
    id mockBundle = [OCMockObject niceMockForClass:[NSBundle class]];
    OCMStub([mockBundle mainBundle]).andReturn(mockBundle);
    OCMStub([mockBundle infoDictionary]).andReturn(@{
        @"CFBundleShortVersionString": kAMPVersion
    });
    
    XCTAssertEqualObjects(kAMPVersion, _deviceInfo.appVersion);

    [mockBundle stopMocking];
}

- (void) testOsName {
#if TARGET_OS_IPHONE
    XCTAssertEqualObjects(@"ios", _deviceInfo.osName);
#else
    XCTAssertEqualObjects(@"OSX", _deviceInfo.osName);
#endif
}

- (void) testOsVersion {
#if TARGET_OS_IPHONE
    XCTAssertEqualObjects([[UIDevice currentDevice] systemVersion], _deviceInfo.osVersion);
#else
    XCTAssertEqualObjects([[NSProcessInfo processInfo] operatingSystemVersionString], _deviceInfo.osVersion);
#endif
}

- (void) testManufacturer {
    XCTAssertEqualObjects(@"Apple", _deviceInfo.manufacturer);
}

- (void) testModel {
    XCTAssertNotNil(_deviceInfo.model);
#if TARGET_OS_IPHONE
    XCTAssertEqualObjects(@"Simulator", _deviceInfo.model);
#endif
}

- (void) testCarrier {
    // TODO: Not sure how to test this on the simulator
//    XCTAssertEqualObjects(nil, _deviceInfo.carrier);
}

- (void) testCountry {
    XCTAssertEqualObjects(@"United States", _deviceInfo.country);
}

- (void) testLanguage {
    XCTAssertEqualObjects(@"English", _deviceInfo.language);
}

- (void) testAdvertiserID {
    // TODO: Not sure how to test this on the simulator
//    XCTAssertEqualObjects(nil, _deviceInfo.advertiserID);
}

- (void) testVendorID {
    // TODO: Not sure how to test this on the simulator
//    XCTAssertEqualObjects(nil, _deviceInfo.vendorID);
}


- (void) testGenerateUUID {
    NSString *a = [_deviceInfo generateUUID];
    NSString *b = [_deviceInfo generateUUID];
    XCTAssertNotNil(a);
    XCTAssertNotNil(b);
    XCTAssertNotEqual(a, b);
    XCTAssertNotEqual(a, b);
}

@end
