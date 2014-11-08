//
//  SIMDevice.h
//  iSimApp
//
//  Created by Phạm Quang Dương on 11/7/14.
//  Copyright (c) 2014 GMO RunSystem. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SIMDevice : NSObject

@property ( nonatomic, strong ) NSString *name;
@property ( nonatomic, strong ) NSString *path;
@property ( nonatomic, strong ) NSMutableArray *applications;

+( instancetype )SIMDeviceWithPath:( NSString* )path;
+( NSMutableArray* )allDevices;

@end
