//
//  SBRemindarAccessCheck.m
//  SBCal
//
//  Created by kenjou yutaka on 2014/06/04.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "SBRemindarAccessCheck.h"

@implementation SBRemindarAccessCheck

-(void)RemindarAccessCheck
{
    SBEventManager *eventMg = [SBEventManager sharedInstance];
    
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    
    switch (status) {
        case EKAuthorizationStatusNotDetermined:
        {
            [eventMg.sharedEventKitStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error){
                if (granted) {
                    BOOL remindarAceess = YES;
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                       [[[UIAlertView alloc] initWithTitle:@"リマインダーの確認"
                                                   message:@"このアプリのリマインダーへのアクセスを許可するには「設定」→「プライバシー」から設定する必要があります。"
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil]
                         show];
                    });
                }
            }];
             break;
        }
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
            [self notifyEvent];
             break;
        case EKAuthorizationStatusAuthorized:
        {
            
        }
            
        default:
            break;
    }
}

-(void)notifyEvent
{
    UIAlertView *notify = [[UIAlertView alloc] initWithTitle:@"リマインダーへのアクセスを許可してください"
                                                     message:@"リマインダーにアクセスできません。「設定」アプリの「プライバシー」→「リマインダー」の項目で「LisCal」のカレンダーへのアクセスを許可してください。\n許可されない場合にはアプリの機能が使用できません。"
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [notify show];
}

@end
