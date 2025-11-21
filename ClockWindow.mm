#import "ClockWindow.h"
#import "ClockView.h"
#import "ClockSettings.h"
#import <dispatch/dispatch.h>

@implementation ClockWindow {
    NSPoint _initialLocation;
    NSPoint _initialMouseLocation;
    NSSize _initialSize;
    BOOL _isDragging;
    BOOL _isResizing;
    NSPoint _resizeStartMouseLocation;
    NSSize _resizeStartSize;
    NSPoint _resizeStartOrigin;
    ClockSettings *_settings;
}

- (instancetype)initWithContentRect:(NSRect)contentRect {
    // Create borderless, transparent window
    self = [super initWithContentRect:contentRect
                            styleMask:NSWindowStyleMaskBorderless
                              backing:NSBackingStoreBuffered
                                defer:NO];
    
    if (self) {
        _settings = [ClockSettings sharedSettings];
        
        // Set window properties
        [self setBackgroundColor:[NSColor clearColor]];
        [self setOpaque:NO];
        [self setHasShadow:NO];
        [self setLevel:NSNormalWindowLevel];
        [self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces | 
                                    NSWindowCollectionBehaviorFullScreenAuxiliary];
        
        // Make window movable by background
        [self setMovableByWindowBackground:YES];
        
        // Apply initial opacity
        [self updateOpacity];
        
        // Apply initial click-through setting
        [self updateClickThrough];
        
        // Create clock view
        ClockView *clockView = [[ClockView alloc] initWithFrame:contentRect];
        [self setContentView:clockView];
        
        // Enable layer for circular masking
        [self.contentView setWantsLayer:YES];
        [self.contentView.layer setCornerRadius:MIN(contentRect.size.width, contentRect.size.height) / 2.0];
        [self.contentView.layer setMasksToBounds:YES];
        
        // Listen for settings changes
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(settingsChanged:)
                                                     name:ClockSettingsChangedNotification
                                                   object:nil];
        
        _isDragging = NO;
    }
    
    return self;
}

- (void)setFrame:(NSRect)frameRect display:(BOOL)flag {
    // Maintain square aspect ratio
    CGFloat size = MIN(frameRect.size.width, frameRect.size.height);
    frameRect.size.width = size;
    frameRect.size.height = size;
    
    [super setFrame:frameRect display:flag];
    
    // Update corner radius for circular mask
    if (self.contentView.layer) {
        self.contentView.layer.cornerRadius = size / 2.0;
    }
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (BOOL)canBecomeMainWindow {
    return YES;
}

- (void)mouseDown:(NSEvent *)event {
    // Check if click is in a resize area (corners/edges)
    NSPoint locationInWindow = [event locationInWindow];
    NSRect frame = [self frame];
    CGFloat cornerSize = 15.0;
    
    // Check corners and edges for resizing
    BOOL inLeftEdge = locationInWindow.x < cornerSize;
    BOOL inRightEdge = locationInWindow.x > frame.size.width - cornerSize;
    BOOL inTopEdge = locationInWindow.y > frame.size.height - cornerSize;
    BOOL inBottomEdge = locationInWindow.y < cornerSize;
    
    if (inLeftEdge || inRightEdge || inTopEdge || inBottomEdge) {
        // Start resizing
        _isResizing = YES;
        _resizeStartMouseLocation = [NSEvent mouseLocation];
        _resizeStartSize = frame.size;
        _resizeStartOrigin = frame.origin;
        _isDragging = NO;
    } else {
        // Start dragging
        _initialLocation = [self frame].origin;
        _initialMouseLocation = [NSEvent mouseLocation];
        _isDragging = YES;
        _isResizing = NO;
    }
}

- (void)mouseDragged:(NSEvent *)event {
    if (_isResizing) {
        NSPoint currentMouseLocation = [NSEvent mouseLocation];
        NSPoint locationInWindow = [event locationInWindow];
        NSRect frame = [self frame];
        CGFloat cornerSize = 15.0;
        
        // Determine which edges are being resized
        BOOL resizeLeft = locationInWindow.x < cornerSize;
        BOOL resizeRight = locationInWindow.x > frame.size.width - cornerSize;
        BOOL resizeTop = locationInWindow.y > frame.size.height - cornerSize;
        BOOL resizeBottom = locationInWindow.y < cornerSize;
        
        // Calculate mouse delta
        NSPoint mouseDelta = NSMakePoint(currentMouseLocation.x - _resizeStartMouseLocation.x,
                                         currentMouseLocation.y - _resizeStartMouseLocation.y);
        
        // Calculate new size (maintain square aspect ratio)
        CGFloat deltaSize = 0;
        if (resizeRight || resizeTop) {
            // Resizing from right or top - use positive delta
            deltaSize = MAX(mouseDelta.x, mouseDelta.y);
        } else if (resizeLeft || resizeBottom) {
            // Resizing from left or bottom - use negative delta
            deltaSize = MIN(mouseDelta.x, mouseDelta.y);
        }
        
        CGFloat newSize = MAX(100.0, _resizeStartSize.width + deltaSize); // Minimum 100x100
        
        // Calculate new origin (adjust if resizing from left or bottom)
        NSPoint newOrigin = _resizeStartOrigin;
        if (resizeLeft) {
            newOrigin.x = _resizeStartOrigin.x + _resizeStartSize.width - newSize;
        }
        if (resizeBottom) {
            newOrigin.y = _resizeStartOrigin.y + _resizeStartSize.height - newSize;
        }
        
        // Set new frame
        NSRect newFrame = NSMakeRect(newOrigin.x, newOrigin.y, newSize, newSize);
        [self setFrame:newFrame display:YES];
        
    } else if (_isDragging) {
        NSPoint currentMouseLocation = [NSEvent mouseLocation];
        NSPoint delta = NSMakePoint(currentMouseLocation.x - _initialMouseLocation.x,
                                    currentMouseLocation.y - _initialMouseLocation.y);
        
        NSPoint newOrigin = NSMakePoint(_initialLocation.x + delta.x,
                                        _initialLocation.y + delta.y);
        [self setFrameOrigin:newOrigin];
    }
}

- (void)mouseUp:(NSEvent *)event {
    _isDragging = NO;
    _isResizing = NO;
    [super mouseUp:event];
}

- (void)settingsChanged:(NSNotification *)notification {
    // Ensure updates happen on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateOpacity];
        [self updateDiameter];
        [self updateClickThrough];
    });
}

- (void)updateOpacity {
    CGFloat opacity = [_settings windowOpacity];
    [self setAlphaValue:opacity];
    // Force window to update
    [self displayIfNeeded];
}

- (void)updateDiameter {
    CGFloat diameter = [_settings windowDiameter];
    NSRect currentFrame = [self frame];
    
    // Only update if diameter actually changed
    if (fabs(currentFrame.size.width - diameter) < 1.0 && fabs(currentFrame.size.height - diameter) < 1.0) {
        return; // Already at the correct size
    }
    
    // Calculate center point
    CGFloat centerX = currentFrame.origin.x + currentFrame.size.width / 2.0;
    CGFloat centerY = currentFrame.origin.y + currentFrame.size.height / 2.0;
    
    // Create new frame centered on the same point
    NSRect newFrame = NSMakeRect(centerX - diameter / 2.0, 
                                 centerY - diameter / 2.0, 
                                 diameter, 
                                 diameter);
    
    // Update the window frame
    [self setFrame:newFrame display:YES];
    
    // Also update the content view frame
    [self.contentView setFrame:NSMakeRect(0, 0, diameter, diameter)];
    
    // Update corner radius for circular mask
    if (self.contentView.layer) {
        self.contentView.layer.cornerRadius = diameter / 2.0;
    }
}

- (void)updateClickThrough {
    BOOL clickThrough = [_settings clickThrough];
    [self setIgnoresMouseEvents:clickThrough];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
