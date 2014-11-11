//
//  main.m
//  iSimApp
//
//  Created by Phạm Quang Dương on 11/7/14.
//  Copyright (c) 2014 GMO RunSystem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIMDevice.h"
#import "SIMApp.h"

NSMutableArray *_allSims = nil;

void printHelp( const char *prog ) {
    printf( "Mapping XCode 6.1 Simulator Applications\n" );
    printf( "Usage:\n" );
    printf( "\t%s\t\t\t\t: Show help\n", prog );
    printf( "\t%s --list-sim\t\t: list all available simulator\n", prog );
    printf( "\t%s --list-app\t\t: list all applications with their simulator\n", prog );
    printf( "\t%s --list-app <simulator>\t: list application of specified simulator\n", prog );
    printf( "\t%s --map <target folder>\t: Do mapping\n", prog );
}

bool loadSimulators() {
    _allSims = [ SIMDevice allDevices ];
    if ( _allSims == nil ) {
        fprintf( stderr, "Could not find XCode 6 simulator directories!\n" );
        return false;
    }
    return true;
}

bool loadApps() {
    if ( _allSims == nil ) return false;
    for ( SIMDevice *device in _allSims ) {
        device.applications = [ SIMApp allAppInFolder:[ device.path stringByAppendingPathComponent:@"data/Applications" ]];
    }
    return true;
}

int listSimulators() {
    if ( loadSimulators() ) {
        for ( SIMDevice *sim in _allSims ) {
            printf( "%s\n", [ sim.name UTF8String ]);
        }
        return 0;
    }
    return 1;
}

void printSimApp( SIMDevice* sim ){
    printf( "%s: %ld\n", [ sim.name UTF8String ], sim.applications ? sim.applications.count : 0 );
    for ( SIMApp *app in sim.applications ) {
        printf( "\t%s (%s)\n", [ app.name UTF8String ], [ app.identifier UTF8String ]);
    }
}

int listApp( const char *simName ) {
    if ( loadSimulators() ) {
        loadApps();
        BOOL found = NO;
        for ( SIMDevice *sim in _allSims ) {
            if ( simName ) {
                const char *s = [ sim.name UTF8String ];
                if ( strcmp( simName, s ) == 0 ) {
                    printSimApp( sim );
                    found = YES;
                    break;
                }
            } else {
                found = YES;
                if ( sim.applications && sim.applications.count )
                    printSimApp( sim );
            }
        }
        if ( !found ) {
            fprintf( stderr, "Simulator \"%s\" not found!\n", simName );
            return 1;
        }
        return 0;
    }
    return 1;
}

void cleanApps( NSString *simMap, NSMutableArray *unusedApps ) {
    NSFileManager *fileMan = [ NSFileManager defaultManager ];
    if ( unusedApps && unusedApps.count ) {
        for ( NSString *appName in unusedApps ) {
            [ fileMan removeItemAtPath:[ simMap stringByAppendingPathComponent:appName ]
                                 error:NULL ];
        }
    }
}

int mapping( const char *path ) {
    if ( loadSimulators() ) {
        loadApps();
        NSFileManager *fileMan = [ NSFileManager defaultManager ];
        NSString *targetPath = nil;
        if ( path ) {
            targetPath = [ fileMan stringWithFileSystemRepresentation:path length:strlen( path )];
            if (![ fileMan fileExistsAtPath:targetPath ]) {
                fprintf( stderr, "Target path not found: %s\n", path );
                return 1;
            }
        } else {
            targetPath = [ fileMan currentDirectoryPath ];
        }
        // Load created simulator map folder
        NSString *simInfoFile = [ targetPath stringByAppendingPathComponent:@".simulators.plist" ];
        NSMutableArray *createdSim = [ NSMutableArray arrayWithContentsOfFile:simInfoFile ];
        NSMutableArray *currentSim = [ NSMutableArray array ];
        for ( SIMDevice *sim in _allSims ) {
            if ( sim.applications == nil || sim.applications.count == 0 )
                continue;
            // Create simulator map directory
            NSString *simMap = [ targetPath stringByAppendingPathComponent:sim.name ];
            NSError *error = nil;
            if (![ fileMan fileExistsAtPath:simMap ]) {
                if (![ fileMan createDirectoryAtPath:simMap
                         withIntermediateDirectories:YES
                                          attributes:nil
                                               error:&error ]) {
                    fprintf( stderr, "Failed to create directory at \"%s\": %s\n", [ simMap UTF8String ], [ error.localizedDescription UTF8String ]);
                    return 1;
                }
            }
            if ( createdSim && [ createdSim containsObject:sim.name ])
                [ createdSim removeObject:sim.name ];
            [ currentSim addObject:sim.name ];
            // App for current simulator
            NSString *appInfoFile = [ simMap stringByAppendingPathComponent:@".apps.plist" ];
            NSMutableArray *createdApps = [ NSMutableArray arrayWithContentsOfFile:appInfoFile ];
            NSMutableArray *currentApps = [ NSMutableArray array ];
            NSMutableDictionary *appNameCount = [ NSMutableDictionary dictionary ];
            for ( SIMApp *app in sim.applications ) {
                NSNumber *num = [ appNameCount objectForKey:app.name ];
                if ( num == nil )
                    num = [ NSNumber numberWithUnsignedInteger:1 ];
                else
                    num = [ NSNumber numberWithUnsignedInteger:[ num unsignedIntegerValue ] + 1 ];
                [ appNameCount setObject:num forKey:app.name ];
            }
            for ( SIMApp *app in sim.applications ) {
                NSUInteger appCnt = [[ appNameCount objectForKey:app.name ] unsignedIntegerValue ];
                NSString *appName = appCnt == 1 ? app.name : [ app.name stringByAppendingFormat:@" (%@)", app.identifier ];
                NSString *appMap = [ simMap stringByAppendingPathComponent:appName ];
                if (![ fileMan fileExistsAtPath:appMap ]) {
                    if (![ fileMan createSymbolicLinkAtPath:appMap
                                        withDestinationPath:app.path
                                                      error:&error ]) {
                        fprintf( stderr, "Failed to create link at \"%s\": %s\n", [ appMap UTF8String ], [ error.localizedDescription UTF8String ]);
                        return 1;
                    }
                }
                if ( createdApps && [ createdApps containsObject:appName ])
                    [ createdApps removeObject:appName ];
                [ currentApps addObject:appName ];
            }
            // Remove unused app map point
            cleanApps( simMap, createdApps );
            [ currentApps writeToFile:appInfoFile atomically:YES ];
        }
        [ currentSim writeToFile:simInfoFile atomically:YES ];
        // Remove unused simulator map point
        if ( createdSim && createdSim.count ) {
            for ( NSString *simName in createdSim ) {
                NSString *simMap = [ targetPath stringByAppendingPathComponent:simName ];
                NSMutableArray *createdApps = [ NSMutableArray arrayWithContentsOfFile:[ simMap stringByAppendingPathComponent:@".apps.plist" ]];
                cleanApps( simMap, createdApps );
                [ fileMan removeItemAtPath:simMap error:NULL ];
            }
        }
        return 0;
    }
    return 1;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if ( argc == 1 ) {
            printHelp( "iSimApp" );
        } else {
            if ( strcmp( argv[1], "--list-sim" ) == 0 ) {
                return listSimulators();
            } else if ( strcmp( argv[1], "--list-app" ) == 0 ) {
                if ( argc > 2 )
                    return listApp( argv[2] );
                else
                    return listApp( NULL );
            } else if ( strcmp( argv[1], "--map" ) == 0 ) {
                if ( argc > 2 )
                    return mapping( argv[2] );
                else
                    return mapping( NULL );
            } else {
                printHelp( "iSimApp" );
            }
        }
    }
    return 0;
}
