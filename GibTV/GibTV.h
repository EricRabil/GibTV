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

@protocol RTIInputSystemSessionDelegate
@end

@interface TIKeyboardIntermediateText: NSObject
@end

@interface TIKeyboardOutput: NSObject
@property (nonatomic, copy) NSString *textToCommit;
- (void)insertText:(NSString *)insertionText;
- (void)deleteBackward:(NSUInteger)deletionCount;
- (void)deleteBackward;
- (void)insertTextAfterSelection:(NSString *)insertionText;
- (void)deleteForward:(NSUInteger)deletionCount;
- (void)deleteForward;
@end

@interface TIDocumentState: NSObject
@property (nonatomic, readonly) NSString *contextBeforeInput; // [contextRange.begin, inputRange.begin]
@property (nonatomic, readonly) NSString *markedText;         // [markedTextRange.begin, markedTextRange.end]
@property (nonatomic, readonly) NSString *selectedText;       // [selectedTextRange.begin, selectedTextRange.end]
@property (nonatomic, readonly) NSString *contextAfterInput;  // [inputRange.end, contextRange.end]
@end

@interface TITextInputTraits: NSObject
@end

@interface RTIDocumentState : NSObject <NSSecureCoding, NSCopying> {
    TIDocumentState* _documentState;
    NSAttributedString* _textCheckingAnnotatedString;
    NSMutableDictionary* __selectionRects;
    CGRect _caretRectInWindow;
    CGRect _firstSelectionRectInWindow;
}
@property (nonatomic,retain) NSMutableDictionary * _selectionRects;                       //@synthesize _selectionRects=__selectionRects - In the implementation block
@property (nonatomic,retain) TIDocumentState * documentState;                             //@synthesize documentState=_documentState - In the implementation block
@property (assign,nonatomic) CGRect caretRectInWindow;                                    //@synthesize caretRectInWindow=_caretRectInWindow - In the implementation block
@property (assign,nonatomic) CGRect firstSelectionRectInWindow;                           //@synthesize firstSelectionRectInWindow=_firstSelectionRectInWindow - In the implementation block
@property (assign,nonatomic) NSRange selectedTextRange;
@property (nonatomic,readonly) NSRange markedTextRange;
@property (nonatomic,copy) NSAttributedString * textCheckingAnnotatedString;              //@synthesize textCheckingAnnotatedString=_textCheckingAnnotatedString - In the implementation block
+(BOOL)supportsSecureCoding;
-(void)setSelectedTextRange:(NSRange)arg1 ;
-(id)init;
-(TIDocumentState *)documentState;
-(NSRange)markedTextRange;
-(NSRange)selectedTextRange;
-(id)initWithCoder:(id)arg1 ;
-(void)encodeWithCoder:(id)arg1 ;
-(NSRange)deltaForSelectionRange:(NSRange)arg1 ;
-(void)resetTextRects;
-(NSMutableDictionary *)_selectionRects;
-(void)set_selectionRects:(NSMutableDictionary *)arg1 ;
-(void)addTextRect:(CGRect)arg1 forCharacterRange:(NSRange)arg2 ;
-(BOOL)isEqual:(id)arg1 ;
-(void)setDocumentState:(TIDocumentState *)arg1 ;
-(id)description;
-(id)copyWithZone:(NSZone*)arg1 ;
-(unsigned long long)characterIndexForPoint:(CGPoint)arg1 ;
-(CGRect)firstRectForCharacterRange:(NSRange)arg1 ;
-(CGRect)caretRectInWindow;
-(CGRect)firstSelectionRectInWindow;
-(NSAttributedString *)textCheckingAnnotatedString;
-(void)setCaretRectInWindow:(CGRect)arg1 ;
-(void)setFirstSelectionRectInWindow:(CGRect)arg1 ;
-(void)setTextCheckingAnnotatedString:(NSAttributedString *)arg1 ;
@end

@interface RTIDocumentTraits : NSObject <NSCopying, NSSecureCoding> {
    
    NSString* _appId;
    NSString* _bundleId;
    NSString* _appName;
    NSString* _localizedAppName;
    NSArray* _associatedDomains;
    NSString* _title;
    NSString* _prompt;
    TITextInputTraits* _textInputTraits;
    NSIndexSet* _PINEntrySeparatorIndexes;
    unsigned long long _autofillMode;
    NSDictionary* _autofillContext;
    NSRange _validTextRange;
}
@property (nonatomic,copy) NSString * appId;                                     //@synthesize appId=_appId - In the implementation block
@property (nonatomic,copy) NSString * bundleId;                                  //@synthesize bundleId=_bundleId - In the implementation block
@property (nonatomic,copy) NSString * appName;                                   //@synthesize appName=_appName - In the implementation block
@property (nonatomic,copy) NSString * localizedAppName;                          //@synthesize localizedAppName=_localizedAppName - In the implementation block
@property (nonatomic,retain) NSArray * associatedDomains;                        //@synthesize associatedDomains=_associatedDomains - In the implementation block
@property (nonatomic,copy) NSString * title;                                     //@synthesize title=_title - In the implementation block
@property (nonatomic,copy) NSString * prompt;                                    //@synthesize prompt=_prompt - In the implementation block
@property (nonatomic,retain) TITextInputTraits * textInputTraits;                //@synthesize textInputTraits=_textInputTraits - In the implementation block
@property (nonatomic,retain) NSIndexSet * PINEntrySeparatorIndexes;              //@synthesize PINEntrySeparatorIndexes=_PINEntrySeparatorIndexes - In the implementation block
@property (assign,nonatomic) NSRange validTextRange;                             //@synthesize validTextRange=_validTextRange - In the implementation block
@property (assign,nonatomic) unsigned long long autofillMode;                    //@synthesize autofillMode=_autofillMode - In the implementation block
@property (nonatomic,retain) NSDictionary * autofillContext;                     //@synthesize autofillContext=_autofillContext - In the implementation block
+(BOOL)supportsSecureCoding;
-(void)setPrompt:(NSString *)arg1 ;
-(TITextInputTraits *)textInputTraits;
-(void)setAutofillMode:(unsigned long long)arg1 ;
-(NSString *)appId;
-(id)init;
-(void)setBundleId:(NSString *)arg1 ;
-(void)setPINEntrySeparatorIndexes:(NSIndexSet *)arg1 ;
-(id)initWithCoder:(id)arg1 ;
-(void)setAutofillContext:(NSDictionary *)arg1 ;
-(NSString *)localizedAppName;
-(void)encodeWithCoder:(id)arg1 ;
-(NSArray *)associatedDomains;
-(NSDictionary *)autofillContext;
-(NSString *)bundleId;
-(void)setValidTextRange:(NSRange)arg1 ;
-(void)setAppName:(NSString *)arg1 ;
-(BOOL)isEqual:(id)arg1 ;
-(NSString *)prompt;
-(void)setAssociatedDomains:(NSArray *)arg1 ;
-(NSRange)validTextRange;
-(id)description;
-(NSString *)title;
-(void)setTextInputTraits:(TITextInputTraits *)arg1 ;
-(void)setAppId:(NSString *)arg1 ;
-(void)setTitle:(NSString *)arg1 ;
-(NSIndexSet *)PINEntrySeparatorIndexes;
-(unsigned long long)autofillMode;
-(NSString *)appName;
-(void)setLocalizedAppName:(NSString *)arg1 ;
-(id)copyWithZone:(NSZone*)arg1 ;
-(void)copyContextualPropertiesFromDocumentTraits:(id)arg1 ;
@end


@interface RTIStyledIntermediateText: NSObject
@end

@interface RTITextOperations : NSObject
@property (nonatomic,retain) NSDictionary * attributedPlaceholders;                              //@synthesize attributedPlaceholders=_attributedPlaceholders - In the implementation block
@property (nonatomic,readonly) NSMutableDictionary * mutableAttributedPlaceholders;
@property (nonatomic,readonly) TIKeyboardOutput * keyboardOutput;                                //@synthesize keyboardOutput=_keyboardOutput - In the implementation block
@property (nonatomic,retain) TIKeyboardIntermediateText * intermediateText;                      //@synthesize intermediateText=_intermediateText - In the implementation block
@property (nonatomic,retain) RTIStyledIntermediateText * styledIntermediateText;                 //@synthesize styledIntermediateText=_styledIntermediateText - In the implementation block
@property (nonatomic,copy) NSString * textToAssert;                                              //@synthesize textToAssert=_textToAssert - In the implementation block
@property (assign,nonatomic) NSRange selectionRangeToAssert;                                     //@synthesize selectionRangeToAssert=_selectionRangeToAssert - In the implementation block
@property (assign,nonatomic) SEL editingActionSelector;                                          //@synthesize editingActionSelector=_editingActionSelector - In the implementation block
@property (nonatomic,readonly) NSAttributedString * attributedInsertionText;
@property (assign,nonatomic) NSRange textCheckingAnnotationRange;                                //@synthesize textCheckingAnnotationRange=_textCheckingAnnotationRange - In the implementation block
@property (assign,nonatomic) NSRange textCheckingReplacementRange;                               //@synthesize textCheckingReplacementRange=_textCheckingReplacementRange - In the implementation block
@property (nonatomic,copy) NSAttributedString * textCheckingAnnotatedString;                     //@synthesize textCheckingAnnotatedString=_textCheckingAnnotatedString - In the implementation block
@property (assign,nonatomic) NSRange textCheckingAnnotationRemovalRange;                         //@synthesize textCheckingAnnotationRemovalRange=_textCheckingAnnotationRemovalRange - In the implementation block
@property (nonatomic,copy) NSString * textCheckingAnnotationToRemove;                            //@synthesize textCheckingAnnotationToRemove=_textCheckingAnnotationToRemove - In the implementation block
-(void)insertAttributedText:(id)arg1 ;
-(void)setIntermediateText:(TIKeyboardIntermediateText *)arg1 ;
-(NSString *)textToAssert;
-(NSRange)selectionRangeToAssert;
-(SEL)editingActionSelector;
-(TIKeyboardOutput *)keyboardOutput;
-(void)setTextToAssert:(NSString *)arg1 ;
-(void)setSelectionRangeToAssert:(NSRange)arg1 ;
-(TIKeyboardIntermediateText *)intermediateText;
-(NSAttributedString *)textCheckingAnnotatedString;
-(void)setTextCheckingAnnotatedString:(NSAttributedString *)arg1 ;
-(RTIStyledIntermediateText *)styledIntermediateText;
-(NSRange)textCheckingAnnotationRange;
-(NSRange)textCheckingReplacementRange;
-(NSRange)textCheckingAnnotationRemovalRange;
-(NSString *)textCheckingAnnotationToRemove;
-(void)_createAttributedPlaceholdersIfNecessary;
-(NSMutableDictionary *)mutableAttributedPlaceholders;
-(void)insertText:(id)arg1 replacementRange:(NSRange)arg2 ;
-(void)insertAttributedText:(id)arg1 replacementRange:(NSRange)arg2 ;
-(NSAttributedString *)attributedInsertionText;
-(void)setStyledIntermediateText:(RTIStyledIntermediateText *)arg1 ;
-(NSDictionary *)attributedPlaceholders;
-(void)setAttributedPlaceholders:(NSDictionary *)arg1 ;
-(void)setEditingActionSelector:(SEL)arg1 ;
-(void)setTextCheckingAnnotationRange:(NSRange)arg1 ;
-(void)setTextCheckingReplacementRange:(NSRange)arg1 ;
-(void)setTextCheckingAnnotationRemovalRange:(NSRange)arg1 ;
-(void)setTextCheckingAnnotationToRemove:(NSString *)arg1 ;
@end

@interface RTIInputSystemSession : NSObject
@property (nonatomic,retain) NSHashTable * extraSessionDelegates;                                   //@synthesize extraSessionDelegates=_extraSessionDelegates - In the implementation block
@property (nonatomic,retain) NSUUID * uuid;                                                         //@synthesize uuid=_uuid - In the implementation block
@property (nonatomic,retain) RTIDocumentTraits * documentTraits;                                    //@synthesize documentTraits=_documentTraits - In the implementation block
@property (nonatomic,retain) RTIDocumentState * documentState;                                      //@synthesize documentState=_documentState - In the implementation block
@property (nonatomic,retain) RTITextOperations * textOperations;                                    //@synthesize textOperations=_textOperations - In the implementation block
@property (nonatomic,readonly) RTITextOperations * _textOperations;
@property (assign,nonatomic) id<RTIInputSystemSessionDelegate> sessionDelegate;              //@synthesize sessionDelegate=_sessionDelegate - In the implementation block
-(RTIDocumentState *)documentState;
-(NSUUID *)uuid;
-(void)setTextOperations:(RTITextOperations *)arg1 ;
-(void)addSessionDelegate:(id)arg1 ;
-(RTIDocumentTraits *)documentTraits;
-(RTITextOperations *)textOperations;
-(void)setSessionDelegate:(id<RTIInputSystemSessionDelegate>)arg1 ;
-(void)setDocumentState:(RTIDocumentState *)arg1 ;
-(void)setUuid:(NSUUID *)arg1 ;
-(void)flushOperations;
-(id<RTIInputSystemSessionDelegate>)sessionDelegate;
-(void)_applyLocalTextOperations:(id)arg1 toDocumentState:(id)arg2 ;
-(void)setDocumentTraits:(RTIDocumentTraits *)arg1 ;
-(RTITextOperations *)_textOperations;
-(void)enumerateSessionDelegatesUsingBlock:(/*^block*/id)arg1 ;
-(void)_createTextOperationsIfNecessary;
-(void)applyLocalTextOperations:(id)arg1 toDocumentState:(id)arg2 ;
-(void)removeSessionDelegate:(id)arg1 ;
-(NSHashTable *)extraSessionDelegates;
-(void)setExtraSessionDelegates:(NSHashTable *)arg1 ;
@end


@interface RTIInputSystemSourceSession: RTIInputSystemSession
@end

@protocol _TVRXKeyboardImpl
@optional
-(void)setTextActionPayload:(id)arg1;
@required
-(TVRCKeyboardAttributes*)attributes;
-(NSString*)text;
-(void)setText:(NSString*)arg1;
-(RTIInputSystemSourceSession*)currentSession;
//-(void)setTextActionPayload:(RTIDataPayload*)arg1;
-(BOOL)isEditing;
-(void)setKeyboardController:(_TVRXKeyboardController*)arg1;
-(void)sendReturnKey;
@end

@interface _TVRXKeyboardController: NSObject
-(void)_endSession;
-(void)setText:(NSString*)text;
-(instancetype)_init;
-(BOOL)isEditing;
-(id<_TVRXKeyboardControllerDelegate>)delegate;
-(void)sendTextActionPayload:(id)arg1 ;
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
