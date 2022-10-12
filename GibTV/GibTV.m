//
//  GibTV.m
//  GibTV
//
//  Created by Eric Rabil on 1/29/22.
//

#import <Foundation/Foundation.h>

__attribute__((weak_import)) @interface RPCompanionLinkClient: NSObject
@end

asm(".weak_reference _OBJC_CLASS_$_RPCompanionLinkClient");

@implementation RPCompanionLinkClient (tvrc_setAllowedTVs)
-(void)tvrc_setAllowedTVs {
    NSLog(@"");
}
@end

@interface TVRXDeviceQuery: NSObject
@end

@implementation TVRXDeviceQuery (copyWithZone)
-(instancetype)copyWithZone:(NSZone*)zone {
    return self;
}
@end
