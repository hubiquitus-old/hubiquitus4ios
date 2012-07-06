//
//  ConnectionController.m
//  SimpleClient
//
//  Created by Novedia Agency on 06/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConnectionController.h"

@interface ConnectionController ()

@end

@implementation ConnectionController
@synthesize publisher;
@synthesize password;
@synthesize endpoints;
@synthesize serverHost;
@synthesize serverPort;
@synthesize connStatus;
@synthesize errorCode;
@synthesize errorMsg;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setPublisher:nil];
    [self setPassword:nil];
    [self setEndpoints:nil];
    [self setServerHost:nil];
    [self setServerPort:nil];
    [self setConnStatus:nil];
    [self setErrorCode:nil];
    [self setErrorMsg:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)hideKeyboard:(id)sender {
    [publisher resignFirstResponder];
    [password resignFirstResponder];
    [endpoints resignFirstResponder];
    [serverHost resignFirstResponder];
    [serverPort resignFirstResponder];
}

- (IBAction)connect:(id)sender {
}

- (IBAction)disconnect:(id)sender {
}
@end
