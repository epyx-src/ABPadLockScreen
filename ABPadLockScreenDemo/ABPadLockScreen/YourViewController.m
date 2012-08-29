//
//  YourViewController.m
//  ABPadLockScreen
//
//  Created by Aron Bury on 9/09/11.
//  Copyright 2011 Aron's IT Consultancy. All rights reserved.
//

#import "YourViewController.h"

@implementation YourViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
                               | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
                               | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

    UIButton *showPinUnlockButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    showPinUnlockButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
                                         | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    showPinUnlockButton.frame = CGRectMake(300.0f, 330.0f, 168.0f, 50.0f);
    [showPinUnlockButton setTitle:@"Show PIN unlock" forState:UIControlStateNormal];
    [showPinUnlockButton addTarget:self action:@selector(showPinUnlock) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showPinUnlockButton];

    UIButton *showPinSetButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    showPinSetButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
                                      | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    showPinSetButton.frame = CGRectMake(300.0f, 400.0f, 168.0f, 50.0f);
    [showPinSetButton setTitle:@"Show PIN set" forState:UIControlStateNormal];
    [showPinSetButton addTarget:self action:@selector(showPinSet) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showPinSetButton];

    UIButton *showPinChangeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    showPinChangeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
                                         | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    showPinChangeButton.frame = CGRectMake(300.0f, 470.0f, 168.0f, 50.0f);
    [showPinChangeButton setTitle:@"Show PIN change" forState:UIControlStateNormal];
    [showPinChangeButton addTarget:self action:@selector(showPinChange) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showPinChangeButton];

    UIButton *showOtpButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    showOtpButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
                                   | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    showOtpButton.frame = CGRectMake(300.0f, 540.0f, 168.0f, 50.0f);
    [showOtpButton setTitle:@"Show OTP" forState:UIControlStateNormal];
    [showOtpButton addTarget:self action:@selector(showOtp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showOtpButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if UIInterfaceOrientationIsLandscape(fromInterfaceOrientation) {
        self.view.frame = CGRectMake(0, 0, 768, 1024);
    }
    else if UIInterfaceOrientationIsPortrait(fromInterfaceOrientation) {
        self.view.frame = CGRectMake(0, 0, 1024, 768);
    }
}

#pragma mark - private methods

- (void)showPinUnlock
{
    [self showPin:PinModeUnlock];
}

- (void)showPinSet
{
    [self showPin:PinModeSet];
}

- (void)showPinChange
{
    [self showPin:PinModeChange];
}

- (void)showPin:(PinMode)pinMode
{
    //Create the ABLockScreen (Alloc init) and display how you wish. An easy way is by using it as a modal view as per below:
    ABPadLockScreen *lockScreen = [[ABPadLockScreen alloc] initWithMode:pinMode withDelegate:self withDataSource:self];
    float centerLeft = self.view.frame.size.width/2.0f - lockScreen.view.frame.size.width/2.0f;
    float centerTop =  self.view.frame.size.height/2.0f - lockScreen.view.frame.size.height/2.0f;
    [lockScreen setModalPresentationStyle:UIModalPresentationFormSheet];
    [lockScreen setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentModalViewController:lockScreen animated:YES];
    lockScreen.view.superview.frame = CGRectMake(centerLeft, centerTop, 332.0f, 465.0f);
}

- (void)showOtp
{
    //Create the ABLockScreen (Alloc init) and display how you wish. An easy way is by using it as a modal view as per below:
    ABOTPPadLockScreen *lockScreen = [[ABOTPPadLockScreen alloc] initWithDelegate:self withDataSource:self];
    float centerLeft = self.view.frame.size.width/2.0f - lockScreen.view.frame.size.width/2.0f;
    float centerTop =  self.view.frame.size.height/2.0f - lockScreen.view.frame.size.height/2.0f;
    [lockScreen setModalPresentationStyle:UIModalPresentationFormSheet];
    [lockScreen setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentModalViewController:lockScreen animated:YES];
    lockScreen.view.superview.frame = CGRectMake(centerLeft, centerTop, 332.0f, 465.0f);
}

#pragma mark - ABPadLockScreen Delegate methods

- (void)pinEntryWasSuccessful:(int)pin forMode:(PinMode)mode
{
    //Perform any action needed when the unlock was successfull (usually remove the lock view and then load another view)
    [self dismissModalViewControllerAnimated:YES];
}

- (void)pinUnlockWasUnsuccessful:(int)falseEntryCode afterAttemptNumber:(int)attemptNumber
{
    //Tells you that the user performed an unsuccessfull unlock and tells you the incorrect code and the attempt number. ABLockScreen will display an error if you have
    //set an attempt limit through the datasource method, but you may wish to make a record of the failed attempt.
}

- (void)pinUnlockWasCancelled
{
    //This is a good place to remove the ABLockScreen
    [self dismissModalViewControllerAnimated:YES];
}

- (void)pinAttemptsExpired
{
    // If you want to perform any action when the user has failed all their attempts, do so here.
    // ABLockPad will automatically lock them from entering in any more pins.
}

- (void)pinSetWasUnsuccessful:(int)pinOne pinTwo:(int)pinTwo
{
}

#pragma mark - ABPadLockScreen DataSource methods

- (BOOL)checkPasscode:(int)passcode
{
    if ( passcode == 1234 ) {
        return YES;
    }
    return NO;
}

- (NSString *)pinPadLockScreenTitleTextForMode:(PinMode)mode state:(PinState)state
{
    //Provide the text for the lock screen title here
    if ( mode == PinModeSet ) {
        return @"Set your PIN";
    }
    else if ( mode == PinModeChange ) {
        return @"Change your PIN";
    }
    return @"Enter PIN";
}

- (NSString *)pinPadLockScreenSubtitleTextForMode:(PinMode)mode state:(PinState)state
{
    //Provide the text for the lock screen subtitle here
    if ( mode == PinModeSet ) {
        if ( state == PinStateConfirm ) {
            return @"Please re-enter your PIN";
        }
        else {
            return @"Please enter your PIN";
        }
    }
    else if ( mode == PinModeChange ) {
        if ( state == PinStateCheck ) {
            return @"Please enter your old PIN";
        }
        else if ( state == PinStateConfirm ) {
            return @"Please re-enter your new PIN";
        }
        else {
            return @"Please enter your new PIN";
        }
    }
    return @"Please enter your PIN";
}

- (BOOL)pinHasAttemptLimit
{
    //If the lock screen only allows a limited number of attempts, return YES. Otherwise, return NO
    return YES;
}

- (int)pinAttemptLimit
{
    //If the lock screen only allows a limited number of attempts, return the number of allowed attempts here You must return higher than 0 (Recomended more than 1).
    return 3;
}

#pragma mark - ABOTPPadLockScreen Delegate methods

- (void)otpUnlockWasSuccessful
{
    //Perform any action needed when the unlock was successfull (usually remove the lock view and then load another view)
    [self dismissModalViewControllerAnimated:YES];
}

- (void)otpUnlockWasUnsuccessful:(int)falseEntryCode afterAttemptNumber:(int)attemptNumber
{
    //Tells you that the user performed an unsuccessfull unlock and tells you the incorrect code and the attempt number. ABLockScreen will display an error if you have
    //set an attempt limit through the datasource method, but you may wish to make a record of the failed attempt.
}

- (void)otpUnlockWasCancelled
{
    //This is a good place to remove the ABLockScreen
    [self dismissModalViewControllerAnimated:YES];
}

- (void)otpPinAttemptsExpired
{
    // If you want to perform any action when the user has failed all their attempts, do so here.
    // ABLockPad will automatically lock them from entering in any more pins.
}

#pragma mark - ABOTPPadLockScreen DataSource methods

- (BOOL)checkOtp:(int)passcode
{
    if ( passcode == 123456 ) {
        return YES;
    }
    return NO;
}

- (NSString *)otpPadLockScreenTitleText
{
    //Provide the text for the lock screen title here
    return @"Enter OTP";
}

- (NSString *)otpPadLockScreenSubtitleText
{
    //Provide the text for the lock screen subtitle here
    return @"Please enter your one time password";
}

- (BOOL)otpHasAttemptLimit
{
    //If the lock screen only allows a limited number of attempts, return YES. Otherwise, return NO
    return NO;
}

- (int)otpAttemptLimit
{
    //If the lock screen only allows a limited number of attempts, return the number of allowed attempts here You must return higher than 0 (Recomended more than 1).
    return 3;
}

@end
