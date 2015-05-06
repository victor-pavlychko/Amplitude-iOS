//
//  SessionTests.m
//  SessionTests
//
//  Created by Curtis on 9/24/14.
//  Copyright (c) 2014 Amplitude. All rights reserved.
//

#import <XCTest/XCTest.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif // TARGET_OS_IPHONE

#import <OCMock/OCMock.h>
#import "Amplitude.h"
#import "Amplitude+Test.h"
#import "BaseTestCase.h"

@interface SessionTests : BaseTestCase

@end

@implementation SessionTests { }

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSessionAutoStarted {
#if TARGET_OS_IPHONE
    id mockApplication = [OCMockObject niceMockForClass:[UIApplication class]];
    [[[mockApplication stub] andReturn:mockApplication] sharedApplication];
    OCMStub([mockApplication applicationState]).andReturn(UIApplicationStateActive);
#else
    id mockApplication = [OCMockObject niceMockForClass:[NSApplication class]];
    [[[mockApplication stub] andReturn:mockApplication] sharedApplication];
    OCMStub([mockApplication isActive]).andReturn(YES);
#endif // TARGET_OS_IPHONE

    [self.amplitude initializeApiKey:apiKey];
    [self.amplitude flushQueue];
    XCTAssertEqual([self.amplitude queuedEventCount], 1);
    XCTAssert([[self.amplitude getLastEvent][@"event_type"] isEqualToString:@"session_start"]);

    [mockApplication stopMocking];
}

- (void)testSessionAutoStartedBackground {
#if TARGET_OS_IPHONE
    id mockApplication = [OCMockObject niceMockForClass:[UIApplication class]];
    [[[mockApplication stub] andReturn:mockApplication] sharedApplication];
    OCMStub([mockApplication applicationState]).andReturn(UIApplicationStateBackground);
#else
    id mockApplication = [OCMockObject niceMockForClass:[NSApplication class]];
    [[[mockApplication stub] andReturn:mockApplication] sharedApplication];
    OCMStub([mockApplication isActive]).andReturn(NO);
#endif // TARGET_OS_IPHONE

    [self.amplitude initializeApiKey:apiKey];
    [self.amplitude flushQueue];
    XCTAssertEqual([self.amplitude queuedEventCount], 0);

    [mockApplication stopMocking];
}

- (void)testSessionAutoStartedInactive {
#if TARGET_OS_IPHONE
    id mockApplication = [OCMockObject niceMockForClass:[UIApplication class]];
    [[[mockApplication stub] andReturn:mockApplication] sharedApplication];
    OCMStub([mockApplication applicationState]).andReturn(UIApplicationStateInactive);
#else
    id mockApplication = [OCMockObject niceMockForClass:[NSApplication class]];
    [[[mockApplication stub] andReturn:mockApplication] sharedApplication];
    OCMStub([mockApplication isActive]).andReturn(YES);
#endif // TARGET_OS_IPHONE

    [self.amplitude initializeApiKey:apiKey];
    [self.amplitude flushQueue];
    XCTAssertEqual([self.amplitude queuedEventCount], 1);
    XCTAssert([[self.amplitude getLastEvent][@"event_type"] isEqualToString:@"session_start"]);

    [mockApplication stopMocking];
}

- (void)testSessionStarted {
    [self.amplitude initializeApiKey:apiKey userId:nil startSession:YES];
    [self.amplitude flushQueue];
    XCTAssertEqual([self.amplitude queuedEventCount], 1);
    XCTAssert([[self.amplitude getLastEvent][@"event_type"] isEqualToString:@"session_start"]);
}

- (void)testSessionNotStarted {
    [self.amplitude initializeApiKey:apiKey userId:nil startSession:NO];
    [self.amplitude flushQueue];
    XCTAssertEqual([self.amplitude queuedEventCount], 0);
}

/**
 * Any number of session start calls should only generate exactly one logged event.
 */
- (void)testStartSession {
    [self.amplitude initializeApiKey:apiKey userId:nil startSession:NO];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
#if TARGET_OS_IPHONE
    [center postNotificationName:UIApplicationDidBecomeActiveNotification object:nil userInfo:nil];
    [center postNotificationName:UIApplicationDidBecomeActiveNotification object:nil userInfo:nil];
#else
    [center postNotificationName:NSApplicationDidBecomeActiveNotification object:nil userInfo:nil];
    [center postNotificationName:NSApplicationDidBecomeActiveNotification object:nil userInfo:nil];
#endif // TARGET_OS_IPHONE

    [self.amplitude flushQueue];
    XCTAssertEqual([self.amplitude queuedEventCount], 1);

    NSDictionary *event = [self.amplitude getLastEvent];
    XCTAssert([event[@"event_type"] isEqualToString:@"session_start"]);
    XCTAssertEqual(event[@"session_id"], event[@"timestamp"]);
}

- (void)testSessionEnd {
    [self.amplitude initializeApiKey:apiKey userId:nil startSession:NO];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
#if TARGET_OS_IPHONE
    [center postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil userInfo:nil];
#else
    [center postNotificationName:NSApplicationDidResignActiveNotification object:nil userInfo:nil];
#endif // TARGET_OS_IPHONE

    [self.amplitude flushQueue];
    XCTAssertEqual([self.amplitude queuedEventCount], 1);
    XCTAssert([[self.amplitude getEvent:0][@"event_type"] isEqualToString:@"session_end"]);
}

- (void)testManualStartSession {
    [self.amplitude initializeApiKey:apiKey userId:nil startSession:NO];

    [self.amplitude startSession];

    [self.amplitude flushQueue];
    XCTAssertEqual([self.amplitude queuedEventCount], 1);

    NSDictionary *event = [self.amplitude getLastEvent];
    XCTAssert([event[@"event_type"] isEqualToString:@"session_start"]);
    XCTAssertEqual(event[@"session_id"], event[@"timestamp"]);
}
/**
 * Ending a session should case another start session event to be logged.
 */
- (void)testSessionRestart {
    [self.amplitude initializeApiKey:apiKey userId:nil startSession:NO];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
#if TARGET_OS_IPHONE
    [center postNotificationName:UIApplicationDidBecomeActiveNotification object:nil userInfo:nil];
    [center postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil userInfo:nil];
    [center postNotificationName:UIApplicationDidBecomeActiveNotification object:nil userInfo:nil];
#else
    [center postNotificationName:NSApplicationDidBecomeActiveNotification object:nil userInfo:nil];
    [center postNotificationName:NSApplicationDidResignActiveNotification object:nil userInfo:nil];
    [center postNotificationName:NSApplicationDidBecomeActiveNotification object:nil userInfo:nil];
#endif

    [self.amplitude flushQueue];
    XCTAssertEqual([self.amplitude queuedEventCount], 3);
    XCTAssert([[self.amplitude getEvent:0][@"event_type"] isEqualToString:@"session_start"]);
    XCTAssert([[self.amplitude getEvent:1][@"event_type"] isEqualToString:@"session_end"]);
    XCTAssert([[self.amplitude getEvent:2][@"event_type"] isEqualToString:@"session_start"]);
}

@end
