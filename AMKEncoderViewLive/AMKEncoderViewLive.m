//
//  AMKEncoderViewLive.m
//  AMKEncoderViewLive
//
//  Created by Bruno Garelli on 9/9/16.
//  Copyright © 2016 Bruno Garelli. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import "AMKEncoderViewLive.h"
#import <AppKit/AppKitDefines.h>

static AMKEncoderViewLive *sharedPlugin;
static const NSString *OUTLET_CONNECTION_MADE = @"IBDocumentDidAddConnectionNotification";
static const NSString *DOCUMENT_CONNECTION_KEY = @"IBDocumentConnectionKey";
@interface AMKEncoderViewLive ()
- (NSDictionary *)parseLabel:(id)abstractLabel;
//@property (nonatomic, strong) NSMutableSet *notificationSet;
@property (nonatomic, strong) NSMutableArray *notificationSet;
@property (nonatomic, strong) NSMutableDictionary *parsedLabel;
@property (nonatomic, strong) NSMutableDictionary *parsedButton;
@property (nonatomic, strong) NSString *storePath;
@property (nonatomic, strong) NSString *storeText;
@end

@implementation AMKEncoderViewLive

- (NSDictionary *)parseLabel:(id)abstractLabel {
    NSMutableDictionary *parsedData = [[NSMutableDictionary alloc] init];
    if ([abstractLabel respondsToSelector:NSSelectorFromString(@"text")]) {
        NSString *text = [abstractLabel valueForKey:@"text"];
        parsedData[@"text"] = text;
        id fontDescription = [abstractLabel valueForKey:@"fontDescription"];
        NSString *fontName = [fontDescription valueForKey:@"description"];
        parsedData[@"fontName"] = fontName;
        id marshalled = [fontDescription valueForKey:@"marshalledValue"];
        if (marshalled != nil) {
            parsedData[@"pointSize"] = [[marshalled valueForKey:@"pointSize"] stringValue];
            parsedData[@"type"] = [[marshalled valueForKey:@"type"] stringValue];
            parsedData[@"weightCategory"] = [[marshalled valueForKey:@"weightCategory"] stringValue];
        } else {
            NSLog(@"NOT MARSHALL");
        }
        NSColor *textColor = [abstractLabel valueForKey:@"textColor"];
        parsedData[@"textColor"] = [textColor description];
        /*NSInteger numberOfColors = [[textColor colorSpace] numberOfColorComponents];
         if (numberOfColors == 3) {
         
         }*/
    }
    return parsedData;
}

- (NSDictionary *)parseButton:(id)abstractButton {
    NSMutableDictionary *parsedData = [[NSMutableDictionary alloc] init];
    /*if ([abstractLabel respondsToSelector:NSSelectorFromString(@"text")]) {
        NSString *text = [abstractLabel valueForKey:@"text"];
        parsedData[@"text"] = text;
        id fontDescription = [abstractLabel valueForKey:@"fontDescription"];
        NSString *fontName = [fontDescription valueForKey:@"description"];
        parsedData[@"fontName"] = fontName;
        id marshalled = [fontDescription valueForKey:@"marshalledValue"];
        if (marshalled != nil) {
            parsedData[@"pointSize"] = [[marshalled valueForKey:@"pointSize"] stringValue];
            parsedData[@"type"] = [[marshalled valueForKey:@"type"] stringValue];
            parsedData[@"weightCategory"] = [[marshalled valueForKey:@"weightCategory"] stringValue];
        } else {
            NSLog(@"NOT MARSHALL");
        }
        NSColor *textColor = [abstractLabel valueForKey:@"textColor"];
        parsedData[@"textColor"] = [textColor description];
        
    }*/
    return parsedData;
}

#pragma mark - Initialization

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    NSArray *allowedLoaders = [plugin objectForInfoDictionaryKey:@"me.delisa.XcodePluginBase.AllowedLoaders"];
    if ([allowedLoaders containsObject:[[NSBundle mainBundle] bundleIdentifier]]) {
        sharedPlugin = [[self alloc] initWithBundle:plugin];
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)bundle
{
    if (self = [super init]) {
        self.notificationSet = [NSMutableSet new];
        self.parsedLabel = [NSMutableDictionary new];
        self.storePath = @"";
        self.storeText = @"";
        // reference to plugin's bundle, for resource access
        _bundle = bundle;
        // NSApp may be nil if the plugin is loaded from the xcodebuild command line tool
        if (NSApp && !NSApp.mainMenu) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationDidFinishLaunching:)
                                                         name:NSApplicationDidFinishLaunchingNotification
                                                       object:nil];
        } else {
            [self initializeAndLog];
        }
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:nil object:nil];
    [self initializeAndLog];
}

- (void)initializeAndLog
{
    NSString *name = [self.bundle objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *version = [self.bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *status = [self initialize] ? @"loaded successfully" : @"failed to load";
    NSLog(@"🔌 Plugin %@ %@ %@", name, version, status);
}

#pragma mark - Implementation

- (BOOL)initialize
{
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Save Changes"
                                                                action:@selector(doMenuAction) keyEquivalent:@""];
        /*NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Do Action" action:@selector(doMenuAction) keyEquivalent:@""];*/
        //[actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
        return YES;
    } else {
        return NO;
    }
}

// Sample Action, for menu item:
- (void)doMenuAction
{
    [self store];
}

- (void)store {
    if ([_storePath length] > 0 && [_parsedLabel count] > 0 && [_storeText length] > 0) {
        NSString *root = @"/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Library/Xcode/Overlays";
        NSString *root2 = _storePath;
        Boolean slashAtEOL = [root2 hasSuffix:@"/"];
        if (!slashAtEOL) {
            root2 = [root2 stringByAppendingString:@"/"];
        }
        root2 = [[root2 stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
        NSFileManager *fMan = [[NSFileManager alloc] init];
        NSArray *subDir = [fMan subpathsOfDirectoryAtPath:root2 error:nil];
        NSString *filtSubDir = @"";
        for (NSString *path in subDir) {
            if ([path containsString:@"/amk"]) {
                NSUInteger pathLength = [path length];
                if (pathLength > 4) {
                    NSString *subPath = [path substringFromIndex:pathLength - 4];
                    if ([subPath isEqual: @"/amk"]) {
                        filtSubDir = path;
                        break;
                    }
                }
            }
        }
        NSString *projFolderFilePath = [[root2 stringByAppendingPathComponent:/*@"amk"*/filtSubDir] stringByAppendingPathComponent:[_storeText stringByAppendingString:@".plist"]];
        
        if ([fMan fileExistsAtPath:projFolderFilePath]) {
            [fMan removeItemAtPath:projFolderFilePath error:nil];
        }
        
        NSString *finalPath2 = projFolderFilePath;
        NSString *finalPath = [[[root stringByAppendingPathComponent:@"amk"] stringByAppendingPathComponent: _storeText] stringByAppendingString:@".plist"];
        
        _Bool canSave = [fMan isWritableFileAtPath:finalPath];
        
        _Bool success = [fMan createFileAtPath:finalPath contents:nil attributes:nil];
        [_parsedLabel writeToFile:finalPath atomically:true];
         
        success = [fMan createFileAtPath:finalPath2 contents:nil attributes:nil];
        [_parsedLabel writeToFile:finalPath2 atomically:true];
    }
}

- (void)handleNotification:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    NSObject *obj = notification.object;
    if (([notification.name isEqual:@"NSControlTextDidEndEditingNotification"]) ) {
        id delegate = [obj valueForKey:@"delegate"];
        if ([[delegate description] containsString:@"IDETextFieldActionFilter"]) {
            id target = [delegate valueForKey:@"target"];
            NSString *keyPath = [[target valueForKey:@"valueKeyPath"] valueForKey:@"observationKeyPath"];
            if ([keyPath containsString:@"storeID"]) {
                id textField = [target valueForKey:@"textField"];
                NSString *text = [textField valueForKey:@"stringValue"];
                if ([_storePath length] > 0 && [_parsedLabel count] > 0 && [text length] > 0) {
                    _storeText = text;
                }
            } else if ([keyPath containsString:@"storeButtonID"]) {
                id textField = [target valueForKey:@"textField"];
                NSString *text = [textField valueForKey:@"stringValue"];
                _storePath = text;
                //_parsedButton = [[NSMutableDictionary alloc] initWithDictionary:[self parseButton: [connection valueForKey:@"destination"]]];
            }
        }
    }
    
    /*if (![notLog containsObject: notification.name]) {
        NSLog(name);
    }*/
    if ([notification.name containsString:@"NSControlTextDidEndEditingNotification"]) {
        NSObject *obj = notification.object;
        NSLog(@"%@", obj);
    }
    NSArray *blackList = @[@"NSApplicationDidUpdateNotification", @"NSApplicationWillUpdateNotification", @"NSWindowDidUpdateNotification"];
    Boolean contains = false;
    for (NSString *listed in blackList) {
        if ([listed isEqual:notification.name]) {
            contains = true;
        }
    }
    if (!contains) {
        //NSLog(@"%@", notification.name);
    }
    if ([notification.name  isEqual: OUTLET_CONNECTION_MADE]) {
        NSConnection *connection = (NSConnection *)info[DOCUMENT_CONNECTION_KEY];
        //NSString *connectionDetails = [connection description];
        //NSArray *components = [connectionDetails componentsSeparatedByString:@"=<"];
        
        //const NSString *view = components[1];
        //NSUInteger low_range = [view rangeOfString:@"'"].location;
        //NSUInteger high_range = [view rangeOfString:@">"].location;
        //NSRange range = NSMakeRange(low_range + 1, high_range - low_range - 1);
        //NSString *sourceName = [view substringWithRange:range];
        NSArray<NSDocument *> *docs = [NSApp orderedDocuments];
        if ([docs count] > 0) {
            NSMutableArray<NSDocument *> *filtered = [[NSMutableArray alloc] init];
            for (NSDocument *doc in docs) {
                if ([[doc description] containsString: @"IBStoryboardDocument"]) {
                    [filtered addObject:doc];
                }
            }
            if ([filtered count] > 0) {
                _storePath = [(NSURL *)[[docs objectAtIndex:0] fileURL] path];
                _parsedLabel = [[NSMutableDictionary alloc] initWithDictionary:[self parseLabel: [connection valueForKey:@"destination"]]];
            }
        }
    }
    if (![self.notificationSet containsObject:notification.name]) {
        NSLog(@"%@, %@", notification.name, [notification.object class]);
        [self.notificationSet addObject:notification.name];
    }
    //[self.notificationSet addObject:notification.name];
}

- (void)commitEditingWithDelegate:(id)delegate didCommitSelector:(SEL)didCommitSelector contextInfo:(void *)contextInfo {
    NSLog(@"commitEditingWithDelegate");
}

@end
