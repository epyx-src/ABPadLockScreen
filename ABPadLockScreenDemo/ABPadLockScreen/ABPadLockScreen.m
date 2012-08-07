//
//  ABPadLockScreen.m
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
#import "ABPadLockScreen.h"

#define KEY_VALUE_WIDTH 16
#define KEY_VALUE_MARGIN 25

@interface ABPadLockScreen()

@property (nonatomic, strong) UIImageView *keyValueOneImageView;
@property (nonatomic, strong) UIImageView *keyValueTwoImageView;
@property (nonatomic, strong) UIImageView *keyValueThreeImageView;
@property (nonatomic, strong) UIImageView *keyValueFourImageView;
@property (nonatomic, strong) UIImageView *keyValueFiveImageView;
@property (nonatomic, strong) UIImageView *keyValueSixImageView;
@property (nonatomic, strong) UIImageView *incorrectAttemptImageView;

@property (nonatomic, strong) UILabel *incorrectAttemptLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;

@property (nonatomic) int digitsPressed;
@property(nonatomic) int attempts;

@property (nonatomic, strong) NSString *digitOne;
@property (nonatomic, strong) NSString *digitTwo;
@property (nonatomic, strong) NSString *digitThree;
@property (nonatomic, strong) NSString *digitFour;
@property (nonatomic, strong) NSString *digitFive;
@property (nonatomic, strong) NSString *digitSix;

- (void)cancelButtonTapped:(id)sender;
- (void)digitButtonPressed:(id)sender;
- (void)backSpaceButtonTapped:(id)sender;
- (void)digitInputted:(int)digit;
- (void)checkPin;
- (void)lockPad;
- (UIButton *)getStyledButtonForNumber:(int)number;

@end

@implementation ABPadLockScreen
@synthesize delegate, dataSource;
@synthesize keyValueOneImageView, keyValueTwoImageView, keyValueThreeImageView, keyValueFourImageView, keyValueFiveImageView, keyValueSixImageView, incorrectAttemptImageView;
@synthesize incorrectAttemptLabel, subTitleLabel;
@synthesize digitOne, digitTwo, digitThree, digitFour, digitFive, digitSix;
@synthesize digitsPressed, attempts;

- (id)initWithDelegate:(id<ABPadLockScreenDelegate>)aDelegate withDataSource:(id<ABPadLockScreenDataSource>)aDataSource
{
    self = [super init];
    if (self) 
    {
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
    [self.view setBackgroundColor:[UIColor blackColor]];

    //Set the background view
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    [self.view addSubview:backgroundView];

    //Set the title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 10.0f, self.view.frame.size.width - 40.0f, 20.0f)];
    [titleLabel setTextAlignment:UITextAlignmentCenter];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18.0f]];
    [titleLabel setText:[dataSource padLockScreenTitleText]];
    [self.view addSubview:titleLabel];
    
    //Set the cancel button
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setBackgroundColor:[UIColor clearColor]];
    [cancelButton setFrame:CGRectMake(self.view.frame.size.width - 60.0f, 7.0f, 50.0f, 29.0f)];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    //Set the subtitle label
    UILabel *_subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 70.0f, self.view.frame.size.width - 40.0f, 20.0f)];
    [_subtitleLabel setTextAlignment:UITextAlignmentCenter];
    [_subtitleLabel setBackgroundColor:[UIColor clearColor]];
    [_subtitleLabel setTextColor:[UIColor blackColor]];
    [_subtitleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0f]];
    [_subtitleLabel setText:[dataSource padLockScreenSubtitleText]];
    [self setSubTitleLabel:_subtitleLabel];
    [self.view addSubview:subTitleLabel];
    
    //Set the (currently empty) key value images (dots that appear when the user presses a button)
    float keyValueX = 50.0f;
    UIImageView *_keyValueImageOne = [[UIImageView alloc] initWithFrame:CGRectMake(keyValueX, 133.0f, 16.0f, 16.0f)];
    [self setKeyValueOneImageView:_keyValueImageOne];
    [self.view addSubview:keyValueOneImageView];

    keyValueX += KEY_VALUE_WIDTH + KEY_VALUE_MARGIN;
    UIImageView *_keyValueImageTwo = [[UIImageView alloc] initWithFrame:CGRectMake(keyValueX, keyValueOneImageView.frame.origin.y, 16.0f, 16.0f)];
    [self setKeyValueTwoImageView:_keyValueImageTwo];
    [self.view addSubview:keyValueTwoImageView];
    
    keyValueX += KEY_VALUE_WIDTH + KEY_VALUE_MARGIN;
    UIImageView *_keyValueImageThree = [[UIImageView alloc] initWithFrame:CGRectMake(keyValueX,
                                                                                     keyValueOneImageView.frame.origin.y, 
                                                                                     16.0f, 
                                                                                     16.0f)];
    [self setKeyValueThreeImageView:_keyValueImageThree];
    [self.view addSubview:keyValueThreeImageView];
    
    keyValueX += KEY_VALUE_WIDTH + KEY_VALUE_MARGIN;
    UIImageView *_keyValueImageFour = [[UIImageView alloc] initWithFrame:CGRectMake(keyValueX,
                                                                                    keyValueOneImageView.frame.origin.y, 
                                                                                    16.0f, 
                                                                                    16.0f)];
    [self setKeyValueFourImageView:_keyValueImageFour];
    [self.view addSubview:keyValueFourImageView];
    
    keyValueX += KEY_VALUE_WIDTH + KEY_VALUE_MARGIN;
    UIImageView *_keyValueImageFive = [[UIImageView alloc] initWithFrame:CGRectMake(keyValueX,
                                                                                    keyValueOneImageView.frame.origin.y,
                                                                                    16.0f,
                                                                                    16.0f)];
    [self setKeyValueFiveImageView:_keyValueImageFive];
    [self.view addSubview:keyValueFiveImageView];

    keyValueX += KEY_VALUE_WIDTH + KEY_VALUE_MARGIN;
    UIImageView *_keyValueImageSix = [[UIImageView alloc] initWithFrame:CGRectMake(keyValueX,
                                                                                    keyValueOneImageView.frame.origin.y,
                                                                                    16.0f,
                                                                                    16.0f)];
    [self setKeyValueSixImageView:_keyValueImageSix];
    [self.view addSubview:keyValueSixImageView];

    //Set the incorrect attempt error background image and label
    UIImageView *_incorrectAttemptImageView = [[UIImageView alloc] initWithFrame:CGRectMake(60.0f, 190.0f, 216.0f, 20.0f)];
    [self setIncorrectAttemptImageView:_incorrectAttemptImageView];
    [self.view addSubview:incorrectAttemptImageView];
    
    UILabel *_incorrectAttemptLabel = [[UILabel alloc] initWithFrame:CGRectMake(incorrectAttemptImageView.frame.origin.x + 10.0f, 
                                                                                incorrectAttemptImageView.frame.origin.y + 1.0f, 
                                                                                incorrectAttemptImageView.frame.size.width - 20.0f, 
                                                                                incorrectAttemptImageView.frame.size.height - 2.0f)];
    [_incorrectAttemptLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12.0f]];
    [_incorrectAttemptLabel setTextAlignment:UITextAlignmentCenter];
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
    [blankButton setBackgroundImage:[UIImage imageNamed:@"blank"] forState:UIControlStateHighlighted];
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
    [self setDigitsPressed:0];
    
    [keyValueOneImageView setImage:nil];
    [keyValueTwoImageView setImage:nil];
    [keyValueThreeImageView setImage:nil];
    [keyValueFourImageView setImage:nil];
    [keyValueFiveImageView setImage:nil];
    [keyValueSixImageView setImage:nil];
    
    [self setDigitOne:nil];
    [self setDigitTwo:nil];
    [self setDigitThree:nil];
    [self setDigitFour:nil];
    [self setDigitFive:nil];
    [self setDigitSix:nil];
}

- (void)resetAttempts
{
    [self setAttempts:0];
}

#pragma mark - button methods
- (void)cancelButtonTapped:(id)sender
{
    [delegate unlockWasCancelled];
    [self resetLockScreen];
    [incorrectAttemptImageView setImage:nil];
    [incorrectAttemptLabel setText:nil];
    
}

- (void)backSpaceButtonTapped:(id)sender
{
    switch (digitsPressed) 
    {
        case 0:
            break;
            
        case 1:
            digitsPressed = 0;
            [keyValueOneImageView setImage:nil];
            [self setDigitOne:nil];
            break;
            
        case 2:
            digitsPressed = 1;
            [keyValueTwoImageView setImage:nil];
            [self setDigitTwo:nil];
            break;
            
        case 3:
            digitsPressed = 2;
            [keyValueThreeImageView setImage:nil];
            [self setDigitThree:nil];
            break;
            
        case 4:
            digitsPressed = 3;
            [keyValueFourImageView setImage:nil];
            [self setDigitFour:nil];
            break;
            
        case 5:
            digitsPressed = 4;
            [keyValueFiveImageView setImage:nil];
            [self setDigitFive:nil];
            break;
            
        default:
            break;
    }
    
}

- (void)digitButtonPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    [self digitInputted:button.tag];
}

- (void)digitInputted:(int)digit
{
    switch (digitsPressed) 
    {
        case 0:
            digitsPressed = 1;
            [keyValueOneImageView setImage:[UIImage imageNamed:@"input"]];
            [self setDigitOne:[NSString stringWithFormat:@"%i", digit]];
            break;
            
        case 1:
            digitsPressed = 2;
            [keyValueTwoImageView setImage:[UIImage imageNamed:@"input"]];
            [self setDigitTwo:[NSString stringWithFormat:@"%i", digit]];
            break;
            
        case 2:
            digitsPressed = 3;
            [keyValueThreeImageView setImage:[UIImage imageNamed:@"input"]];
            [self setDigitThree:[NSString stringWithFormat:@"%i", digit]];
            break;
            
        case 3:
            digitsPressed = 4;
            [keyValueFourImageView setImage:[UIImage imageNamed:@"input"]];
            [self setDigitFour:[NSString stringWithFormat:@"%i", digit]];
            break;
            
        case 4:
            digitsPressed = 5;
            [keyValueFiveImageView setImage:[UIImage imageNamed:@"input"]];
            [self setDigitFive:[NSString stringWithFormat:@"%i", digit]];
            break;

        case 5:
            digitsPressed = 6;
            [keyValueSixImageView setImage:[UIImage imageNamed:@"input"]];
            [self setDigitSix:[NSString stringWithFormat:@"%i", digit]];
            [self performSelector:@selector(checkPin) withObject:self afterDelay:0.3];
            break;

        default:
            break;
    }
}

- (void)checkPin
{
    int stringPasscode = [[NSString stringWithFormat:@"%@%@%@%@%@%@", digitOne, digitTwo, digitThree, digitFour, digitFive, digitSix] intValue];
    if (stringPasscode == [dataSource unlockPasscode]) 
    {
        [delegate unlockWasSuccessful];
        [self resetLockScreen];
        [incorrectAttemptImageView setImage:nil];
        [incorrectAttemptLabel setText:nil];
    }
    else
    {
        attempts += 1;
        [delegate unlockWasUnsuccessful:stringPasscode afterAttemptNumber:attempts];
        if ([dataSource hasAttemptLimit]) 
        {
            
            int remainingAttempts = [dataSource attemptLimit] - attempts;
            if (remainingAttempts != 0) 
            {
                [incorrectAttemptImageView setImage:[UIImage imageNamed:@"error-box"]];
                [incorrectAttemptLabel setText:[NSString stringWithFormat:@"Incorrect pin. %i attempts left", [dataSource attemptLimit] - attempts]];
            }
            else
            {
                [incorrectAttemptImageView setImage:[UIImage imageNamed:@"error-box"]];
                [incorrectAttemptLabel setText:@"No remaining attempts"];
                [self lockPad];
                [delegate attemptsExpired];
                return;
            }
        }
        else
        {
            [incorrectAttemptImageView setImage:[UIImage imageNamed:@"error-box"]];
            [incorrectAttemptLabel setText:[NSString stringWithFormat:@"Incorrect pin"]];
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
