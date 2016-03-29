//
//  CXTimer.m
//  shipxy01
//
//  Created by Chuanxun on 15/10/20.
//  Copyright © 2015年 shipxy. All rights reserved.
//

#import "CXTimer.h"

#define KIDENTIFIER @"identifier"
#define KTOTAL_TIMES @"total_times"
#define KDISPATCH_INTERVAL 1

@interface CXTimer ()

@property (nonatomic, strong) NSMutableDictionary *idToTimerDict;
@property (nonatomic, strong) NSMutableDictionary *idToRemainDict;
@property (nonatomic, strong) NSMutableDictionary *idToDelegateDict;
@end

@implementation CXTimer

+ (instancetype)sharedInstance
{
    static CXTimer *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[CXTimer alloc] init];
        }
    });
    return instance;
}

- (BOOL)addTimerWithIdentifier:(NSString *)identifier interval:(NSTimeInterval)interval  delegate:(id<CXTimerProtocol>)delegate
{
    if (interval < KDISPATCH_INTERVAL) {
        return NO;
    }
    
    NSTimer *timer = self.idToTimerDict[identifier];
    if (timer) {
        return NO;
    }
    
    NSDictionary *userInfo = @{KIDENTIFIER:identifier,KTOTAL_TIMES:[NSNumber numberWithDouble:interval]};
    timer = [NSTimer timerWithTimeInterval:KDISPATCH_INTERVAL target:self selector:@selector(dispatchTimer:) userInfo:userInfo repeats:YES];
    [self.idToTimerDict setObject:timer forKey:identifier];
    [self.idToRemainDict setObject:[NSNumber numberWithDouble:interval] forKey:identifier];
    [self.idToDelegateDict setObject:delegate forKey:identifier];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
    return YES;
}

- (void)dispatchTimer:(NSTimer *)timer
{
    NSString *identifier = timer.userInfo[KIDENTIFIER];
    NSNumber *totalTimes = timer.userInfo[KTOTAL_TIMES];
    id <CXTimerProtocol>delegate = self.idToDelegateDict[identifier];
    NSTimeInterval remainTime = [self.idToRemainDict[identifier] doubleValue] - KDISPATCH_INTERVAL;
    NSTimeInterval passTime = [totalTimes doubleValue] - remainTime;
    if (passTime >= [totalTimes doubleValue]) {
        [self.idToRemainDict removeObjectForKey:identifier];
        [self.idToTimerDict removeObjectForKey:identifier];
        [self.idToDelegateDict removeObjectForKey:identifier];
        [timer invalidate];
        if ([delegate respondsToSelector:@selector(cxtimerFired:)]) {
            [delegate cxtimerFired:self];
        }
    }else
    {
        [self.idToRemainDict setObject:[NSNumber numberWithDouble:remainTime] forKey:identifier];
        if ([delegate respondsToSelector:@selector(cxtimer:pass:remain:)]) {
            [delegate cxtimer:self pass:passTime remain:remainTime];
        }
    }
}

- (BOOL)hasTimerForIdentifier:(NSString *)identifier
{
    return [self.idToTimerDict objectForKey:identifier] != nil;
}

- (double)remainTimeForIdnetifier:(NSString *)identifier
{
    return [[self.idToRemainDict objectForKey:identifier] doubleValue];
}

-(void)changeDelegate:(id<CXTimerProtocol>)delegate forIdentifier:(NSString *)identifier
{
    if (self.idToDelegateDict[identifier] != nil) {
        self.idToDelegateDict[identifier] = delegate;
    }
}

#pragma mark - lazy load
-(NSDictionary *)idToTimerDict
{
    if (!_idToTimerDict) {
        _idToTimerDict = [[NSMutableDictionary alloc] init];
    }
    return _idToTimerDict;
}

-(NSMutableDictionary *)idToRemainDict
{
    if (!_idToRemainDict) {
        _idToRemainDict = [[NSMutableDictionary alloc] init];
    }
    return _idToRemainDict;
}

-(NSMutableDictionary *)idToDelegateDict
{
    if (!_idToDelegateDict) {
        _idToDelegateDict = [[NSMutableDictionary alloc] init];
    }
    return _idToDelegateDict;
}

@end
