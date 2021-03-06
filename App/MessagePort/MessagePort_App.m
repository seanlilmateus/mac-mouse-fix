//
// --------------------------------------------------------------------------
// MessagePort_App.m
// Created for Mac Mouse Fix (https://github.com/noah-nuebling/mac-mouse-fix)
// Created by Noah Nuebling in 2019
// Licensed under MIT
// --------------------------------------------------------------------------
//

#import "MessagePort_App.h"
#import "../Accessibility/AuthorizeAccessibilityView.h"
#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@implementation MessagePort_App


#pragma mark - local (incoming messages)


+ (void)load {
    
    if (self == [MessagePort_App class]) {
        CFMessagePortRef localPort =
        CFMessagePortCreateLocal(kCFAllocatorDefault,
                             CFSTR("com.nuebling.mousefix.port"),
                             didReceiveMessage,
                             nil,
                             NULL);
        
        // setting the name here instead of when creating the port creates some super weird behavior, too.
//        CFMessagePortSetName(localPort, CFSTR("com.nuebling.mousefix.port"));
        
        // on Catalina, creating the local Port returns NULL and throws a permission denied error. Trying to schedule it with the runloop yields a crash.
        // But even if you just skip the runloop scheduling it still works somehow!
        if (localPort != NULL) {
            // Could set up message port. Scheduling with run loop.
            CFRunLoopSourceRef runLoopSource =
                CFMessagePortCreateRunLoopSource(kCFAllocatorDefault, localPort, 0);
            
            CFRunLoopAddSource(CFRunLoopGetMain(),
                               runLoopSource,
                               kCFRunLoopCommonModes);
            CFRelease(runLoopSource);
        } else {
            // Couldn't set up message port. But it'll probably work anyways for some reason.
        }
    }
}

static CFDataRef didReceiveMessage(CFMessagePortRef port, SInt32 messageID, CFDataRef data, void *info) {
    
    NSString *message = [[NSString alloc] initWithData:(__bridge NSData *)data encoding:NSUTF8StringEncoding];
    
    NSLog(@"Main App Received Message: %@", message);
    
    if ([message isEqualToString:@"accessibilityDisabled"]) {
        [AuthorizeAccessibilityView add];
        [(AppDelegate *)NSApp.delegate stopRemoveAccOverlayTimer]; // If App delegate is about to remove the acc overlay, stop that
    }
    
    NSData *response = NULL;
    return (__bridge CFDataRef)response;
}


#pragma mark - remote (outgoing messages)

+ (void)sendMessageToHelper:(NSString *)message {
    
    NSLog(@"Sending message to Helper: %@", message);
    
    CFMessagePortRef remotePort = CFMessagePortCreateRemote(kCFAllocatorDefault, CFSTR("com.nuebling.mousefix.helper.port"));
    if (remotePort == NULL) {
        NSLog(@"there is no CFMessagePort");
        return;
    }
    
    SInt32 messageID = 0x420666; // Arbitrary
    CFDataRef messageData = (__bridge CFDataRef)[message dataUsingEncoding:kUnicodeUTF8Format];
    CFTimeInterval sendTimeout = 0.0;
    CFTimeInterval recieveTimeout = 0.0;
    CFStringRef replyMode = NULL;
    CFDataRef returnData = nil;
    SInt32 status = CFMessagePortSendRequest(remotePort, messageID, messageData, sendTimeout, recieveTimeout, replyMode, &returnData);
    if (status != 0) {
        NSLog(@"CFMessagePortSendRequest status: %d", status);
    }
    CFRelease(remotePort);
}

//+ (NSString *)sendMessageWithReplyToHelper:(NSString *)message {
//    
//    NSLog(@"Sending message to Helper");
//    
//    CFMessagePortRef remotePort = CFMessagePortCreateRemote(kCFAllocatorDefault, CFSTR("com.nuebling.mousefix.helper.port"));
//    if (remotePort == NULL) {
//        NSLog(@"there is no CFMessagePort");
//        return NULL;
//    }
//    
//    SInt32 messageID = 0x420666; // Arbitrary
//    CFDataRef messageData = (__bridge CFDataRef)[message dataUsingEncoding:kUnicodeUTF8Format];
//    CFTimeInterval sendTimeout = 0.0;
//    CFTimeInterval recieveTimeout = 1;
//    CFStringRef replyMode = kCFRunLoopDefaultMode;
//    CFDataRef returnData;
//    SInt32 status = CFMessagePortSendRequest(remotePort, messageID, messageData, sendTimeout, recieveTimeout, replyMode, &returnData);
//    if (status != 0) {
//        NSLog(@"CFMessagePortSendRequest status: %d", status);
//    }
//    
//    return [[NSString alloc] initWithData:(__bridge NSData *)returnData encoding:NSUTF8StringEncoding];
//}


@end
