#import "ClockView.h"
#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>

@implementation ClockView {
    NSTimer *_timer;
    ClockSettings *_settings;
    NSTrackingArea *_trackingArea;
    NSDateFormatter *_dateFormatter;
    NSCalendar *_tzCalendar;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        _settings = [ClockSettings sharedSettings];
        
        // Enable layer-backed view for better performance
        self.wantsLayer = YES;
        self.layer.backgroundColor = [[NSColor clearColor] CGColor];
        
        // Start timer to update clock every second
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(timerFired:)
                                                userInfo:nil
                                                 repeats:YES];
        
        // Listen for settings changes
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(settingsChanged:)
                                                     name:ClockSettingsChangedNotification
                                                   object:nil];
        
        // Create tracking area for cursor updates
        [self updateTrackingAreas];
        
        // Reusable date formatter and calendar (avoid allocating every second in drawRect)
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [_dateFormatter setDateFormat:@"HH:mm:ss"];
        _tzCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    }
    return self;
}

- (void)dealloc {
    [_timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_trackingArea) {
        [self removeTrackingArea:_trackingArea];
    }
    [_dateFormatter release];
    [_tzCalendar release];
    [super dealloc];
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    
    if (_trackingArea) {
        [self removeTrackingArea:_trackingArea];
    }
    
    _trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                  options:(NSTrackingMouseMoved | NSTrackingActiveAlways | NSTrackingInVisibleRect)
                                                    owner:self
                                                 userInfo:nil];
    [self addTrackingArea:_trackingArea];
}

- (void)mouseMoved:(NSEvent *)event {
    NSPoint locationInView = [self convertPoint:[event locationInWindow] fromView:nil];
    NSRect bounds = [self bounds];
    CGFloat cornerSize = 15.0;
    
    BOOL inLeftEdge = locationInView.x < cornerSize;
    BOOL inRightEdge = locationInView.x > bounds.size.width - cornerSize;
    BOOL inTopEdge = locationInView.y > bounds.size.height - cornerSize;
    BOOL inBottomEdge = locationInView.y < cornerSize;
    
    if ((inLeftEdge && inTopEdge) || (inRightEdge && inBottomEdge)) {
        [[NSCursor resizeUpDownCursor] set];
    } else if ((inRightEdge && inTopEdge) || (inLeftEdge && inBottomEdge)) {
        [[NSCursor resizeUpDownCursor] set];
    } else if (inLeftEdge || inRightEdge) {
        [[NSCursor resizeLeftRightCursor] set];
    } else if (inTopEdge || inBottomEdge) {
        [[NSCursor resizeUpDownCursor] set];
    } else {
        [[NSCursor arrowCursor] set];
    }
}

- (void)timerFired:(NSTimer *)timer {
    [self setNeedsDisplay:YES];
}

- (void)settingsChanged:(NSNotification *)notification {
    // Force immediate redraw on main thread when settings change
    // This ensures TZ Hand updates when timezone changes
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay:YES];
        [self displayIfNeeded];
        // Also invalidate and force a redraw
        [self setNeedsDisplayInRect:[self bounds]];
    });
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSRect bounds = [self bounds];
    CGFloat centerX = NSMidX(bounds);
    CGFloat centerY = NSMidY(bounds);
    CGFloat radius = MIN(bounds.size.width, bounds.size.height) / 2.0;
    
    // Get graphics context
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    CGContextRef cgContext = [context CGContext];
    
    // Enable antialiasing
    CGContextSetShouldAntialias(cgContext, YES);
    CGContextSetAllowsAntialiasing(cgContext, YES);
    
    // Save context state
    CGContextSaveGState(cgContext);
    
    // Translate to center
    CGContextTranslateCTM(cgContext, centerX, centerY);
    
    // Draw clock face (filled circle) - Swiss railway clock style
    NSColor *faceColor = [_settings clockFaceColor];
    [faceColor setFill];
    NSBezierPath *facePath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(-radius, -radius, radius * 2, radius * 2)];
    [facePath fill];
    
    // Draw thick black border circle (characteristic of Swiss railway clock)
    // The border is quite prominent, typically 3-5% of radius
    [[NSColor blackColor] setStroke];
    NSBezierPath *borderPath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(-radius, -radius, radius * 2, radius * 2)];
    [borderPath setLineWidth:radius * 0.05]; // 5% of radius for thick, prominent border
    [borderPath stroke];
    
    // Draw minute markers (60 thin rectangles at 6° intervals)
    // These are 1/3 the size of hour markers and start at the same outside diameter
    CGFloat borderThickness = radius * 0.05;
    CGFloat markerStartRadius = radius - borderThickness; // Just inside the border
    
    CGFloat hourMarkerWidth = radius * 0.04; // 4% of radius (width of hour marker)
    CGFloat hourMarkerLength = radius * 0.12; // 12% of radius (length of hour marker)
    
    // Minute markers are 1/3 the size of hour markers
    CGFloat minuteMarkerWidth = hourMarkerWidth / 3.0; // 1/3 width
    CGFloat minuteMarkerLength = hourMarkerLength / 3.0; // 1/3 length
    
    [[NSColor blackColor] setFill];
    for (int i = 0; i < 60; ++i) {
        CGContextSaveGState(cgContext);
        CGFloat angle = (i * 6.0 - 90.0) * M_PI / 180.0; // -90° to start at top, 6° per minute
        CGContextRotateCTM(cgContext, angle);
        
        // Position marker from edge (same starting point as hour markers) extending inward
        NSRect markerRect = NSMakeRect(-minuteMarkerWidth / 2, 
                                       markerStartRadius - minuteMarkerLength, 
                                       minuteMarkerWidth, 
                                       minuteMarkerLength);
        NSBezierPath *markerPath = [NSBezierPath bezierPathWithRect:markerRect];
        [markerPath fill];
        
        CGContextRestoreGState(cgContext);
    }
    
    // Draw hour markers (12 black rectangles at 30° intervals)
    // Swiss railway clock: markers are positioned right at the edge, extending inward
    // They are substantial rectangles that sit just inside the border
    // Hour markers will cover the minute markers at their positions
    CGFloat hourMarkerRadius = markerStartRadius; // Same starting point as minute markers
    
    for (int i = 0; i < 12; ++i) {
        CGContextSaveGState(cgContext);
        CGFloat angle = (i * 30.0 - 90.0) * M_PI / 180.0; // -90° to start at top
        CGContextRotateCTM(cgContext, angle);
        
        // Position marker from edge (just inside border) extending inward
        NSRect markerRect = NSMakeRect(-hourMarkerWidth / 2, 
                                       hourMarkerRadius - hourMarkerLength, 
                                       hourMarkerWidth, 
                                       hourMarkerLength);
        NSBezierPath *markerPath = [NSBezierPath bezierPathWithRect:markerRect];
        [markerPath fill];
        
        CGContextRestoreGState(cgContext);
    }
    
    // Get current time using cached date formatter (local timezone already set in init)
    NSString *timeString = [_dateFormatter stringFromDate:[NSDate date]];
    
    // Parse hour and minute from string to ensure we get correct values
    NSArray *timeParts = [timeString componentsSeparatedByString:@":"];
    NSInteger hour = [[timeParts objectAtIndex:0] integerValue];
    NSInteger minute = [[timeParts objectAtIndex:1] integerValue];
    NSInteger second = [[timeParts objectAtIndex:2] integerValue];
    
    // Get day using calendar
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *dayComponents = [calendar components:NSCalendarUnitDay fromDate:[NSDate date]];
    NSInteger day = [dayComponents day];
    
    // Calculate hand angles
    // In Core Graphics, 0° is at 3 o'clock, positive rotation is counterclockwise
    // For a clock: 12 o'clock (top) = -90° in standard math
    // The markers use: (i * 6.0 - 90.0) * M_PI / 180.0 without negation
    // Hands need an additional -90° rotation to be accurate
    // Hour: 30° per hour + 0.5° per minute
    NSInteger hour12 = hour % 12;
    CGFloat hourAngle = (hour12 * 30.0 + minute * 0.5 - 90.0 - 90.0) * M_PI / 180.0;
    // Minute: 6° per minute
    CGFloat minuteAngle = (minute * 6.0 - 90.0 - 90.0) * M_PI / 180.0;
    
    // Calculate TZ Hand angle for selected timezone
    CGFloat tzHandAngle = 0.0;
    NSString *tzHandTimezone = [_settings tzHandTimezone];
    if (tzHandTimezone && [tzHandTimezone length] > 0) {
        NSTimeZone *tz = [NSTimeZone timeZoneWithName:tzHandTimezone];
        if (!tz) {
            // Try alternative timezone identifier format
            tz = [NSTimeZone timeZoneWithAbbreviation:tzHandTimezone];
        }
        if (tz) {
            [_tzCalendar setTimeZone:tz];
            NSDate *now = [NSDate date];
            NSDateComponents *tzComponents = [_tzCalendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:now];
            NSInteger tzHour = [tzComponents hour];
            NSInteger tzMinute = [tzComponents minute];
            NSInteger tzHour12 = tzHour % 12;
            if (tzHour12 == 0) tzHour12 = 12; // 0 o'clock = 12 o'clock
            tzHandAngle = (tzHour12 * 30.0 + tzMinute * 0.5 - 90.0 - 90.0) * M_PI / 180.0;
        }
    }
    
    // Draw hour hand (rectangle, thicker and longer, crossing center by 25%)
    NSColor *hourHandColor = [_settings hourHandColor];
    [hourHandColor setFill];
    CGFloat hourHandWidth = radius * 0.08; // 8% of radius (thicker)
    CGFloat hourHandLength = radius * 0.5; // 50% of radius (forward length)
    CGFloat hourHandBackLength = hourHandLength * 0.25; // 25% extends past center
    
    CGContextSaveGState(cgContext);
    // Flip Y coordinate to match standard clock orientation (Y up = 12 o'clock)
    CGContextScaleCTM(cgContext, 1.0, -1.0);
    CGContextRotateCTM(cgContext, hourAngle);
    // Draw hand extending from -backLength (past center) to +length (forward)
    NSRect hourHandRect = NSMakeRect(-hourHandWidth / 2, -hourHandBackLength, hourHandWidth, hourHandLength + hourHandBackLength);
    NSBezierPath *hourHandPath = [NSBezierPath bezierPathWithRect:hourHandRect];
    [hourHandPath fill];
    CGContextRestoreGState(cgContext);
    
    // Draw minute hand (rectangle, thicker and longer, crossing center by 25%)
    NSColor *minuteHandColor = [_settings minuteHandColor];
    [minuteHandColor setFill];
    CGFloat minuteHandWidth = radius * 0.08; // 8% of radius (thicker, same as hour hand)
    CGFloat minuteHandLength = radius * 0.7; // 70% of radius (longer than hour hand)
    CGFloat minuteHandBackLength = minuteHandLength * 0.25; // 25% extends past center
    
    CGContextSaveGState(cgContext);
    // Flip Y coordinate to match standard clock orientation (Y up = 12 o'clock)
    CGContextScaleCTM(cgContext, 1.0, -1.0);
    CGContextRotateCTM(cgContext, minuteAngle);
    // Draw hand extending from -backLength (past center) to +length (forward)
    NSRect minuteHandRect = NSMakeRect(-minuteHandWidth / 2, -minuteHandBackLength, minuteHandWidth, minuteHandLength + minuteHandBackLength);
    NSBezierPath *minuteHandPath = [NSBezierPath bezierPathWithRect:minuteHandRect];
    [minuteHandPath fill];
    CGContextRestoreGState(cgContext);
    
    // Draw TZ Hand (same shape as hour hand, but for different timezone)
    NSColor *tzHandColor = [_settings tzHandColor];
    [tzHandColor setFill];
    CGFloat tzHandWidth = radius * 0.08; // 8% of radius (same as hour hand)
    CGFloat tzHandLength = radius * 0.5; // 50% of radius (same as hour hand)
    CGFloat tzHandBackLength = tzHandLength * 0.25; // 25% extends past center (same as hour hand)
    
    CGContextSaveGState(cgContext);
    // Flip Y coordinate to match standard clock orientation (Y up = 12 o'clock)
    CGContextScaleCTM(cgContext, 1.0, -1.0);
    CGContextRotateCTM(cgContext, tzHandAngle);
    // Draw hand extending from -backLength (past center) to +length (forward)
    NSRect tzHandRect = NSMakeRect(-tzHandWidth / 2, -tzHandBackLength, tzHandWidth, tzHandLength + tzHandBackLength);
    NSBezierPath *tzHandPath = [NSBezierPath bezierPathWithRect:tzHandRect];
    [tzHandPath fill];
    CGContextRestoreGState(cgContext);
    
    // Draw center dot (Swiss railway clock has a small black center dot)
    [[NSColor blackColor] setFill];
    CGFloat centerDotRadius = radius * 0.02; // 2% of radius (small center dot)
    NSBezierPath *centerDotPath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(-centerDotRadius, -centerDotRadius, 
                                                                                     centerDotRadius * 2, centerDotRadius * 2)];
    [centerDotPath fill];
    
    // Draw day of month
    NSPoint dayPosition = [_settings dayOfMonthPosition];
    NSFont *dayFont = [_settings dayOfMonthFont];
    NSString *dayString = [NSString stringWithFormat:@"%ld", (long)day];
    
    // Use the position from settings
    // If user hasn't customized it, it will be (0, 0) and we use default
    // Otherwise use the custom position
    NSPoint actualPosition = dayPosition;
    
    // Check if position is unset (both exactly 0.0) - use default
    // We use a small epsilon to handle floating point comparison
    const CGFloat epsilon = 0.001;
    if (fabs(dayPosition.x) < epsilon && fabs(dayPosition.y) < epsilon) {
        // Default: just above 6:00 (bottom of clock)
        // Position at about 75% down from center, slightly above the edge
        actualPosition = NSMakePoint(0.0, -radius * 0.75);
    }
    
    NSDictionary *attributes = @{
        NSFontAttributeName: dayFont,
        NSForegroundColorAttributeName: [NSColor blackColor]
    };
    
    NSAttributedString *attributedDayString = [[NSAttributedString alloc] initWithString:dayString attributes:attributes];
    NSSize textSize = [attributedDayString size];
    NSPoint textOrigin = NSMakePoint(actualPosition.x - textSize.width / 2, 
                                     actualPosition.y - textSize.height / 2);
    
    [attributedDayString drawAtPoint:textOrigin];
    [attributedDayString release];
    
    // Restore context state
    CGContextRestoreGState(cgContext);
}

@end
