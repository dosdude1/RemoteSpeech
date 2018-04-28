//
//  main.m
//  relaunch
//
//  Created by Collin Mistr on 12/26/16.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NSString *appPath;

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        pid_t parentPID = atoi(argv[2]);
        ProcessSerialNumber psn;
        while (GetProcessForPID(parentPID, &psn) != procNotFound)
            sleep(1);
        
        appPath = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
        BOOL success = [[NSWorkspace sharedWorkspace] openFile:[appPath stringByExpandingTildeInPath]];
        
        return (success) ? 0 : 1;
        
    }
    return 0;
}

