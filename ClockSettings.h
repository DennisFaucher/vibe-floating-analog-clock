#ifndef CLOCKSETTINGS_H
#define CLOCKSETTINGS_H

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

// Notification name for settings changes
extern NSString *const ClockSettingsChangedNotification;

@interface ClockSettings : NSObject

+ (instancetype)sharedSettings;

// Clock face color
- (NSColor *)clockFaceColor;
- (void)setClockFaceColor:(NSColor *)color;

// Hour hand color
- (NSColor *)hourHandColor;
- (void)setHourHandColor:(NSColor *)color;

// Minute hand color
- (NSColor *)minuteHandColor;
- (void)setMinuteHandColor:(NSColor *)color;

// Day of month position
- (NSPoint)dayOfMonthPosition;
- (void)setDayOfMonthPosition:(NSPoint)position;

// Day of month font
- (NSFont *)dayOfMonthFont;
- (void)setDayOfMonthFont:(NSFont *)font;

// Window opacity (0.0 to 1.0, where 1.0 is fully opaque)
- (CGFloat)windowOpacity;
- (void)setWindowOpacity:(CGFloat)opacity;

// Window diameter in pixels
- (CGFloat)windowDiameter;
- (void)setWindowDiameter:(CGFloat)diameter;

// Click through (allow mouse events to pass through window)
- (BOOL)clickThrough;
- (void)setClickThrough:(BOOL)clickThrough;

// TZ Hand (timezone hand) color
- (NSColor *)tzHandColor;
- (void)setTzHandColor:(NSColor *)color;

// TZ Hand timezone identifier (e.g., "America/New_York", "Europe/London")
- (NSString *)tzHandTimezone;
- (void)setTzHandTimezone:(NSString *)timezoneIdentifier;

// Saved window position
- (BOOL)hasSavedWindowPosition;
- (NSPoint)windowOrigin;
- (void)setWindowOrigin:(NSPoint)origin;

// Always on top
- (BOOL)alwaysOnTop;
- (void)setAlwaysOnTop:(BOOL)alwaysOnTop;

// Notify observers of changes
- (void)notifySettingsChanged;

@end

#endif // CLOCKSETTINGS_H
