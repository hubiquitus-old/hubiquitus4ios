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

#import "MessageBuilderController.h"
#import "HUtils.h"
#import "AppDelegate.h"
#import "DDLog.h"
#import "HOptions.h"
#import "SBJson.h"
#import "HNativeObjectsCategories.h"
#import "HClient.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface MessageBuilderController ()

@end

@implementation MessageBuilderController
@synthesize scrollView;
@synthesize activeField;
@synthesize connector;
@synthesize cmd_status_unit;
@synthesize params_result_value;
@synthesize alert_ack;
@synthesize convstate_convid;
@synthesize errors;
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
    [self setScrollView:nil];
    [self setActiveField:nil];
    [self setConnector:nil];
    [self setCmd_status_unit:nil];
    [self setParams_result_value:nil];
    [self setAlert_ack:nil];
    [self setConvstate_convid:nil];
    [self setErrors:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (IBAction)clear:(id)sender {
    self.cmd_status_unit.text = @"";
    self.params_result_value.text = @"";
    self.alert_ack.text = @"";
    self.convstate_convid.text = @"";
    self.errors.text = @"";
    
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

- (IBAction)buildCmd:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[ [UIApplication sharedApplication] delegate];
    NSError * error;
    
    HMessageOptions * msgOpts = [[HMessageOptions alloc] init];
    msgOpts.convid = appDelegate.messageOptionsController.convid.text;
    msgOpts.ref = appDelegate.messageOptionsController.ref.text;
    msgOpts.priority = [appDelegate.messageOptionsController.priority.text intValue];
    msgOpts.author = appDelegate.messageOptionsController.author.text;
    msgOpts.timeout = [appDelegate.messageOptionsController.timeout.text intValue];
    
    NSDictionary * params = [self.params_result_value.text JSONValue];
    HMessage * msg = [hClient buildCommandWithActor:appDelegate.messageOptionsController.actor.text cmd:self.cmd_status_unit.text params:params options:msgOpts didFailWithError:&error];
    
    self.errors.text = [error description];
    
    appDelegate.messageSenderController.messageContent.text = [msg JSONRepresentation];
}

- (IBAction)buildResult:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[ [UIApplication sharedApplication] delegate];
    NSError * error;
    
    
    HMessageOptions * msgOpts = [[HMessageOptions alloc] init];
    msgOpts.convid = appDelegate.messageOptionsController.convid.text;
    msgOpts.ref = appDelegate.messageOptionsController.ref.text;
    msgOpts.priority = [appDelegate.messageOptionsController.priority.text intValue];
    msgOpts.author = appDelegate.messageOptionsController.author.text;
    msgOpts.timeout = [appDelegate.messageOptionsController.timeout.text intValue];
    
    
    NSDictionary * result = [self.params_result_value.text JSONValue];
    HMessage * msg = [hClient buildResultWithActor:appDelegate.messageOptionsController.actor.text ref:appDelegate.messageOptionsController.ref.text status:[self.cmd_status_unit.text intValue] result:result options:msgOpts didFailWithError:&error];
    
    self.errors.text = [error description];
    
    appDelegate.messageSenderController.messageContent.text = [msg JSONRepresentation];
}

- (IBAction)buildMeasure:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[ [UIApplication sharedApplication] delegate];
    NSError * error;
    
    HMessageOptions * msgOpts = [[HMessageOptions alloc] init];
    msgOpts.convid = appDelegate.messageOptionsController.convid.text;
    msgOpts.ref = appDelegate.messageOptionsController.ref.text;
    msgOpts.priority = [appDelegate.messageOptionsController.priority.text intValue];
    msgOpts.author = appDelegate.messageOptionsController.author.text;
    msgOpts.timeout = [appDelegate.messageOptionsController.timeout.text intValue];
    
    HMessage * msg = [hClient buildMeasureWithActor:appDelegate.messageOptionsController.actor.text value:self.params_result_value.text unit:self.cmd_status_unit.text options:msgOpts didFailWithError:&error];
    
    self.errors.text = [error description];
    
    appDelegate.messageSenderController.messageContent.text = [msg JSONRepresentation];
}

- (IBAction)buildAck:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[ [UIApplication sharedApplication] delegate];
    NSError * error;
    
    HMessageOptions * msgOpts = [[HMessageOptions alloc] init];
    msgOpts.convid = appDelegate.messageOptionsController.convid.text;
    msgOpts.ref = appDelegate.messageOptionsController.ref.text;
    msgOpts.priority = [appDelegate.messageOptionsController.priority.text intValue];
    msgOpts.author = appDelegate.messageOptionsController.author.text;
    msgOpts.timeout = [appDelegate.messageOptionsController.timeout.text intValue];
    
    HMessage * msg = [hClient buildAckWithActor:appDelegate.messageOptionsController.actor.text ref:appDelegate.messageOptionsController.ref.text ack:self.alert_ack.text options:msgOpts didFailWithError:&error] ;
    
    self.errors.text = [error description];
    
    appDelegate.messageSenderController.messageContent.text = [msg JSONRepresentation];
}

- (IBAction)buildAlert:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[ [UIApplication sharedApplication] delegate];
    NSError * error;
    
    HMessageOptions * msgOpts = [[HMessageOptions alloc] init];
    msgOpts.convid = appDelegate.messageOptionsController.convid.text;
    msgOpts.ref = appDelegate.messageOptionsController.ref.text;
    msgOpts.priority = [appDelegate.messageOptionsController.priority.text intValue];
    msgOpts.author = appDelegate.messageOptionsController.author.text;
    msgOpts.timeout = [appDelegate.messageOptionsController.timeout.text intValue];
    
    HMessage * msg = [hClient buildAlertWithActor:appDelegate.messageOptionsController.actor.text alert:self.alert_ack.text options:msgOpts didFailWithError:&error];
    
    self.errors.text = [error description];
    
    appDelegate.messageSenderController.messageContent.text = [msg JSONRepresentation];
}

- (IBAction)buildConvstate:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[ [UIApplication sharedApplication] delegate];
    NSError * error;
    
    HMessageOptions * msgOpts = [[HMessageOptions alloc] init];
    msgOpts.convid = appDelegate.messageOptionsController.convid.text;
    msgOpts.ref = appDelegate.messageOptionsController.ref.text;
    msgOpts.priority = [appDelegate.messageOptionsController.priority.text intValue];
    msgOpts.author = appDelegate.messageOptionsController.author.text;
    msgOpts.timeout = [appDelegate.messageOptionsController.timeout.text intValue];
    
    HMessage * msg = [hClient buildConvStateWithActor:appDelegate.messageOptionsController.actor.text convid:self.convstate_convid.text status:self.cmd_status_unit.text option:msgOpts didFailWithError:&error];
    
    self.errors.text = [error description];
    
    appDelegate.messageSenderController.messageContent.text = [msg JSONRepresentation];
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
