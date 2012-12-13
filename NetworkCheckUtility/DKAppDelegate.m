//
//  DKAppDelegate.m
//  NetworkCheckUtility
//
//  Created by Devarshi Kulshreshtha on 12/12/12.
//  Copyright (c) 2012 DaemonConstruction. All rights reserved.
//

#import "DKAppDelegate.h"
#import "Reachability.h"

@interface DKAppDelegate ()
@property (strong, readwrite) NSString *hostName;
@property (weak) IBOutlet NSPopUpButton *actionPopupButton;
@property (strong, readwrite) NSArray *referencedLinks;
@property (readwrite, strong) Reachability *hostReach;
@property (weak) IBOutlet NSTextField *referenceTextField;
@end

@implementation DKAppDelegate
@synthesize actionPopupButton;

#pragma mark constants

NSString *const kOnlineStatusMessage = @"Online";
NSString *const kOfflineStatusMessage = @"Offline";

typedef NS_ENUM(NSInteger, CommandTypeOptions)
{
    CommandTypeCurl,
    CommandTypeCFNetDiagnostics,
    CommandTypeReachability,
    CommandTypeNSURLConnection
};

#pragma mark -

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    // initializing host name
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"hostName"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"http://www.apple.com" forKey:@"hostName"];
    }
    self.hostName = [[NSUserDefaults standardUserDefaults] objectForKey:@"hostName"];
    
    // adding observers
    [self addObserver:self forKeyPath:@"selectedMethod" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
    
    // initializing referencedLinks
    self.referencedLinks = @[ @"http://cocoadev.com/wiki/NSTaskWaitUntilExit", @"http://theocacao.com/document.page/206", @"http://developer.apple.com/library/ios/#samplecode/Reachability/Introduction/Intro.html", @"http://stackoverflow.com/questions/7627058/how-to-determine-internet-connection-in-cocoa" ];
    
    // reference link display related initialization
    [self.referenceTextField setAllowsEditingTextAttributes:YES];
    [self.referenceTextField setSelectable:YES];
}
- (IBAction)goAction:(id)sender {
    switch ([self.actionPopupButton indexOfSelectedItem]) {
        case CommandTypeCurl:
            [self identifyStatusUsingCurl];
            break;
        case CommandTypeCFNetDiagnostics:
            [self identifyStatusUsingCFNetDiagnostics];
            break;
        case CommandTypeReachability:
            [self identifyStatusUsingReachability];
            break;
        case CommandTypeNSURLConnection:
            [self identifyStatusUsingNSURLConnection];
            break;
        default:
            break;
    }
}

//reference: http://cocoadev.com/wiki/NSTaskWaitUntilExit
- (void)identifyStatusUsingCurl
{
    NSTask *curlTask = [[NSTask alloc] init];
    NSPipe *curlPipe = [[NSPipe alloc] init];
    NSFileHandle *outputHandle = [curlPipe fileHandleForReading];
    //FIXME: use of readInBackgroundAndNotify
    [curlTask setLaunchPath:@"/usr/bin/curl"];
    [curlTask setArguments:@[ self.hostName ]];
    [curlTask setStandardOutput:curlPipe];
    [curlTask launch];
    NSData *outputData = [outputHandle availableData];
    [outputHandle closeFile];
    [curlTask waitUntilExit];
    
    [self updateMsgAccordingToStatus:([outputData length] != 0)];
}

//reference: http://theocacao.com/document.page/206
- (void)identifyStatusUsingCFNetDiagnostics
{
    CFNetDiagnosticRef diagnostic;
    diagnostic = CFNetDiagnosticCreateWithURL(NULL, (__bridge CFURLRef)[NSURL URLWithString:self.hostName]);
    
    CFNetDiagnosticStatus status;
    status = CFNetDiagnosticCopyNetworkStatusPassively(diagnostic, NULL);
    
    CFRelease(diagnostic);
    
    [self updateMsgAccordingToStatus:(status == kCFNetDiagnosticConnectionUp)];
}

//reference: http://developer.apple.com/library/ios/#samplecode/Reachability/Introduction/Intro.html
- (void)identifyStatusUsingReachability
{
    self.hostReach = [Reachability reachabilityWithHostName:[[NSURL URLWithString:self.hostName] host]];
    [self updateMsgAccordingToStatus:([self.hostReach currentReachabilityStatus] != NotReachable)];
}

//reference: http://stackoverflow.com/questions/7627058/how-to-determine-internet-connection-in-cocoa answer by Korio
- (void)identifyStatusUsingNSURLConnection
{
    NSURL *url = [[NSURL alloc] initWithString:self.hostName];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5.0];
    [self updateMsgAccordingToStatus:([NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil] != nil)];
}

// method to update status msg
- (void)updateMsgAccordingToStatus:(BOOL)status
{
    if (status) {
        // yes or net connected
        self.statusString = kOnlineStatusMessage;
    }
    else
    {
        // no or net not connected
        self.statusString = kOfflineStatusMessage;
    }
}

#pragma mark KVO related method
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"selectedMethod"]) {
        
        // updating referenceLink
        [self updateReferencedLinkFromLink:[self.referencedLinks objectAtIndex:[self.actionPopupButton indexOfSelectedItem]]];
        
        if (![change objectForKey:NSKeyValueChangeOldKey]) {
            self.statusString = nil;
        }
        else if (![[change objectForKey:NSKeyValueChangeNewKey] isEqualToString:[change objectForKey:NSKeyValueChangeOldKey]]) {
            
            // if new and old selected methods are different
            // then clear status string
            self.statusString = nil;
        }
    }
}

#pragma mark embeding hyperlink in attributed string
//reference: http://developer.apple.com/library/mac/#qa/qa1487/_index.html
- (void)updateReferencedLinkFromLink:(NSString *)aLink
{
    if ([aLink isEqualToString:@""] || (aLink == nil)) {
        self.referencedLink = nil;
    }
    else
    {
        NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:aLink];
        NSRange range = NSMakeRange(0, [attrString length]);
        NSFont *helveticaFont = [NSFont fontWithName:@"Helvetica" size:12];
        
        [attrString beginEditing];
        [attrString addAttribute:NSFontAttributeName value:helveticaFont range:range];
        [attrString addAttribute:NSLinkAttributeName value:aLink range:range];
        [attrString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
        [attrString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:range];
        [attrString endEditing];
        
        self.referencedLink = attrString;
    }
    
}

#pragma mark App Delegate methods
- (void)applicationWillTerminate:(NSNotification *)notification
{
    [self removeObserver:self forKeyPath:@"selectedMethod"];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    [self.window makeKeyAndOrderFront:nil];
    return YES;
}
@end
