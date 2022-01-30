//
//  GibTV.m
//  GibTV
//
//  Created by Eric Rabil on 1/29/22.
//

#import <Foundation/Foundation.h>
#import "GibTV.h"

asm(".weak_reference _OBJC_CLASS_$_RPCompanionLinkClient");

@implementation RPCompanionLinkClient (tvrc_setAllowedTVs)
-(void)tvrc_setAllowedTVs {
    NSLog(@"");
}
@end

@implementation _TVRXDeviceQuery (copyWithZone)
-(instancetype)copyWithZone:(NSZone*)zone {
    return self;
}
@end
