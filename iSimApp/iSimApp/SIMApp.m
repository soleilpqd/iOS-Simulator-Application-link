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
        app.bundleName = appBundle;
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
            NSDictionary *idInfo = [ NSDictionary dictionaryWithContentsOfFile:[ app.path stringByAppendingPathComponent:@".com.apple.mobile_container_manager.metadata.plist" ]];
            if ( idInfo )
                app.identifier = [ idInfo objectForKey:@"MCMMetadataIdentifier" ];
            if ( app.identifier == nil )
                app.identifier = [ appInfo objectForKey:@"CFBundleIdentifier" ];
        }
        if ( app.name == nil || app.name.length == 0 ) app.name = appBundle;
        return app;
    }
    return nil;
}

// path should be ~/Library/Developer/CoreSimulator/Devices/<udid>/data/Applications
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

// path should be ~/Library/Developer/CoreSimulator/Devices/<udid>/data/Containers
+( NSMutableArray* )allApp6InFolder:(NSString *)path {
    NSMutableArray *allApps = [ self allAppInFolder:[ path stringByAppendingPathComponent:@"Bundle/Application" ]];
    NSMutableArray *result = nil;
    if ( allApps && allApps.count ) {
        result = [ NSMutableArray array ];
        // Now load documents path
        NSFileManager *fileMan = [ NSFileManager defaultManager ];
        NSString *docRootPath = [ path stringByAppendingPathComponent:@"Data/Application" ];
        NSArray *subDirs = [ fileMan contentsOfDirectoryAtPath:docRootPath error:nil ];
        if ( subDirs && subDirs.count ) {
            for ( NSString *sDir in subDirs ) {
                NSString *sDirPath = [ docRootPath stringByAppendingPathComponent:sDir ];
                NSDictionary *info = [ NSDictionary dictionaryWithContentsOfFile:[ sDirPath stringByAppendingPathComponent:@".com.apple.mobile_container_manager.metadata.plist" ]];
                if ( info ) {
                    NSString *bundleId = [ info objectForKey:@"MCMMetadataIdentifier" ];
                    if ( bundleId ) {
                        SIMApp *appBundle = nil;
                        for ( SIMApp *app in allApps ) {
                            if ([ app.identifier isEqualToString:bundleId ]) {
                                appBundle = app;
                                break;
                            }
                        }
                        if ( appBundle ) {
                            appBundle.documentPath = sDirPath;
                            [ result addObject:appBundle ];
                            [ allApps removeObject:appBundle ];
                        }
                    }
                }
            }
        }
        [ result addObjectsFromArray:allApps ];
    }
    return result;
}

-( NSString* )description {
    return [ NSString stringWithFormat:@"APP: %@ (%@)", self.name, self.identifier ];
}

@end
