//
//  AppDelegate.m
//  autoloc
//
//  Created by Joshua Basch on 4/29/15.
//  Copyright (c) 2015 HT154. All rights reserved.
//

#import "AppDelegate.h"

#import <IOKit/ps/IOPowerSources.h>
#import <notify.h>

#define HOME_POWER_APADTER_KEY (@"")

@interface AppDelegate ()

@end

@implementation AppDelegate {
    int token;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self powerChanged];
    
    notify_register_dispatch(kIOPSNotifyPowerSource, &token, dispatch_get_main_queue(), ^(int token) {
        [self powerChanged];
    });
}

-(void)powerChanged {
    NSString *loc = @"Automatic";
    
    CFDictionaryRef pSource = IOPSCopyExternalPowerAdapterDetails();
    
    if (pSource) {
        const void *psValue;
        if ((psValue = CFDictionaryGetValue(pSource, @kIOPSPowerAdapterSerialNumberKey))) {
            if ([(__bridge NSNumber *)psValue isEqualToNumber:@0x0035f890]) {
                loc = @"Home";
            }
        }
    }
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/sbin/scselect";
    task.arguments = @[loc];
    
    [task launch];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    notify_cancel(token);
}

@end
