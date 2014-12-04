//
//  SIMApp.h
//  iSimApp
//
//  Created by Phạm Quang Dương on 11/7/14.
//  Copyright (c) 2014 GMO RunSystem. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SIMApp : NSObject

@property ( nonatomic, strong ) NSString *name;
@property ( nonatomic, strong ) NSString *identifier;
@property ( nonatomic, strong ) NSString *bundleName;
@property ( nonatomic, strong ) NSString *path;
@property ( nonatomic, strong ) NSString *documentPath;

+( NSMutableArray* )allAppInFolder:( NSString* )path;
+( NSMutableArray* )allApp6InFolder:( NSString* )path;

@end
