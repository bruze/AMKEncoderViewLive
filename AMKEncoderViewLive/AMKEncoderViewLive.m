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
@property (nonatomic, strong) NSMutableSet *notificationSet;
@end

@implementation AMKEncoderViewLive

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:nil object:nil];
        
        self.notificationSet = [NSMutableSet new];
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
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Reset Logger"
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
    NSString *path = @"/Users/bgarelli/Library/Developer/CoreSimulator/Devices/AAF9BE99-DC9E-4822-8C6B-F6E31DCBE133/data/Containers/Data/Application/DDB0390B-F977-45DD-A92A-B287ED2ED340/Documents/plugingIn.txt";
    [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    NSString *str = @"PLUGPLUGPLUG";
    [str writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];

    [self.notificationSet removeAllObjects];
    /*NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Hello, World"];
    [alert runModal];*/
}
//name	__NSCFConstantString *	@"NSControlTextDidEndEditingNotification"	0x00007fff7870b2b0
//((IDEInspectorBasicStringProperty *)((IDETextFieldActionFilter *)((NSTextField *)notification.object).delegate).target)
- (void)handleNotification:(NSNotification *)notification {
    NSString *name = notification.name;
    NSArray *notLog = [NSArray arrayWithObjects: @"NSApplicationDidUpdateNotification", @"NSWindowDidUpdateNotification",
                                                 @"NSApplicationWillUpdateNotification", @"NSMouseMovedNotification",
                                                @"NSTextViewDidChangeTypingAttributesNotification",
                       @"NSBundleDidLoadNotification", @"NSUserDefaultsDidChangeNotification", @"_NSThreadDidStartNotification", @"_NSPersistentStoreCoordinatorStoresDidChangePrivateNotification",
                       @"IDEIndexIsIndexingWorkspaceNotification", @"IDEIndexingPrebuildControllerBuildDidStopNotification", @"CurrentExecutionTrackerCompletedNotification", @"IDEBuildOperationDidGenerateOutputFilesNotification", @"XCBuildContextDidCreateDependencyGraphNotification",
                       @"_NSThreadDidStartNotification", @"NSFileHandleDataAvailableNotification", @"NSTextStorageWillProcessEditingNotification",
                       @"NSMenuDidAddItemNotification",
                       @"NSMenuDidChangeItemNotification",
                       @"NSViewFrameDidChangeNotification",
                       @"NSThreadWillExitNotification", @"NSApplicationDidResignActiveNotification", @"NSWindowDidResignKeyNotification", @"NSApplicationWillResignActiveNotification", @"NSMenuDidRemoveItemNotification" ,@"NSMenuDidRemoveAllItemsNotification",@"NSViewDidUpdateTrackingAreasNotification", @"XCBuildContextDidFinishSettingTargetSnapshotNotification", @"IDEBuildOperationDidStopNotification",@"PBXTargetProductReferenceDidChangeNotification",@"IDEIndexDidChangeStateNotification",
                       
                       @"ExecutionEnvironmentLastBuildCompletedNotification",
                       @"XCBuildContextDidFinishSettingTargetSnapshotNotification",
                       @"IDESourceControlIDEDidUpdateLocalStatusNotification",
                       @"IDEWorkspaceDocumentWillWriteStateDataNotification",
                       @"IDESourceControlIDEWillUpdateLocalStatusNotification",
                       @"NSThreadWillExitNotification",
                                                 nil
                       ];
    if (![notLog containsObject: notification.name]) {
        //NSLog(name);
    }
    //IBDocumentDidFinishEditingNotification //NSControlTextDidChangeNotification //DVTGlobalFindStringDidChangeNotification //IDENavigableItemCoordinatorPropertyValuesChangeNotification
    
    /*IBDocumentDidFinishEditingNotification
    NSUndoManagerDidCloseUndoGroupNotification
    DVTUndoManagerDidAddTopLevelChangeGroupNotification
    IBDocumentIssuesDidChange
    IDEEditorDocumentIsEditedStatusDidChangeNotification
    IDEEditorDocumentHasEditsSinceLastUserInitiatedSaveStatusChangedNotification
    NSKeyUpNotification
    DVTModelObjectGraphWillCoalesceChangesNotification
    DVTModelObjectGraphObjectsDidChangeNotificationName
     DVTModelObjectGraphDidCoalesceChangesNotification
     IDENavigableItemCoordinatorPropertyValuesChangeNotification*/
    NSDictionary *info = notification.userInfo;
    NSObject *obj = notification.object;
    if ([notification.name isEqual:@"DVTUndoManagerDidAddTopLevelChangeGroupNotification"]) {
        id doc = [obj valueForKey:@"document"];
        id entry = [[doc valueForKey:@"globalEntryPointKeyPathsToIndicators"] valueForKey:@"designatedEntryPoint"];
        id indicated = [entry valueForKey:@"indicatedEntryPoint"];
        NSLog(@"%@, @%, %@", name, info, obj);
    }
    /*if ([notification.name isEqual:@"IDENavigableItemCoordinatorPropertyValuesChangeNotification"]) {
        id meKnow = nil;
    }*/
    //if (![self.notificationSet containsObject:notification.name]) {
        if ([notification.name  isEqual: OUTLET_CONNECTION_MADE]) {
            /*IDEInspectorBasicStringProperty *propInspect = ((IDEInspectorBasicStringProperty *)((IDETextFieldActionFilter *)((NSTextField *)notification.object).delegate).target);*/
            NSConnection *connection = (NSConnection *)info[DOCUMENT_CONNECTION_KEY];
            NSString *connectionDetails = [connection description];
            NSArray *components = [connectionDetails componentsSeparatedByString:@"=<"];
            /*
             IBUIView: 0x1197e3f20 (xbe-ue-P26) 'Super View'>  property=label  destination*/
            const NSString *view = components[1];
            NSUInteger low_range = [view rangeOfString:@"'"].location;
            NSUInteger high_range = [view rangeOfString:@">"].location;
            NSRange range = NSMakeRange(low_range + 1, high_range - low_range - 1);
            NSString *sourceName = [view substringWithRange:range];
            NSString *path = [(NSURL *)[[[NSApp orderedDocuments] objectAtIndex:1] fileURL] path];
            
            [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
            NSString *str = @"PLUGPLUGPLUG";
            //[str writeToFile:[path stringByAppendingString:sourceName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            //NSLog(@"%@, @%, %@", name, info, obj);
        }
    
        //NSLog(@"%@, %@", notification.name, [notification.object class]/*notification.object*/);
        //[self.notificationSet addObject:notification.name];
    //}
}

- (void)commitEditingWithDelegate:(id)delegate didCommitSelector:(SEL)didCommitSelector contextInfo:(void *)contextInfo {
    NSLog(@"commitEditingWithDelegate");
}

@end
