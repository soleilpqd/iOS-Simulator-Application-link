//
//  SIMDevice.m
//  iSimApp
//
//  Created by Phạm Quang Dương on 11/7/14.
//  Copyright (c) 2014 GMO RunSystem. All rights reserved.
//

#import "SIMDevice.h"

@implementation SIMDevice

+( NSMutableArray* )allDevices {
    NSMutableArray *result = nil;
    NSFileManager *fileMan = [ NSFileManager defaultManager ];
    NSString *simRootPath = [ NSHomeDirectory() stringByAppendingPathComponent:@"Library/Developer/CoreSimulator/Devices" ];
    if ([ fileMan fileExistsAtPath:simRootPath ]) {
        NSArray *subDir = [ fileMan contentsOfDirectoryAtPath:simRootPath error:NULL ];
        if ( subDir && subDir.count ) {
            result = [ NSMutableArray array ];
            for ( NSString *path in subDir ) {
                SIMDevice *device = [ self SIMDeviceWithPath:[ simRootPath stringByAppendingPathComponent:path ]];
                if ( device )[ result addObject:device ];
            }
        }
    }
    if ( result.count == 0 ) return nil;
    [ result sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[( SIMDevice* )obj1 name ] compare:[( SIMDevice* )obj2 name ]];
    }];
    return result;
}

+( instancetype )SIMDeviceWithPath:(NSString *)path {
    NSString *dicPath = [ path stringByAppendingPathComponent:@"device.plist" ];
    NSFileManager *fileMan = [ NSFileManager defaultManager ];
    NSDictionary *deviceDic = nil;
    if ([ fileMan fileExistsAtPath:dicPath ])
        deviceDic = [ NSDictionary dictionaryWithContentsOfFile:dicPath ];
    if ( deviceDic ) {
        SIMDevice *device = [[ SIMDevice alloc ] init ];
        device.path = path;
        NSString *runtime = [[ deviceDic objectForKey:@"runtime" ] pathExtension ];
        device.name = [ NSString stringWithFormat:@"%@ - %@", [ deviceDic objectForKey:@"name" ],
                       [[ runtime stringByReplacingOccurrencesOfString:@"iOS-"
                                                            withString:@"iOS " ] stringByReplacingOccurrencesOfString:@"-"
                        withString:@"." ]];
        return device;
    }
    return nil;
}

-( NSString* )description {
    if ( self.applications )
        return [ NSString stringWithFormat:@"SIM: %@ (%ld)", self.name, self.applications.count ];
    return [ NSString stringWithFormat:@"SIM: %@", self.name ];
}

@end
