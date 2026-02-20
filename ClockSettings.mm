#import "ClockSettings.h"

NSString *const ClockSettingsChangedNotification = @"ClockSettingsChangedNotification";

@implementation ClockSettings {
    NSUserDefaults *_defaults;
}

+ (instancetype)sharedSettings {
    static ClockSettings *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _defaults = [NSUserDefaults standardUserDefaults];
        [self initializeDefaults];
    }
    return self;
}

- (void)initializeDefaults {
    // Default clock face color: white
    if (![_defaults objectForKey:@"clockFaceColor"]) {
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:[NSColor whiteColor] requiringSecureCoding:NO error:nil];
        if (colorData) {
            [_defaults setObject:colorData forKey:@"clockFaceColor"];
        }
    }
    
    // Default hour hand color: black
    if (![_defaults objectForKey:@"hourHandColor"]) {
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:[NSColor blackColor] requiringSecureCoding:NO error:nil];
        if (colorData) {
            [_defaults setObject:colorData forKey:@"hourHandColor"];
        }
    }
    
    // Default minute hand color: black
    if (![_defaults objectForKey:@"minuteHandColor"]) {
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:[NSColor blackColor] requiringSecureCoding:NO error:nil];
        if (colorData) {
            [_defaults setObject:colorData forKey:@"minuteHandColor"];
        }
    }
    
    // Default day of month position: center (0, 0)
    // The drawing code will use (0, 0) as a signal to use the default position
    // which is just above 6:00, calculated relative to the clock radius
    if (![_defaults objectForKey:@"dayOfMonthPositionX"]) {
        [_defaults setDouble:0.0 forKey:@"dayOfMonthPositionX"];
        [_defaults setDouble:0.0 forKey:@"dayOfMonthPositionY"];
    }
    
    // Default font: system font, size 24
    if (![_defaults objectForKey:@"dayOfMonthFontName"]) {
        [_defaults setObject:@"Helvetica" forKey:@"dayOfMonthFontName"];
        [_defaults setDouble:24.0 forKey:@"dayOfMonthFontSize"];
    }
    
    // Default window opacity: 100% (1.0)
    if (![_defaults objectForKey:@"windowOpacity"]) {
        [_defaults setDouble:1.0 forKey:@"windowOpacity"];
    }
    
    // Default window diameter: 400 pixels
    if (![_defaults objectForKey:@"windowDiameter"]) {
        [_defaults setDouble:400.0 forKey:@"windowDiameter"];
    }
    
    // Default click through: NO (disabled)
    if (![_defaults objectForKey:@"clickThrough"]) {
        [_defaults setBool:NO forKey:@"clickThrough"];
    }
    
    // Default always on top: NO (window position is only saved when user moves the window)
    if (![_defaults objectForKey:@"alwaysOnTop"]) {
        [_defaults setBool:NO forKey:@"alwaysOnTop"];
    }
    
    // Default TZ Hand color: red (to distinguish from regular hour hand)
    if (![_defaults objectForKey:@"tzHandColor"]) {
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:[NSColor redColor] requiringSecureCoding:NO error:nil];
        if (colorData) {
            [_defaults setObject:colorData forKey:@"tzHandColor"];
        }
    }
    
    // Default TZ Hand timezone: UTC
    if (![_defaults objectForKey:@"tzHandTimezone"]) {
        [_defaults setObject:@"UTC" forKey:@"tzHandTimezone"];
    }
}

- (NSColor *)clockFaceColor {
    NSData *colorData = [_defaults objectForKey:@"clockFaceColor"];
    if (colorData) {
        @try {
            NSColor *color = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithObjects:[NSColor class], nil] fromData:colorData error:nil];
            if (color) {
                return color;
            }
        } @catch (NSException *exception) {
            // Use default color
        }
    }
    return [NSColor whiteColor];
}

- (void)setClockFaceColor:(NSColor *)color {
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:NO error:nil];
    if (colorData) {
        [_defaults setObject:colorData forKey:@"clockFaceColor"];
        [self notifySettingsChanged];
    }
}

- (NSColor *)hourHandColor {
    NSData *colorData = [_defaults objectForKey:@"hourHandColor"];
    if (colorData) {
        @try {
            NSColor *color = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithObjects:[NSColor class], nil] fromData:colorData error:nil];
            if (color) {
                return color;
            }
        } @catch (NSException *exception) {
            // Use default color
        }
    }
    return [NSColor blackColor];
}

- (void)setHourHandColor:(NSColor *)color {
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:NO error:nil];
    if (colorData) {
        [_defaults setObject:colorData forKey:@"hourHandColor"];
        [self notifySettingsChanged];
    }
}

- (NSColor *)minuteHandColor {
    NSData *colorData = [_defaults objectForKey:@"minuteHandColor"];
    if (colorData) {
        @try {
            NSColor *color = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithObjects:[NSColor class], nil] fromData:colorData error:nil];
            if (color) {
                return color;
            }
        } @catch (NSException *exception) {
            // Use default color
        }
    }
    return [NSColor blackColor];
}

- (void)setMinuteHandColor:(NSColor *)color {
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:NO error:nil];
    if (colorData) {
        [_defaults setObject:colorData forKey:@"minuteHandColor"];
        [self notifySettingsChanged];
    }
}

- (NSPoint)dayOfMonthPosition {
    double x = [_defaults doubleForKey:@"dayOfMonthPositionX"];
    double y = [_defaults doubleForKey:@"dayOfMonthPositionY"];
    return NSMakePoint(x, y);
}

- (void)setDayOfMonthPosition:(NSPoint)position {
    [_defaults setDouble:position.x forKey:@"dayOfMonthPositionX"];
    [_defaults setDouble:position.y forKey:@"dayOfMonthPositionY"];
    [self notifySettingsChanged];
}

- (NSFont *)dayOfMonthFont {
    NSString *fontName = [_defaults stringForKey:@"dayOfMonthFontName"];
    if (!fontName) {
        fontName = @"Helvetica";
    }
    double fontSize = [_defaults doubleForKey:@"dayOfMonthFontSize"];
    if (fontSize <= 0) {
        fontSize = 24.0;
    }
    NSFont *font = [NSFont fontWithName:fontName size:fontSize];
    if (!font) {
        font = [NSFont systemFontOfSize:fontSize];
    }
    return font;
}

- (void)setDayOfMonthFont:(NSFont *)font {
    [_defaults setObject:[font fontName] forKey:@"dayOfMonthFontName"];
    [_defaults setDouble:[font pointSize] forKey:@"dayOfMonthFontSize"];
    [self notifySettingsChanged];
}

- (CGFloat)windowOpacity {
    if ([_defaults objectForKey:@"windowOpacity"]) {
        return [_defaults doubleForKey:@"windowOpacity"];
    }
    return 1.0; // Default: fully opaque
}

- (void)setWindowOpacity:(CGFloat)opacity {
    // Clamp opacity between 0.0 and 1.0
    CGFloat clampedOpacity = MAX(0.0, MIN(1.0, opacity));
    [_defaults setDouble:clampedOpacity forKey:@"windowOpacity"];
    [self notifySettingsChanged];
}

- (CGFloat)windowDiameter {
    if ([_defaults objectForKey:@"windowDiameter"]) {
        CGFloat diameter = [_defaults doubleForKey:@"windowDiameter"];
        // Ensure minimum size
        return MAX(100.0, diameter);
    }
    return 400.0; // Default: 400 pixels
}

- (void)setWindowDiameter:(CGFloat)diameter {
    // Clamp diameter between 100 and 2000 pixels
    CGFloat clampedDiameter = MAX(100.0, MIN(2000.0, diameter));
    [_defaults setDouble:clampedDiameter forKey:@"windowDiameter"];
    [self notifySettingsChanged];
}

- (BOOL)hasSavedWindowPosition {
    return [_defaults objectForKey:@"windowOriginX"] != nil;
}

- (NSPoint)windowOrigin {
    CGFloat x = [_defaults doubleForKey:@"windowOriginX"];
    CGFloat y = [_defaults doubleForKey:@"windowOriginY"];
    return NSMakePoint(x, y);
}

- (void)setWindowOrigin:(NSPoint)origin {
    [_defaults setDouble:origin.x forKey:@"windowOriginX"];
    [_defaults setDouble:origin.y forKey:@"windowOriginY"];
    // Don't notify - position is only used at launch and when saving from window
}

- (BOOL)alwaysOnTop {
    return [_defaults boolForKey:@"alwaysOnTop"];
}

- (void)setAlwaysOnTop:(BOOL)alwaysOnTop {
    [_defaults setBool:alwaysOnTop forKey:@"alwaysOnTop"];
    [self notifySettingsChanged];
}

- (BOOL)clickThrough {
    return [_defaults boolForKey:@"clickThrough"];
}

- (void)setClickThrough:(BOOL)clickThrough {
    [_defaults setBool:clickThrough forKey:@"clickThrough"];
    [self notifySettingsChanged];
}

- (NSColor *)tzHandColor {
    NSData *colorData = [_defaults objectForKey:@"tzHandColor"];
    if (colorData) {
        @try {
            NSColor *color = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithObjects:[NSColor class], nil] fromData:colorData error:nil];
            if (color) {
                return color;
            }
        } @catch (NSException *exception) {
            // Use default color
        }
    }
    return [NSColor redColor];
}

- (void)setTzHandColor:(NSColor *)color {
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:NO error:nil];
    if (colorData) {
        [_defaults setObject:colorData forKey:@"tzHandColor"];
        [self notifySettingsChanged];
    }
}

- (NSString *)tzHandTimezone {
    NSString *timezone = [_defaults stringForKey:@"tzHandTimezone"];
    if (!timezone) {
        return @"UTC";
    }
    return timezone;
}

- (void)setTzHandTimezone:(NSString *)timezoneIdentifier {
    if (timezoneIdentifier) {
        [_defaults setObject:timezoneIdentifier forKey:@"tzHandTimezone"];
        [self notifySettingsChanged];
    }
}

- (void)notifySettingsChanged {
    [[NSNotificationCenter defaultCenter] postNotificationName:ClockSettingsChangedNotification object:self];
}

@end
