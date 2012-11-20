/*
 * Copyright (c) Novedia Group 2012.
 *
 *    This file is part of Hubiquitus
 *
 *    Permission is hereby granted, free of charge, to any person obtaining a copy
 *    of this software and associated documentation files (the "Software"), to deal
 *    in the Software without restriction, including without limitation the rights
 *    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 *    of the Software, and to permit persons to whom the Software is furnished to do so,
 *    subject to the following conditions:
 *
 *    The above copyright notice and this permission notice shall be included in all copies
 *    or substantial portions of the Software.
 *
 *    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 *    INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 *    PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
 *    FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 *    ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 *    You should have received a copy of the MIT License along with Hubiquitus.
 *    If not, see <http://opensource.org/licenses/mit-license.php>.
 */

#import "ConnectionController.h"
#import "HUtils.h"
#import "AppDelegate.h"
#import "DDLog.h"
#import "HOptions.h"
#import "HLogLevel.h"

@interface ConnectionController ()

@end

@implementation ConnectionController
@synthesize scrollView;
@synthesize publisher;
@synthesize password;
@synthesize endpoints;
@synthesize connStatus;
@synthesize errorCode;
@synthesize errorMsg;
@synthesize activeField;
@synthesize connector;
@synthesize hClient;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[ [UIApplication sharedApplication] delegate];
    self.hClient = appDelegate.hClient;
    
    [self registerForKeyboardNotifications];
    [self createGestureRecognizers];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload 
{
    [self setPublisher:nil];
    [self setPassword:nil];
    [self setEndpoints:nil];
    [self setConnStatus:nil];
    [self setErrorCode:nil];
    [self setErrorMsg:nil];
    [self setScrollView:nil];
    [self setActiveField:nil];
    [self setConnector:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (IBAction)connect:(id)sender {
    [self hideKeyboard:nil];
    
    DDLogVerbose(@"Connecting with publisher %@ and endpoints : %@", publisher.text, endpoints.text); 

    HOptions *options = [[HOptions alloc] init];
    options.endpoints = [endpoints.text componentsSeparatedByString:@","];
    
    [self.hClient connectWithPublisher:publisher.text password:password.text options:options];
}

- (IBAction)disconnect:(id)sender {
    [self hideKeyboard:nil];
    DDLogVerbose(@"disconnecting");
    [self.hClient disconnect];
}



#pragma mark - common views setup

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)createGestureRecognizers {
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(hideKeyboard:)];
    tapRecognizer.delegate = self;
    [self.scrollView addGestureRecognizer:tapRecognizer];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height + scrollView.bounds.size.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y + activeField.frame.size.height - aRect.size.height);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}


#pragma mark - text field delegate

- (IBAction)hideKeyboard:(id)sender {
    [activeField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    activeField = nil;
}

#pragma mark - gesture recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]){
        return NO;
    }
    return YES;
}

#pragma mark - simple client view controller protocol
- (void)updateConnectorStatus:(Status)status {
    if(status == CONNECTED) {
        self.connector.image = [UIImage imageNamed:@"hub_connected"];
    } else if(status == DISCONNECTED) {
        self.connector.image = [UIImage imageNamed:@"hub_disconnected"];
    } else {
        self.connector.image = [UIImage imageNamed:@"hub_connecting"];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateConnectorStatus:hClient.status];
}

@end
