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

    UIButton *showPinButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [showPinButton setFrame:CGRectMake(300.0f, 400.0f, 168.0f, 50.0f)];
    [showPinButton setTitle:@"Show PIN" forState:UIControlStateNormal];
    [showPinButton addTarget:self action:@selector(showPin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showPinButton];

    UIButton *showOtpButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [showOtpButton setFrame:CGRectMake(300.0f, 470.0f, 168.0f, 50.0f)];
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
        [self.view setFrame:CGRectMake(0, 0, 768, 1024)]; 
    }
    else if UIInterfaceOrientationIsPortrait(fromInterfaceOrientation) {
        [self.view setFrame:CGRectMake(0, 0, 1024, 768)]; 
    }
}

#pragma mark - private methods

- (void)showPin
{
    //Create the ABLockScreen (Alloc init) and display how you wish. An easy way is by using it as a modal view as per below:
    ABPadLockScreen *lockScreen = [[ABPadLockScreen alloc] initWithDelegate:self withDataSource:self];
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

- (void)pinUnlockWasSuccessful
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
    //If you want to perform any action when the user has failed all their attempts, do so here. ABLockPad will automatically lock them from entering in any more
    //pins.
}

#pragma mark - ABPadLockScreen DataSource methods

- (int)pinUnlockPasscode
{
    //Provide the ABLockScreen with a code to verify against
    return 1234;
}

- (NSString *)pinPadLockScreenTitleText
{
    //Provide the text for the lock screen title here
    return @"Enter passcode";
    
}

- (NSString *)pinPadLockScreenSubtitleText
{
    //Provide the text for the lock screen subtitle here
    return @"Please enter passcode";
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
    //If you want to perform any action when the user has failed all their attempts, do so here. ABLockPad will automatically lock them from entering in any more
    //pins.
}

#pragma mark - ABOTPPadLockScreen DataSource methods

- (int)otpUnlockPasscode
{
    //Provide the ABLockScreen with a code to verify against
    return 123456;
}

- (NSString *)otpPadLockScreenTitleText
{
    //Provide the text for the lock screen title here
    return @"Enter OTP";
    
}

- (NSString *)otpPadLockScreenSubtitleText
{
    //Provide the text for the lock screen subtitle here
    return @"Please enter yoiur one time password";
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
