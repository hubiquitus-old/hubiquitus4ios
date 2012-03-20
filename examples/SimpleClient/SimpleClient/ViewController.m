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

#import "ViewController.h"
#import "HCMessage.h"

@implementation ViewController
@synthesize username;
@synthesize statuses;
@synthesize items;
@synthesize options, client;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString * optionPath = [[NSBundle mainBundle] pathForResource:@"options" ofType:@"plist"];
    options = [HCOptions optionsWithPlist:optionPath];
    client = [HCClient clientWithUsername:TEST_USERNAME password:TEST_PASSWORD delegate:self options:options];
    
    //callback version
    /*client = [HubiquitusClient clientWithUsername:@"" password:@"" options:options callbackBlock:^(NSDictionary * content) {
        NSLog(@"notification : %@", content);
    }];*/
    
    username.text = options.username;
    statuses.text = @"";
    items.text = @"";
}

- (void)viewDidUnload
{
    [self setUsername:nil];
    [self setStatuses:nil];
    [self setItems:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - HCCLient delegate

- (void)notifyResultWithType:(NSString *)type channel:(NSString *)channel_identifier msgid:(NSString *)msgid {
    NSLog(@"Getting a result : Type %@, channel %@, msgid %@", type, channel_identifier, msgid);
}

- (void)notifyLinkStatusUpdate:(NSString *)status code:(NSNumber *)code {
    NSLog(@"Link update : status %@, code %@ \n", status, code);
}

- (void)notifyMessage:(HCMessage *)message FromChannel:(NSString *)channel_identifier {
    NSLog(@"Getting a message : message %@, channel %@", message, channel_identifier);
}

- (void)notifyErrorOfType:(NSString *)type code:(NSNumber*)code channel:(NSString *)channel_identifier msgid:(NSString *)msgid {
    NSLog(@"Error notification : type %@, code %@, channel %@, msgid %@", type, code, channel_identifier, msgid);
}

- (IBAction)connect:(id)sender {
    [client connect];
}

- (IBAction)disconnect:(id)sender {
    [client disconnect];
}

- (IBAction)publish:(id)sender {
    NSDictionary * publishMsg = [NSDictionary dictionaryWithObjectsAndKeys:@"it works !", @"msg", nil];
    HCMessage * message = [[HCMessage alloc] initWithDictionnary:publishMsg];
    NSString * msgid = [client publishToChannel:TEST_CHANNEL message:message];
    NSLog(@"Trying to publish with msgid : %@", msgid);
}

- (IBAction)subscribe:(id)sender {
    NSString * msgid = [client subscribeToChannel:TEST_CHANNEL];
    NSLog(@"Trying to subscribe with msgid : %@", msgid);
}

- (IBAction)unsubscribe:(id)sender {
    NSString * msgid = [client unsubscribeFromChannel:TEST_CHANNEL];
    NSLog(@"Trying to unsubscribe with msgid : %@", msgid);
}

- (IBAction)getAllMessages:(id)sender {
    NSString * msgid = [client getMessagesFromChannel:TEST_CHANNEL2];
    NSLog(@"Trying to get all messages from channel with msgid : %@", msgid);
}
@end
