//
//  ABOTPPadLockScreen.m
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

#import "ABOTPPadLockScreen.h"

#define KEY_VALUE_WIDTH 16
#define KEY_VALUE_MARGIN 25

#define MAX_PIN_LENGTH 9

@interface ABOTPPadLockScreen()

@property (nonatomic, strong) UIImageView *incorrectAttemptImageView;

@property (nonatomic, strong) UILabel *incorrectAttemptLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;

@property (nonatomic, strong) UILabel *pinCodeLabel;

@property (nonatomic) int attempts;

- (void)cancelButtonTapped:(id)sender;
- (void)digitButtonPressed:(id)sender;
- (void)backSpaceButtonTapped:(id)sender;
- (void)digitInputted:(int)digit;
- (void)checkPin;
- (void)lockPad;
- (UIButton *)getStyledButtonForNumber:(int)number;

@end

@implementation ABOTPPadLockScreen

@synthesize delegate, dataSource;
@synthesize pinCodeLabel;
@synthesize incorrectAttemptImageView;
@synthesize incorrectAttemptLabel, subTitleLabel;
@synthesize attempts;

- (id)initWithDelegate:(id<ABOTPPadLockScreenDelegate>)aDelegate withDataSource:(id<ABOTPPadLockScreenDataSource>)aDataSource
{
    self = [super init];
    if (self) {
        [self setDelegate:aDelegate];
        [self setDataSource:aDataSource];
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
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setFrame:CGRectMake(0.0f, 0.0f, 332.0f, 465.0f)];//size of unlock pad
    [self.view setBackgroundColor:[UIColor clearColor]];

    //Set the background view
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background-otp"]];
    [self.view addSubview:backgroundView];

    //Set the title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 10.0f, self.view.frame.size.width - 40.0f, 20.0f)];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18.0f]];
    [titleLabel setText:[dataSource otpPadLockScreenTitleText]];
    [self.view addSubview:titleLabel];

    //Set the cancel button
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setBackgroundColor:[UIColor clearColor]];
    [cancelButton setFrame:CGRectMake(self.view.frame.origin.x + 10.0f, 7.0f, 50.0f, 29.0f)];
    [cancelButton setTitle:NSLocalizedStringFromTable(@"ABLOCKSCREEN_Cancel", @"ABPadLockScreen", nil)
                  forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0f]];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];

    //Set the check button
    UIButton *checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [checkButton setBackgroundColor:[UIColor clearColor]];
    [checkButton setFrame:CGRectMake(self.view.frame.size.width - 60.0f, 7.0f, 50.0f, 29.0f)];
    [checkButton setTitle:NSLocalizedStringFromTable(@"ABLOCKSCREEN_Check", @"ABPadLockScreen", nil)
                 forState:UIControlStateNormal];
    [checkButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0f]];
    [checkButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [checkButton addTarget:self action:@selector(enterButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkButton];

    //Set the subtitle label
    UILabel *_subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 70.0f, self.view.frame.size.width - 40.0f, 20.0f)];
    [_subtitleLabel setTextAlignment:NSTextAlignmentCenter];
    [_subtitleLabel setBackgroundColor:[UIColor clearColor]];
    [_subtitleLabel setTextColor:[UIColor blackColor]];
    [_subtitleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0f]];
    [_subtitleLabel setText:[dataSource otpPadLockScreenSubtitleText]];
    [self setSubTitleLabel:_subtitleLabel];
    [self.view addSubview:subTitleLabel];

    //Set the label showing the pin code
    self.pinCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, 123.0f, 250.0f, 40.0f)];
    self.pinCodeLabel.textAlignment = UITextAlignmentCenter;
    self.pinCodeLabel.backgroundColor = [UIColor clearColor];
    self.pinCodeLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:42.0f];
    self.pinCodeLabel.text = @"";
    [self.view addSubview:self.pinCodeLabel];

    //Set the incorrect attempt error background image and label
    UIImageView *_incorrectAttemptImageView = [[UIImageView alloc] initWithFrame:CGRectMake(60.0f, 190.0f, 216.0f, 20.0f)];
    [self setIncorrectAttemptImageView:_incorrectAttemptImageView];
    [self.view addSubview:incorrectAttemptImageView];

    UILabel *_incorrectAttemptLabel = [[UILabel alloc] initWithFrame:CGRectMake(incorrectAttemptImageView.frame.origin.x + 10.0f,
                                                                                incorrectAttemptImageView.frame.origin.y + 1.0f, 
                                                                                incorrectAttemptImageView.frame.size.width - 20.0f, 
                                                                                incorrectAttemptImageView.frame.size.height - 2.0f)];
    [_incorrectAttemptLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12.0f]];
    [_incorrectAttemptLabel setTextAlignment:NSTextAlignmentCenter];
    [_incorrectAttemptLabel setTextColor:[UIColor whiteColor]];
    [_incorrectAttemptLabel setBackgroundColor:[UIColor clearColor]];
    [self setIncorrectAttemptLabel:_incorrectAttemptLabel];
    [self.view addSubview:incorrectAttemptLabel];

    //Add buttons
    float buttonTop = 242.0f;
    float buttonHeight = 55.0f;
    float leftButtonWidth = 106.0f;
    float middleButtonWidth = 109.0f;
    float rightButtonWidth = 105.0f;

    UIButton *oneButton = [self getStyledButtonForNumber:1];
    [oneButton setFrame:CGRectMake(6.0f, buttonTop, leftButtonWidth, buttonHeight)];
    [self.view addSubview:oneButton];

    UIButton *twoButton = [self getStyledButtonForNumber:2];
    [twoButton setFrame:CGRectMake(oneButton.frame.origin.x + oneButton.frame.size.width, 
                                   oneButton.frame.origin.y, 
                                   middleButtonWidth, 
                                   buttonHeight)];
    [self.view addSubview:twoButton];

    UIButton *threeButton = [self getStyledButtonForNumber:3];
    [threeButton setFrame:CGRectMake(twoButton.frame.origin.x + twoButton.frame.size.width, 
                                     twoButton.frame.origin.y, 
                                     rightButtonWidth, 
                                     buttonHeight)];
    [self.view addSubview:threeButton];

    UIButton *fourButton = [self getStyledButtonForNumber:4];
    [fourButton setFrame:CGRectMake(oneButton.frame.origin.x, 
                                    oneButton.frame.origin.y + oneButton.frame.size.height - 1, 
                                    leftButtonWidth, 
                                    buttonHeight)];
    [self.view addSubview:fourButton];

    UIButton *fiveButton = [self getStyledButtonForNumber:5];
    [fiveButton setFrame:CGRectMake(twoButton.frame.origin.x, 
                                    fourButton.frame.origin.y, 
                                    middleButtonWidth, 
                                    buttonHeight)];
    [self.view addSubview:fiveButton];

    UIButton *sixButton = [self getStyledButtonForNumber:6];
    [sixButton setFrame:CGRectMake(threeButton.frame.origin.x, 
                                   fiveButton.frame.origin.y, 
                                   rightButtonWidth, 
                                   buttonHeight)];
    [self.view addSubview:sixButton];

    UIButton *sevenButton = [self getStyledButtonForNumber:7];
    [sevenButton setFrame:CGRectMake(oneButton.frame.origin.x, 
                                     fourButton.frame.origin.y + fourButton.frame.size.height - 1, 
                                     leftButtonWidth, 
                                     buttonHeight)];
    [self.view addSubview:sevenButton];

    UIButton *eightButton = [self getStyledButtonForNumber:8];
    [eightButton setFrame:CGRectMake(twoButton.frame.origin.x, 
                                     sevenButton.frame.origin.y, 
                                     middleButtonWidth, 
                                     buttonHeight)];
    [self.view addSubview:eightButton];

    UIButton *nineButton = [self getStyledButtonForNumber:9];
    [nineButton setFrame:CGRectMake(threeButton.frame.origin.x, 
                                    sevenButton.frame.origin.y, 
                                    rightButtonWidth, 
                                    buttonHeight)];
    [self.view addSubview:nineButton];

    UIButton *blankButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [blankButton setBackgroundImage:[UIImage imageNamed:@"blank"] forState:UIControlStateNormal];
    [blankButton setBackgroundImage:[UIImage imageNamed:@"blank-selected"] forState:UIControlStateHighlighted];
    [blankButton setFrame:CGRectMake(sevenButton.frame.origin.x,
                                     sevenButton.frame.origin.y + sevenButton.frame.size.height - 1, 
                                     leftButtonWidth, 
                                     buttonHeight)];
    [self.view addSubview:blankButton];

    UIButton *zeroButton = [self getStyledButtonForNumber:0];
    [zeroButton setFrame:CGRectMake(twoButton.frame.origin.x, 
                                    blankButton.frame.origin.y, 
                                    middleButtonWidth, 
                                    buttonHeight)];
    [self.view addSubview:zeroButton];

    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setBackgroundImage:[UIImage imageNamed:@"clear"] forState:UIControlStateNormal];
    [clearButton setBackgroundImage:[UIImage imageNamed:@"clear-selected"] forState:UIControlStateHighlighted];
    [clearButton addTarget:self action:@selector(backSpaceButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [clearButton setFrame:CGRectMake(threeButton.frame.origin.x, 
                                     zeroButton.frame.origin.y, 
                                     rightButtonWidth, 
                                     buttonHeight)];
    [self.view addSubview:clearButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.incorrectAttemptLabel = nil;
    self.subTitleLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - pubilic methods
- (void)resetLockScreen
{
    self.pinCodeLabel.text = @"";
}

- (void)resetAttempts
{
    [self setAttempts:0];
}

#pragma mark - button methods

- (void)cancelButtonTapped:(id)sender
{
    [delegate otpUnlockWasCancelled];
    [self resetLockScreen];
    [incorrectAttemptImageView setImage:nil];
    [incorrectAttemptLabel setText:nil];
}

- (void)enterButtonTapped:(id)sender
{
    [self performSelector:@selector(checkPin) withObject:self afterDelay:0.3];
}

- (void)backSpaceButtonTapped:(id)sender
{
    int length = [self.pinCodeLabel.text length];
    if ( length >= 1 ) {
        self.pinCodeLabel.text = [self.pinCodeLabel.text substringWithRange:NSMakeRange(0, length-1)];
    }
}

- (void)digitButtonPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;

    [self digitInputted:button.tag];
}

- (void)digitInputted:(int)digit
{
    if ( [self.pinCodeLabel.text length] < MAX_PIN_LENGTH ) {
        self.pinCodeLabel.text = [self.pinCodeLabel.text stringByAppendingFormat:@"%i", digit];
    }
}

- (void)checkPin
{
    int stringPasscode = [self.pinCodeLabel.text intValue];
    if ( [dataSource checkOtp:stringPasscode] == YES ) {
        [delegate otpUnlockWasSuccessful];
        [self resetLockScreen];
        [incorrectAttemptImageView setImage:nil];
        [incorrectAttemptLabel setText:nil];
    }
    else {
        attempts += 1;
        [delegate otpUnlockWasUnsuccessful:stringPasscode afterAttemptNumber:attempts];
        if ([dataSource otpHasAttemptLimit]) {
            int remainingAttempts = [dataSource otpAttemptLimit] - attempts;
            if (remainingAttempts != 0)  {
                [incorrectAttemptImageView setImage:[UIImage imageNamed:@"error-box"]];
                [incorrectAttemptLabel setText:
                 [NSString stringWithFormat:NSLocalizedStringFromTable(@"ABLOCKSCREEN_IncorrectPinAttemptsLeft", @"ABPadLockScreen", nil),
                  [dataSource otpAttemptLimit] - attempts]];
            }
            else {
                [incorrectAttemptImageView setImage:[UIImage imageNamed:@"error-box"]];
                [incorrectAttemptLabel setText:NSLocalizedStringFromTable(@"ABLOCKSCREEN_NoRemainingAttempt", @"ABPadLockScreen", nil)];
                [self lockPad];
                [delegate otpAttemptsExpired];
                return;
            }
        }
        else {
            [incorrectAttemptImageView setImage:[UIImage imageNamed:@"error-box"]];
            [incorrectAttemptLabel setText:NSLocalizedStringFromTable(@"ABLOCKSCREEN_IncorrectPin", @"ABPadLockScreen", nil)];
        }
        [self resetLockScreen];
    }
    
}

- (void)lockPad
{
    UIView *lockView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 238.0f, self.view.frame.size.width, self.view.frame.size.height - 238.0f)];
    [subTitleLabel setText:nil];
    [lockView setBackgroundColor:[UIColor blackColor]];
    [lockView setAlpha:0.5];
    [self.view addSubview:lockView];
}

#pragma mark - private methods

- (UIButton *)getStyledButtonForNumber:(int)number
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *imageName = [NSString stringWithFormat:@"%i", number];
    NSString *altImageName = [NSString stringWithFormat:@"%@-selected", imageName];
    [button setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:altImageName] forState:UIControlStateHighlighted];
    [button setTag:number];
    [button addTarget:self action:@selector(digitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return button;
    
}
@end
