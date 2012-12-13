//
//  DKAppDelegate.h
//  NetworkCheckUtility
//
//  Created by Devarshi Kulshreshtha on 12/12/12.
//  Copyright (c) 2012 DaemonConstruction. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DKAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (readwrite, strong) NSString *statusString;
@property (readwrite, strong) NSString *selectedMethod;
@property (readwrite, strong) NSMutableAttributedString *referencedLink;
@end
