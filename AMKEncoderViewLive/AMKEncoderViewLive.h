//
//  AMKEncoderViewLive.h
//  AMKEncoderViewLive
//
//  Created by Bruno Garelli on 9/9/16.
//  Copyright © 2016 Bruno Garelli. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface AMKEncoderViewLive : NSObject

+ (instancetype)sharedPlugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end