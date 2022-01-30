//
//  GibTV.h
//  GibTV
//
//  Created by Eric Rabil on 1/29/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class _TVRXDeviceQuery, _TVRXDevice, _TVRXKeyboardController, TVRCKeyboardAttributes, TVRCButton;

typedef NS_ENUM(NSInteger, TVRCDeviceDisconnectReason) {
    asdf
};

@interface TVRCPINEntryAttributes : NSObject
@property (nonatomic,readonly) unsigned long long totalDigitCount;
@property (nonatomic,readonly) unsigned long long numberOfDigitGroups;
-(instancetype)initWithDigitCount:(unsigned long long)arg1 ;
-(unsigned long long)numberOfDigitGroups;
-(unsigned long long)numberOfDigitsInGroup:(unsigned long long)arg1 ;
-(unsigned long long)totalDigitCount;
-(instancetype)initWithGroupLengths:(id)arg1 ;
@end

@interface RTIDataPayload : NSObject <NSSecureCoding> {
    NSData * _data;
    unsigned long long  _version;
}
@property (nonatomic, retain) NSData *data;
@property (nonatomic, readonly) unsigned long long version;
+ (instancetype)payloadWithData:(NSData*)arg1;
+ (instancetype)payloadWithData:(NSData*)arg1 version:(unsigned long long)arg2;
- (NSData*)data;
- (instancetype)initWithData:(NSData*)arg1 version:(unsigned long long)arg2;
- (void)setData:(NSData*)arg1;
- (unsigned long long)version;
@end

@interface TVRCKeyboardAttributes: NSObject
-(id)_init;
-(NSString *)title;
-(void)setTitle:(NSString *)arg1 ;
-(long long)_keyboardType;
-(NSString *)prompt;
-(void)setPrompt:(NSString *)arg1 ;
-(BOOL)_isSecure;
-(long long)_returnKeyType;
-(void)_setSecure:(BOOL)arg1 ;
-(long long)_autocorrectionType;
-(long long)_autocapitalizationType;
-(BOOL)_enablesReturnKeyAutomatically;
-(TVRCPINEntryAttributes *)PINEntryAttributes;
-(void)setPINEntryAttributes:(TVRCPINEntryAttributes *)arg1 ;
-(void)_setAutocorrectionType:(long long)arg1 ;
-(void)_setAutocapitalizationType:(long long)arg1 ;
-(void)_setEnablesReturnKeyAutomatically:(BOOL)arg1 ;
-(BOOL)isEqualToAttributes:(TVRCKeyboardAttributes*)arg1 ;
-(void)_setKeyboardType:(long long)arg1 ;
-(void)_setLikelyPINEntry:(BOOL)arg1 ;
-(RTIDataPayload *)rtiDataPayload;
-(void)setRtiDataPayload:(RTIDataPayload *)arg1 ;
-(BOOL)_isLikelyPINEntry;
-(void)_setReturnKeyType:(long long)arg1 ;
-(long long)_spellCheckingType;
-(void)_setSpellCheckingType:(long long)arg1 ;
@end

@protocol _TVRXKeyboardControllerDelegate
@optional
- (void)keyboardController:(_TVRXKeyboardController *)arg1 didUpdateAttributes:(TVRCKeyboardAttributes *)arg2;
- (void)keyboardController:(_TVRXKeyboardController *)arg1 didUpdateText:(NSString *)arg2;
- (void)keyboardControllerEndedTextEditing:(_TVRXKeyboardController *)arg1;
- (void)keyboardController:(_TVRXKeyboardController *)arg1 beganTextEditingWithAttributes:(TVRCKeyboardAttributes *)arg2;
@end

@protocol _TVRXKeyboardImpl
@optional
-(void)setTextActionPayload:(id)arg1;
@required
-(TVRCKeyboardAttributes*)attributes;
-(NSString*)text;
-(void)setText:(NSString*)arg1;
-(BOOL)isEditing;
-(void)setKeyboardController:(_TVRXKeyboardController*)arg1;
-(void)sendReturnKey;
@end

@interface _TVRXKeyboardController: NSObject
-(id<_TVRXKeyboardImpl>)impl;
-(void)_endSession;
-(void)setText:(NSString*)text;
-(instancetype)_init;
-(BOOL)isEditing;
-(id<_TVRXKeyboardControllerDelegate>)delegate;
-(void)setDelegate:(id<_TVRXKeyboardControllerDelegate>)delegate;
-(NSString*)text;
-(void)sendReturnKey;
@end

//@protocol _TVRXDeviceDelegate
//@optional
//-(void)deviceConnected:(_TVRXDevice*)device;
//// device:disconnectedForReason:error:
//-(void)device:(_TVRXDevice*)device disconnectedForReason:(TVRCDeviceDisconnectReason)reason error:(NSError*)error;
//@end

@interface _TVRXDeviceAuthenticationChallenge : NSObject {
    /*^block*/id _continuation;
    /*^block*/id _cancellationHandler;
    long long _challengeType;
    long long _challengeAttributes;
    long long _throttleSeconds;
    NSString* _codeToEnterOnDevice;
}

@property (nonatomic,readonly) long long challengeType;                          //@synthesize challengeType=_challengeType - In the implementation block
@property (assign,nonatomic) long long challengeAttributes;                      //@synthesize challengeAttributes=_challengeAttributes - In the implementation block
@property (assign,nonatomic) long long throttleSeconds;                          //@synthesize throttleSeconds=_throttleSeconds - In the implementation block
@property (nonatomic,copy,readonly) NSString * codeToEnterOnDevice;              //@synthesize codeToEnterOnDevice=_codeToEnterOnDevice - In the implementation block
+(instancetype)_challengeWithCodeToEnterOnDevice:(NSString*)arg1 cancellationHandler:(/*^block*/id)arg2 ;
+(instancetype)_challengeWithCodeToEnterLocally:(/*^block*/id)arg1 ;
-(instancetype)_init;
-(void)cancel;
-(void)userEnteredCodeLocally:(NSString*)arg1 ;
-(long long)challengeAttributes;
-(long long)throttleSeconds;
-(long long)challengeType;
-(NSString *)codeToEnterOnDevice;
-(void)setChallengeAttributes:(long long)arg1 ;
-(void)setThrottleSeconds:(long long)arg1 ;
@end


@protocol _TVRXDeviceDelegate <NSObject>

@optional
- (void)device:(_TVRXDevice *)arg1 updatedSupportedButtons:(NSSet<TVRCButton*> *)arg2;
- (void)deviceNameChanged:(_TVRXDevice *)arg1;
- (void)device:(_TVRXDevice *)arg1 disconnectedForReason:(long long)arg2 error:(NSError *)arg3;
- (void)deviceConnected:(_TVRXDevice *)arg1;
- (void)device:(_TVRXDevice *)arg1 encounteredAuthenticationChallenge:(_TVRXDeviceAuthenticationChallenge *)arg2;
- (_Bool)deviceShouldAllowConnectionAuthentication:(_TVRXDevice *)arg1;
- (void)deviceBeganConnecting:(_TVRXDevice *)arg1;
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
-(void)sendTouchEvent:(TVRCTouchEvent*)touchEvent;
-(nullable id<_TVRXDeviceDelegate>)delegate;
-(void)setDelegate:(nullable id<_TVRXDeviceDelegate>)delegate;
-(_TVRXKeyboardController*)keyboardController;
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
