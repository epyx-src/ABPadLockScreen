//
//  ABOTPPadLockScreen.h
//
//  Version 1.2
//
//  Created by Aron Bury on 09/09/2011.
//  Copyright 2011 Aron Bury. All rights reserved.
//
//  Get the latest version of ABLockScreen from this location:
//  https://github.com/abury/ABPadLockScreen
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import <UIKit/UIKit.h>

@protocol ABOTPPadLockScreenDelegate

@required
- (void)otpUnlockWasSuccessful;
- (void)otpUnlockWasUnsuccessful:(int)falseEntryCode afterAttemptNumber:(int)attemptNumber;
- (void)otpUnlockWasCancelled;

@optional
- (void)otpAttemptsExpired;

@end

@protocol ABOTPPadLockScreenDataSource

@required
- (int)otpUnlockPasscode;
- (NSString *)otpPadLockScreenTitleText;
- (NSString *)otpPadLockScreenSubtitleText;
- (BOOL)otpHasAttemptLimit;

@optional
- (int)otpAttemptLimit;

@end

@interface ABOTPPadLockScreen : UIViewController

@property (nonatomic, unsafe_unretained) id<ABOTPPadLockScreenDelegate> delegate;
@property (nonatomic, unsafe_unretained) id<ABOTPPadLockScreenDataSource> dataSource;

- (id)initWithDelegate:(id<ABOTPPadLockScreenDelegate>)aDelegate
        withDataSource:(id<ABOTPPadLockScreenDataSource>)aDataSource;
- (void)resetAttempts;
- (void)resetLockScreen;

@end
