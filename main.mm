#import <Cocoa/Cocoa.h>
#import "ClockWindow.h"
#import "SettingsWindow.h"
#import "ClockSettings.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (strong) ClockWindow *clockWindow;
@property (strong) SettingsWindow *settingsWindow;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    // Get diameter from settings
    ClockSettings *settings = [ClockSettings sharedSettings];
    CGFloat diameter = [settings windowDiameter];
    
    // Create clock window with diameter from settings
    NSRect windowRect = NSMakeRect(100, 100, diameter, diameter);
    self.clockWindow = [[ClockWindow alloc] initWithContentRect:windowRect];
    
    // Show the clock window
    [self.clockWindow makeKeyAndOrderFront:nil];
    [self.clockWindow center];
    
    // Sync menu item states with settings
    NSMenu *viewMenu = [[[NSApp mainMenu] itemWithTitle:@"View"] submenu];
    NSMenuItem *clickThroughItem = [viewMenu itemWithTitle:@"Click Through"];
    if (clickThroughItem) {
        [clickThroughItem setState:[settings clickThrough] ? NSControlStateValueOn : NSControlStateValueOff];
    }
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    // Cleanup if needed
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (IBAction)showSettings:(id)sender {
    if (!self.settingsWindow) {
        self.settingsWindow = [[SettingsWindow alloc] init];
    }
    [self.settingsWindow makeKeyAndOrderFront:nil];
}

- (IBAction)quitApplication:(id)sender {
    [NSApp terminate:nil];
}

- (IBAction)toggleAlwaysOnTop:(id)sender {
    NSMenuItem *menuItem = (NSMenuItem *)sender;
    BOOL isOnTop = [menuItem state] == NSControlStateValueOff;
    
    if (isOnTop) {
        [self.clockWindow setLevel:NSFloatingWindowLevel];
        [menuItem setState:NSControlStateValueOn];
    } else {
        [self.clockWindow setLevel:NSNormalWindowLevel];
        [menuItem setState:NSControlStateValueOff];
    }
}

- (IBAction)toggleClickThrough:(id)sender {
    NSMenuItem *menuItem = (NSMenuItem *)sender;
    ClockSettings *settings = [ClockSettings sharedSettings];
    BOOL clickThrough = [menuItem state] == NSControlStateValueOff;
    
    [settings setClickThrough:clickThrough];
    
    if (clickThrough) {
        [menuItem setState:NSControlStateValueOn];
    } else {
        [menuItem setState:NSControlStateValueOff];
    }
}

@end

void setupMenuBar() {
    NSMenu *menuBar = [[NSMenu alloc] init];
    [NSApp setMainMenu:menuBar];
    
    // Application menu
    NSMenuItem *appMenuItem = [[NSMenuItem alloc] init];
    [menuBar addItem:appMenuItem];
    
    NSMenu *appMenu = [[NSMenu alloc] init];
    [appMenuItem setSubmenu:appMenu];
    
    NSString *appName = @"VibeClock";
    NSString *quitTitle = [@"Quit " stringByAppendingString:appName];
    
    NSMenuItem *quitMenuItem = [[NSMenuItem alloc] initWithTitle:quitTitle
                                                          action:@selector(quitApplication:)
                                                   keyEquivalent:@"q"];
    [quitMenuItem setTarget:[NSApp delegate]];
    [appMenu addItem:quitMenuItem];
    
    // View menu
    NSMenuItem *viewMenuItem = [[NSMenuItem alloc] init];
    [viewMenuItem setTitle:@"View"];
    [menuBar addItem:viewMenuItem];
    
    NSMenu *viewMenu = [[NSMenu alloc] init];
    [viewMenuItem setSubmenu:viewMenu];
    
    NSMenuItem *alwaysOnTopItem = [[NSMenuItem alloc] initWithTitle:@"Always on Top"
                                                               action:@selector(toggleAlwaysOnTop:)
                                                        keyEquivalent:@"t"];
    [alwaysOnTopItem setTarget:[NSApp delegate]];
    [alwaysOnTopItem setState:NSControlStateValueOff];
    [viewMenu addItem:alwaysOnTopItem];
    
    NSMenuItem *clickThroughItem = [[NSMenuItem alloc] initWithTitle:@"Click Through"
                                                               action:@selector(toggleClickThrough:)
                                                        keyEquivalent:@"c"];
    [clickThroughItem setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagShift];
    [clickThroughItem setTarget:[NSApp delegate]];
    [clickThroughItem setState:NSControlStateValueOff];
    [viewMenu addItem:clickThroughItem];
    
    // Settings menu
    NSMenuItem *settingsMenuItem = [[NSMenuItem alloc] init];
    [settingsMenuItem setTitle:@"Settings"];
    [menuBar addItem:settingsMenuItem];
    
    NSMenu *settingsMenu = [[NSMenu alloc] init];
    [settingsMenuItem setSubmenu:settingsMenu];
    
    NSMenuItem *showSettingsItem = [[NSMenuItem alloc] initWithTitle:@"Settings..."
                                                              action:@selector(showSettings:)
                                                       keyEquivalent:@","];
    [showSettingsItem setTarget:[NSApp delegate]];
    [settingsMenu addItem:showSettingsItem];
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        AppDelegate *delegate = [[AppDelegate alloc] init];
        [app setDelegate:delegate];
        
        setupMenuBar();
        
        [app run];
    }
    return 0;
}
