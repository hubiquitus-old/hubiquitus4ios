/*
 * Copyright (c) Novedia Group 2012.
 *
 *     This file is part of Hubiquitus.
 *
 *     Hubiquitus is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Hubiquitus is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with Hubiquitus.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "FunctionsController.h"
#import "HUtils.h"
#import "AppDelegate.h"
#import "DDLog.h"
#import "HOptions.h"
#import "SBJson.h"
#import "HLogLevel.h"

@interface FunctionsController () {
    void(^_cb)(HMessage* response);
}

@end

@implementation FunctionsController
@synthesize scrollView;
@synthesize activeField;
@synthesize connector;
@synthesize actor;
@synthesize convstate;
@synthesize convid;
@synthesize nbLastMsg;
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
    
    _cb = ^(HMessage* response) {
        DDLogVerbose(@"Response message : %@", response);
        dispatch_async(dispatch_get_main_queue(), ^() {
            appDelegate.incomingMessageController.onMessageContent.text = [NSString stringWithFormat:@"%@ \n Callback : %@",appDelegate.incomingMessageController.onMessageContent.text, [response JSONRepresentation]];
        });
    };
    
    [self registerForKeyboardNotifications];
    [self createGestureRecognizers];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload 
{
    [self setScrollView:nil];
    [self setActiveField:nil];
    [self setConnector:nil];
    [self setActor:nil];
    [self setConvstate:nil];
    [self setConvid:nil];
    [self setNbLastMsg:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (IBAction)clear:(id)sender {
    self.nbLastMsg.text = @"";
    self.convid.text = @"";
    self.actor.text = @"";
    self.convstate.text = @"";
    
}

- (IBAction)getSubscriptions:(id)sender {
    [hClient getSubscriptionsWithBlock:_cb];
}

- (IBAction)subscribe:(id)sender {
    [hClient subscribeToActor:self.actor.text withBlock:_cb];
}

- (IBAction)unsubscribe:(id)sender {
    [hClient unscribeFromActor:self.actor.text withBlock:_cb];
}

- (IBAction)getLastMessages:(id)sender {
    [hClient getLastMessagesFromActor:self.actor.text quantity:[NSNumber numberWithInt:[self.nbLastMsg.text intValue]] withBlock:_cb];
}

- (IBAction)getThread:(id)sender {
    [hClient getThreadFromActor:self.actor.text withConvid:self.convid.text block:_cb];
}

- (IBAction)getThreads:(id)sender {
    [hClient getThreadsFromActor:self.actor.text withStatus:self.convstate.text block:_cb];
}

- (IBAction)getRelevantMessages:(id)sender {
    [hClient getRelevantMessagesFromActor:self.actor.text withBlock:_cb];
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
    DDLogVerbose(@"Touch up on action");
    [activeField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    activeField = nil;
    [activeField resignFirstResponder];
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
