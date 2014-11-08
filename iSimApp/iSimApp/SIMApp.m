//
//  SIMApp.m
//  iSimApp
//
//  Created by Phạm Quang Dương on 11/7/14.
//  Copyright (c) 2014 GMO RunSystem. All rights reserved.
//

#import "SIMApp.h"

@implementation SIMApp

+( instancetype )SIMAppWithPath:(NSString *)path {
    NSFileManager *fileMan = [ NSFileManager defaultManager ];
    NSString *appBundle = nil;
    NSArray *subItems = [ fileMan contentsOfDirectoryAtPath:path error:NULL ];
    for ( NSString *item in subItems ) {
        if ([ item.pathExtension isEqualToString:@"app" ]) {
            appBundle = item;
            break;
        }
    }
    if ( appBundle ) {
        SIMApp *app = [[ SIMApp alloc ] init ];
        app.path = path;
        
        NSString *dicPath = [ path stringByAppendingPathComponent:[ NSString stringWithFormat:@"%@/Info.plist", appBundle ]];
        NSDictionary *appInfo = nil;
        if ([ fileMan fileExistsAtPath:dicPath ])
            appInfo = [ NSDictionary dictionaryWithContentsOfFile:dicPath ];
        if ( appInfo ) {
            app.name = [ appInfo objectForKey:@"CFBundleDisplayName" ];
            if ( app.name == nil || app.name.length == 0 )
                app.name = [ appInfo objectForKey:@"CFBundleName" ];
            if ( app.name == nil || app.name.length == 0 )
                app.name = [ appInfo objectForKey:@"CFBundleIdentifier" ];
            app.identifier = [ appInfo objectForKey:@"CFBundleIdentifier" ];
        }
        if ( app.name == nil || app.name.length == 0 ) app.name = appBundle;
        return app;
    }
    return nil;
}

+( NSMutableArray* )allAppInFolder:(NSString *)path {
    NSMutableArray *result = nil;
    NSFileManager *fileMan = [ NSFileManager defaultManager ];
    if ([ fileMan fileExistsAtPath:path ]) {
        NSArray *subDir = [ fileMan contentsOfDirectoryAtPath:path error:NULL ];
        if ( subDir && subDir.count ) {
            result = [ NSMutableArray array ];
            for ( NSString *p in subDir ) {
                SIMApp *app = [ self SIMAppWithPath:[ path stringByAppendingPathComponent:p ]];
                if ( app )[ result addObject:app ];
            }
        }
    }
    if ( result.count == 0 ) return nil;
    [ result sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[( SIMApp* )obj1 name ] compare:[( SIMApp* )obj2 name ]];
    }];
    return result;
}

-( NSString* )description {
    return [ NSString stringWithFormat:@"APP: %@", self.name ];
}

@end
