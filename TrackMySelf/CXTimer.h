//
//  CXTimer.h
//  shipxy01
//
//  Created by Chuanxun on 15/10/20.
//  Copyright © 2015年 shipxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CXTimer;

@protocol CXTimerProtocol <NSObject>

- (void)cxtimer:(CXTimer *)timer pass:(NSTimeInterval)passedTime remain:(NSTimeInterval)remainTime;
- (void)cxtimerFired:(CXTimer *)timer;

@end

@interface CXTimer : NSObject

@property (nonatomic, weak) id<CXTimerProtocol>delegate;

+ (instancetype)sharedInstance;

- (BOOL)addTimerWithIdentifier:(NSString *)identifier interval:(NSTimeInterval)interval delegate:(id<CXTimerProtocol>)delegate;

- (BOOL)hasTimerForIdentifier:(NSString *)identifier;
- (double)remainTimeForIdnetifier:(NSString *)identifier;
- (void)changeDelegate:(id<CXTimerProtocol>)delegate forIdentifier:(NSString *)identifier;
@end
