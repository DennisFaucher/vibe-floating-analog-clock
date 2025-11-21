#import "SettingsWindow.h"
#import "ClockSettings.h"

@interface SettingsWindow () <NSWindowDelegate>
@property (strong) NSColorWell *clockFaceColorWell;
@property (strong) NSColorWell *hourHandColorWell;
@property (strong) NSColorWell *minuteHandColorWell;
@property (strong) NSPopUpButton *fontNamePopup;
@property (strong) NSTextField *fontSizeField;
@property (strong) NSTextField *positionXField;
@property (strong) NSTextField *positionYField;
@property (strong) NSTextField *opacityField;
@property (strong) NSTextField *diameterField;
@property (strong) NSButton *clickThroughCheckbox;
@property (strong) NSColorWell *tzHandColorWell;
@property (strong) NSPopUpButton *tzHandTimezonePopup;
@end

@implementation SettingsWindow

- (instancetype)init {
    NSRect contentRect = NSMakeRect(0, 0, 400, 450);
    
    self = [super initWithContentRect:contentRect
                            styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable
                              backing:NSBackingStoreBuffered
                                defer:NO];
    
    if (self) {
        [self setTitle:@"VibeClock Settings"];
        [self setDelegate:self];
        [self center];
        
        ClockSettings *settings = [ClockSettings sharedSettings];
        
        // Create scroll view for content
        NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:contentRect];
        [scrollView setHasVerticalScroller:YES];
        [scrollView setAutohidesScrollers:YES];
        [scrollView setBorderType:NSBezelBorder];
        
        // Create container view (increased height for new fields)
        NSView *containerView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, contentRect.size.width, 800)];
        
        CGFloat yPos = 650;
        CGFloat labelWidth = 150;
        CGFloat fieldWidth = 200;
        CGFloat spacing = 30;
        
        // Clock Face Color
        NSTextField *faceColorLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, yPos, labelWidth, 22)];
        [faceColorLabel setStringValue:@"Clock Face Color:"];
        [faceColorLabel setBezeled:NO];
        [faceColorLabel setDrawsBackground:NO];
        [faceColorLabel setEditable:NO];
        [faceColorLabel setSelectable:NO];
        [containerView addSubview:faceColorLabel];
        
        self.clockFaceColorWell = [[NSColorWell alloc] initWithFrame:NSMakeRect(180, yPos, fieldWidth, 22)];
        [self.clockFaceColorWell setColor:[settings clockFaceColor]];
        [self.clockFaceColorWell setTarget:self];
        [self.clockFaceColorWell setAction:@selector(clockFaceColorChanged:)];
        [containerView addSubview:self.clockFaceColorWell];
        
        yPos -= spacing;
        
        // Hour Hand Color
        NSTextField *hourHandLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, yPos, labelWidth, 22)];
        [hourHandLabel setStringValue:@"Hour Hand Color:"];
        [hourHandLabel setBezeled:NO];
        [hourHandLabel setDrawsBackground:NO];
        [hourHandLabel setEditable:NO];
        [hourHandLabel setSelectable:NO];
        [containerView addSubview:hourHandLabel];
        
        self.hourHandColorWell = [[NSColorWell alloc] initWithFrame:NSMakeRect(180, yPos, fieldWidth, 22)];
        [self.hourHandColorWell setColor:[settings hourHandColor]];
        [self.hourHandColorWell setTarget:self];
        [self.hourHandColorWell setAction:@selector(hourHandColorChanged:)];
        [containerView addSubview:self.hourHandColorWell];
        
        yPos -= spacing;
        
        // Minute Hand Color
        NSTextField *minuteHandLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, yPos, labelWidth, 22)];
        [minuteHandLabel setStringValue:@"Minute Hand Color:"];
        [minuteHandLabel setBezeled:NO];
        [minuteHandLabel setDrawsBackground:NO];
        [minuteHandLabel setEditable:NO];
        [minuteHandLabel setSelectable:NO];
        [containerView addSubview:minuteHandLabel];
        
        self.minuteHandColorWell = [[NSColorWell alloc] initWithFrame:NSMakeRect(180, yPos, fieldWidth, 22)];
        [self.minuteHandColorWell setColor:[settings minuteHandColor]];
        [self.minuteHandColorWell setTarget:self];
        [self.minuteHandColorWell setAction:@selector(minuteHandColorChanged:)];
        [containerView addSubview:self.minuteHandColorWell];
        
        yPos -= spacing;
        
        // TZ Hand Color
        NSTextField *tzHandColorLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, yPos, labelWidth, 22)];
        [tzHandColorLabel setStringValue:@"TZ Hand Color:"];
        [tzHandColorLabel setBezeled:NO];
        [tzHandColorLabel setDrawsBackground:NO];
        [tzHandColorLabel setEditable:NO];
        [tzHandColorLabel setSelectable:NO];
        [containerView addSubview:tzHandColorLabel];
        
        self.tzHandColorWell = [[NSColorWell alloc] initWithFrame:NSMakeRect(180, yPos, fieldWidth, 22)];
        [self.tzHandColorWell setColor:[settings tzHandColor]];
        [self.tzHandColorWell setTarget:self];
        [self.tzHandColorWell setAction:@selector(tzHandColorChanged:)];
        [containerView addSubview:self.tzHandColorWell];
        
        yPos -= spacing;
        
        // TZ Hand Timezone
        NSTextField *tzHandTimezoneLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, yPos, labelWidth, 22)];
        [tzHandTimezoneLabel setStringValue:@"TZ Hand Timezone:"];
        [tzHandTimezoneLabel setBezeled:NO];
        [tzHandTimezoneLabel setDrawsBackground:NO];
        [tzHandTimezoneLabel setEditable:NO];
        [tzHandTimezoneLabel setSelectable:NO];
        [containerView addSubview:tzHandTimezoneLabel];
        
        self.tzHandTimezonePopup = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(180, yPos, fieldWidth, 22) pullsDown:NO];
        
        // Populate with common timezones
        NSArray *timezones = @[
            @"UTC",
            @"America/New_York",
            @"America/Chicago",
            @"America/Denver",
            @"America/Los_Angeles",
            @"America/Phoenix",
            @"America/Anchorage",
            @"Pacific/Honolulu",
            @"Europe/London",
            @"Europe/Paris",
            @"Europe/Berlin",
            @"Europe/Rome",
            @"Europe/Madrid",
            @"Europe/Amsterdam",
            @"Europe/Stockholm",
            @"Europe/Moscow",
            @"Asia/Tokyo",
            @"Asia/Shanghai",
            @"Asia/Hong_Kong",
            @"Asia/Singapore",
            @"Asia/Dubai",
            @"Asia/Kolkata",
            @"Australia/Sydney",
            @"Australia/Melbourne",
            @"Australia/Perth",
            @"Pacific/Auckland",
            @"America/Toronto",
            @"America/Vancouver",
            @"America/Mexico_City",
            @"America/Sao_Paulo",
            @"America/Buenos_Aires"
        ];
        [self.tzHandTimezonePopup addItemsWithTitles:timezones];
        
        // Select current timezone
        NSString *currentTimezone = [settings tzHandTimezone];
        NSInteger tzIndex = [self.tzHandTimezonePopup indexOfItemWithTitle:currentTimezone];
        if (tzIndex == -1) {
            // If current timezone not in list, add it and select it
            [self.tzHandTimezonePopup addItemWithTitle:currentTimezone];
            tzIndex = [self.tzHandTimezonePopup numberOfItems] - 1;
        }
        [self.tzHandTimezonePopup selectItemAtIndex:tzIndex];
        
        [self.tzHandTimezonePopup setTarget:self];
        [self.tzHandTimezonePopup setAction:@selector(tzHandTimezoneChanged:)];
        [containerView addSubview:self.tzHandTimezonePopup];
        
        yPos -= spacing * 1.5;
        
        // Day of Month Font Section
        NSTextField *fontSectionLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, yPos, labelWidth, 22)];
        [fontSectionLabel setStringValue:@"Day of Month Font:"];
        [fontSectionLabel setBezeled:NO];
        [fontSectionLabel setDrawsBackground:NO];
        [fontSectionLabel setEditable:NO];
        [fontSectionLabel setSelectable:NO];
        [fontSectionLabel setFont:[NSFont boldSystemFontOfSize:13]];
        [containerView addSubview:fontSectionLabel];
        
        yPos -= spacing;
        
        // Font Name
        NSTextField *fontNameLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(40, yPos, labelWidth - 20, 22)];
        [fontNameLabel setStringValue:@"Font Name:"];
        [fontNameLabel setBezeled:NO];
        [fontNameLabel setDrawsBackground:NO];
        [fontNameLabel setEditable:NO];
        [fontNameLabel setSelectable:NO];
        [containerView addSubview:fontNameLabel];
        
        // Create popup button with common fonts
        self.fontNamePopup = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(180, yPos, fieldWidth, 22) pullsDown:NO];
        NSArray *fontNames = @[
            @"Helvetica",
            @"Helvetica-Bold",
            @"Helvetica-Oblique",
            @"Arial",
            @"Arial-Bold",
            @"Times-Roman",
            @"Times-Bold",
            @"Courier",
            @"Courier-Bold",
            @"Menlo",
            @"Monaco",
            @"Lucida Grande",
            @"Verdana",
            @"Georgia",
            @"Palatino"
        ];
        [self.fontNamePopup addItemsWithTitles:fontNames];
        
        // Select current font
        NSFont *currentFont = [settings dayOfMonthFont];
        NSString *currentFontName = [currentFont fontName];
        NSInteger index = [self.fontNamePopup indexOfItemWithTitle:currentFontName];
        if (index == -1) {
            // If current font not in list, add it and select it
            [self.fontNamePopup addItemWithTitle:currentFontName];
            index = [self.fontNamePopup numberOfItems] - 1;
        }
        [self.fontNamePopup selectItemAtIndex:index];
        
        [self.fontNamePopup setTarget:self];
        [self.fontNamePopup setAction:@selector(fontNameChanged:)];
        [containerView addSubview:self.fontNamePopup];
        
        yPos -= spacing;
        
        // Font Size
        NSTextField *fontSizeLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(40, yPos, labelWidth - 20, 22)];
        [fontSizeLabel setStringValue:@"Font Size:"];
        [fontSizeLabel setBezeled:NO];
        [fontSizeLabel setDrawsBackground:NO];
        [fontSizeLabel setEditable:NO];
        [fontSizeLabel setSelectable:NO];
        [containerView addSubview:fontSizeLabel];
        
        self.fontSizeField = [[NSTextField alloc] initWithFrame:NSMakeRect(180, yPos, 100, 22)];
        [self.fontSizeField setStringValue:[NSString stringWithFormat:@"%.1f", [currentFont pointSize]]];
        [self.fontSizeField setTarget:self];
        [self.fontSizeField setAction:@selector(fontSizeChanged:)];
        // Also update when text changes (not just on Enter)
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fontSizeFieldChanged:)
                                                     name:NSControlTextDidChangeNotification
                                                   object:self.fontSizeField];
        [containerView addSubview:self.fontSizeField];
        
        yPos -= spacing * 1.5;
        
        // Day of Month Position Section
        NSTextField *positionSectionLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, yPos, labelWidth, 22)];
        [positionSectionLabel setStringValue:@"Day of Month Position:"];
        [positionSectionLabel setBezeled:NO];
        [positionSectionLabel setDrawsBackground:NO];
        [positionSectionLabel setEditable:NO];
        [positionSectionLabel setSelectable:NO];
        [positionSectionLabel setFont:[NSFont boldSystemFontOfSize:13]];
        [containerView addSubview:positionSectionLabel];
        
        yPos -= spacing;
        
        // Position X
        NSTextField *positionXLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(40, yPos, labelWidth - 20, 22)];
        [positionXLabel setStringValue:@"X Position:"];
        [positionXLabel setBezeled:NO];
        [positionXLabel setDrawsBackground:NO];
        [positionXLabel setEditable:NO];
        [positionXLabel setSelectable:NO];
        [containerView addSubview:positionXLabel];
        
        self.positionXField = [[NSTextField alloc] initWithFrame:NSMakeRect(180, yPos, 100, 22)];
        NSPoint currentPosition = [settings dayOfMonthPosition];
        [self.positionXField setStringValue:[NSString stringWithFormat:@"%.1f", currentPosition.x]];
        [self.positionXField setTarget:self];
        [self.positionXField setAction:@selector(positionChanged:)];
        // Also update when text changes
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(positionFieldChanged:)
                                                     name:NSControlTextDidChangeNotification
                                                   object:self.positionXField];
        [containerView addSubview:self.positionXField];
        
        yPos -= spacing;
        
        // Position Y
        NSTextField *positionYLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(40, yPos, labelWidth - 20, 22)];
        [positionYLabel setStringValue:@"Y Position:"];
        [positionYLabel setBezeled:NO];
        [positionYLabel setDrawsBackground:NO];
        [positionYLabel setEditable:NO];
        [positionYLabel setSelectable:NO];
        [containerView addSubview:positionYLabel];
        
        self.positionYField = [[NSTextField alloc] initWithFrame:NSMakeRect(180, yPos, 100, 22)];
        [self.positionYField setStringValue:[NSString stringWithFormat:@"%.1f", currentPosition.y]];
        [self.positionYField setTarget:self];
        [self.positionYField setAction:@selector(positionChanged:)];
        // Also update when text changes
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(positionFieldChanged:)
                                                     name:NSControlTextDidChangeNotification
                                                   object:self.positionYField];
        [containerView addSubview:self.positionYField];
        
        yPos -= spacing * 1.5;
        
        // Window Settings Section
        NSTextField *windowSectionLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, yPos, labelWidth, 22)];
        [windowSectionLabel setStringValue:@"Window Settings:"];
        [windowSectionLabel setBezeled:NO];
        [windowSectionLabel setDrawsBackground:NO];
        [windowSectionLabel setEditable:NO];
        [windowSectionLabel setSelectable:NO];
        [windowSectionLabel setFont:[NSFont boldSystemFontOfSize:13]];
        [containerView addSubview:windowSectionLabel];
        
        yPos -= spacing;
        
        // Opacity
        NSTextField *opacityLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(40, yPos, labelWidth - 20, 22)];
        [opacityLabel setStringValue:@"Opacity (%):"];
        [opacityLabel setBezeled:NO];
        [opacityLabel setDrawsBackground:NO];
        [opacityLabel setEditable:NO];
        [opacityLabel setSelectable:NO];
        [containerView addSubview:opacityLabel];
        
        self.opacityField = [[NSTextField alloc] initWithFrame:NSMakeRect(180, yPos, 100, 22)];
        CGFloat currentOpacity = [settings windowOpacity];
        [self.opacityField setStringValue:[NSString stringWithFormat:@"%.0f", currentOpacity * 100.0]];
        [self.opacityField setTarget:self];
        [self.opacityField setAction:@selector(opacityChanged:)];
        // Also update when text changes (not just on Enter)
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(opacityFieldChanged:)
                                                     name:NSControlTextDidChangeNotification
                                                   object:self.opacityField];
        [containerView addSubview:self.opacityField];
        
        yPos -= spacing;
        
        // Diameter
        NSTextField *diameterLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(40, yPos, labelWidth - 20, 22)];
        [diameterLabel setStringValue:@"Diameter (pixels):"];
        [diameterLabel setBezeled:NO];
        [diameterLabel setDrawsBackground:NO];
        [diameterLabel setEditable:NO];
        [diameterLabel setSelectable:NO];
        [containerView addSubview:diameterLabel];
        
        self.diameterField = [[NSTextField alloc] initWithFrame:NSMakeRect(180, yPos, 100, 22)];
        CGFloat currentDiameter = [settings windowDiameter];
        [self.diameterField setStringValue:[NSString stringWithFormat:@"%.0f", currentDiameter]];
        [self.diameterField setTarget:self];
        [self.diameterField setAction:@selector(diameterChanged:)];
        // Also update when text changes (not just on Enter)
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(diameterFieldChanged:)
                                                     name:NSControlTextDidChangeNotification
                                                   object:self.diameterField];
        [containerView addSubview:self.diameterField];
        
        yPos -= spacing;
        
        // Click Through
        self.clickThroughCheckbox = [[NSButton alloc] initWithFrame:NSMakeRect(40, yPos, 300, 22)];
        [self.clickThroughCheckbox setButtonType:NSButtonTypeSwitch];
        [self.clickThroughCheckbox setTitle:@"Click Through (allow clicks to pass through window)"];
        [self.clickThroughCheckbox setState:[settings clickThrough] ? NSControlStateValueOn : NSControlStateValueOff];
        [self.clickThroughCheckbox setTarget:self];
        [self.clickThroughCheckbox setAction:@selector(clickThroughChanged:)];
        [containerView addSubview:self.clickThroughCheckbox];
        
        // Set document view
        [scrollView setDocumentView:containerView];
        [self setContentView:scrollView];
    }
    
    return self;
}

- (void)clockFaceColorChanged:(id)sender {
    ClockSettings *settings = [ClockSettings sharedSettings];
    [settings setClockFaceColor:[self.clockFaceColorWell color]];
}

- (void)hourHandColorChanged:(id)sender {
    ClockSettings *settings = [ClockSettings sharedSettings];
    [settings setHourHandColor:[self.hourHandColorWell color]];
}

- (void)minuteHandColorChanged:(id)sender {
    ClockSettings *settings = [ClockSettings sharedSettings];
    [settings setMinuteHandColor:[self.minuteHandColorWell color]];
}

- (void)tzHandColorChanged:(id)sender {
    ClockSettings *settings = [ClockSettings sharedSettings];
    [settings setTzHandColor:[self.tzHandColorWell color]];
}

- (void)tzHandTimezoneChanged:(id)sender {
    ClockSettings *settings = [ClockSettings sharedSettings];
    NSString *timezone = [self.tzHandTimezonePopup titleOfSelectedItem];
    [settings setTzHandTimezone:timezone];
}

- (void)fontNameChanged:(id)sender {
    ClockSettings *settings = [ClockSettings sharedSettings];
    NSString *fontName = [self.fontNamePopup titleOfSelectedItem];
    NSFont *currentFont = [settings dayOfMonthFont];
    NSFont *newFont = [NSFont fontWithName:fontName size:[currentFont pointSize]];
    if (newFont) {
        [settings setDayOfMonthFont:newFont];
    } else {
        // Fallback to system font if font not found
        NSFont *fallbackFont = [NSFont systemFontOfSize:[currentFont pointSize]];
        [settings setDayOfMonthFont:fallbackFont];
    }
}

- (void)fontSizeChanged:(id)sender {
    ClockSettings *settings = [ClockSettings sharedSettings];
    CGFloat fontSize = [[self.fontSizeField stringValue] doubleValue];
    if (fontSize > 0) {
        NSFont *currentFont = [settings dayOfMonthFont];
        NSFont *newFont = [NSFont fontWithName:[currentFont fontName] size:fontSize];
        if (newFont) {
            [settings setDayOfMonthFont:newFont];
        }
    }
}

- (void)fontSizeFieldChanged:(NSNotification *)notification {
    // Update when text changes (debounced)
    [self fontSizeChanged:self.fontSizeField];
}

- (void)positionChanged:(id)sender {
    ClockSettings *settings = [ClockSettings sharedSettings];
    CGFloat x = [[self.positionXField stringValue] doubleValue];
    CGFloat y = [[self.positionYField stringValue] doubleValue];
    [settings setDayOfMonthPosition:NSMakePoint(x, y)];
}

- (void)positionFieldChanged:(NSNotification *)notification {
    // Update when text changes (debounced)
    [self positionChanged:notification.object];
}

- (void)opacityChanged:(id)sender {
    ClockSettings *settings = [ClockSettings sharedSettings];
    CGFloat opacityPercent = [[self.opacityField stringValue] doubleValue];
    // Convert percentage to 0.0-1.0 range
    CGFloat opacity = MAX(0.0, MIN(100.0, opacityPercent)) / 100.0;
    [settings setWindowOpacity:opacity];
}

- (void)opacityFieldChanged:(NSNotification *)notification {
    // Update when text changes (debounced)
    [self opacityChanged:self.opacityField];
}

- (void)diameterChanged:(id)sender {
    ClockSettings *settings = [ClockSettings sharedSettings];
    CGFloat diameter = [[self.diameterField stringValue] doubleValue];
    if (diameter > 0) {
        [settings setWindowDiameter:diameter];
    }
}

- (void)diameterFieldChanged:(NSNotification *)notification {
    // Update when text changes (debounced)
    [self diameterChanged:self.diameterField];
}

- (void)clickThroughChanged:(id)sender {
    ClockSettings *settings = [ClockSettings sharedSettings];
    BOOL clickThrough = [self.clickThroughCheckbox state] == NSControlStateValueOn;
    [settings setClickThrough:clickThrough];
}

- (void)windowWillClose:(NSNotification *)notification {
    // Window is closing, nothing special needed
}

@end
