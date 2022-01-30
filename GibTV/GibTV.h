//
//  GibTV.h
//  GibTV
//
//  Created by Eric Rabil on 1/29/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class _TVRXDeviceQuery, _TVRXDevice;

typedef NS_ENUM(NSInteger, TVRCDeviceDisconnectReason) {
    asdf
};

@protocol _TVRXDeviceDelegate
@optional
-(void)deviceConnected:(_TVRXDevice*)device;
// device:disconnectedForReason:error:
-(void)device:(_TVRXDevice*)device disconnectedForReason:(TVRCDeviceDisconnectReason)reason error:(NSError*)error;
@end

typedef NS_ENUM(NSInteger, TVRCButtonEventType) {
    TVRCButtonEventTypeTapped = 0,
    TVRCButtonEventTypePressed = 1,
    TVRCButtonEventTypeReleased = 2,
    TVRCButtonEventTypeButtonDown = 3
};

typedef NS_ENUM(NSInteger, TVRCButtonType) {
    TVRCButtonTypeSelect = 1,
    TVRCButtonTypeMenu = 2,
    TVRCButtonTypeHome = 3,
    TVRCButtonTypeSiri = 4,
    TVRCButtonTypePlayPause = 5,
    TVRCButtonTypeVolumeUp = 10,
    TVRCButtonTypeVolumeDown = 11,
    TVRCButtonTypeArrowUp = 12,
    TVRCButtonTypeArrowDown = 13,
    TVRCButtonTypeArrowLeft = 14,
    TVRCButtonTypeArrowRight = 15,
    TVRCButtonTypeCaptionsToggle = 16,
    TVRCButtonTypeActivateScreenSaver = 19,
    TVRCButtonTypeLaunchApplication = 20,
    TVRCButtonTypeWake = 21,
    TVRCButtonTypeSleep = 22,
    TVRCButtonTypePageUp = 26,
    TVRCButtonTypePageDown = 27,
    TVRCButtonTypeGuide = 28,
    TVRCButtonTypeMute = 29,
    TVRCButtonTypePower = 30
};

NSString* TVRCButtonTypeDescription(TVRCButtonType);

@interface TVRCButton: NSObject
-(BOOL)isEnabled;
-(BOOL)hasTapAction;
-(NSDictionary*)properties;
-(TVRCButtonType)buttonType;
@end

@interface TVRCButtonEvent: NSObject
+(instancetype)buttonEventForButton:(TVRCButton*)button eventType:(TVRCButtonEventType)eventType;
-(TVRCButton*)button;
-(TVRCButtonEventType)eventType;
@end

@interface TVRCTouchEvent: NSObject
// -(int)_initWithTimestamp:(int)arg2 finger:(int)arg3 phase:(id)arg4 digitizerLocation:(id)arg5
-(instancetype)_initWithTimestamp:(double)timestamp finger:(long long)finger phase:(long long)phase digitizerLocation:(CGPoint)digitizerLocation;
-(long long)phase;
-(long long)finger;
-(CGPoint)digitizerLocation;
-(double)timestamp;
@end

@interface _TVRXDevice: NSObject
-(BOOL)paired;
-(void)connect;
-(void)disconnect;
-(NSString*)name;
-(NSString*)model;
-(NSString*)identifier;
-(int)connectionState;
-(NSSet<TVRCButton*>*)supportedButtons;
-(void)sendButtonEvent:(TVRCButtonEvent*)buttonEvent;
-(nullable id<_TVRXDeviceDelegate>)delegate;
-(void)setDelegate:(nullable id<_TVRXDeviceDelegate>)delegate;
@end

@protocol _TVRXDeviceQueryDelegate
@optional
-(void)deviceQueryDidUpdateDevices:(_TVRXDeviceQuery*)query;
@end

__attribute__((weak_import)) @interface RPCompanionLinkClient: NSObject
@end

@interface _TVRCFeatures: NSObject
+(BOOL)rapportEnabled;
@end

@interface _TVRXDeviceQuery: NSObject
//+(NSArray<TVRCDevice*>*)_allDiscoveredDevices;
-(NSSet<_TVRXDevice*>*)devices;
-(void)start;
-(void)stop;
-(nullable id<_TVRXDeviceQueryDelegate>)delegate;
-(void)setDelegate:(nullable id<_TVRXDeviceQueryDelegate>)delegate;
@end

@interface _TVRCMatchPointDeviceQuery: NSObject
-(void)start;
-(void)stop;
@end

NS_ASSUME_NONNULL_END
