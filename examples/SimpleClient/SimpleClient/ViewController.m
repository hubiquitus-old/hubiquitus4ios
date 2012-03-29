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
@synthesize channel;
@synthesize console;
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
    /*
    client = [HCClient clientWithUsername:TEST_USERNAME password:TEST_PASSWORD callbackBlock:^(NSString * context, NSDictionary * data) {
        NSLog(@"Event : context %@,    data %@", context, data);
    } options:options];
    */
     
    self.channel.text = TEST_CHANNEL;
    username.text = options.username;
    
}

- (void)viewDidUnload
{
    [self setUsername:nil];
    [self setChannel:nil];
    [self setConsole:nil];
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

- (void)updateConsoleWithTxt:(NSString*)txt {
    console.text = [NSString stringWithFormat:@"%@\n%@", console.text, txt];
    [console scrollRangeToVisible:NSMakeRange(console.text.length-2, 1)];
}

- (void)notifyResultWithType:(NSString *)type channel:(NSString *)channel_identifier msgid:(NSString *)msgid {
    NSLog(@"Getting a result : Type %@, channel %@, msgid %@", type, channel_identifier, msgid);
    NSString * txt = [NSString stringWithFormat:@"Getting a result : Type %@, channel %@, msgid %@", type, channel_identifier, msgid ];
    [self performSelectorOnMainThread:@selector(updateConsoleWithTxt:) withObject:txt waitUntilDone:YES];
}

- (void)notifyLinkStatusUpdate:(NSString *)status code:(NSNumber *)code {
    NSLog(@"Link update : status %@, code %@ \n", status, code);
    NSString * txt = [NSString stringWithFormat:@"Link update : status %@, code %@ \n", status, code];
    [self performSelectorOnMainThread:@selector(updateConsoleWithTxt:) withObject:txt waitUntilDone:YES];
    
}

- (void)notifyMessage:(HCMessage *)message FromChannel:(NSString *)channel_identifier {
    NSLog(@"Getting a message : message %@, channel %@", message, channel_identifier);
    NSString * txt = [NSString stringWithFormat:@"Getting a message : message %@, channel %@", message, channel_identifier];
    [self performSelectorOnMainThread:@selector(updateConsoleWithTxt:) withObject:txt waitUntilDone:YES];
}

- (void)notifyErrorOfType:(NSString *)type code:(NSNumber*)code channel:(NSString *)channel_identifier msgid:(NSString *)msgid {
    NSLog(@"Error notification : type %@, code %@, channel %@, msgid %@", type, code, channel_identifier, msgid);
    NSString * txt = [NSString stringWithFormat:@"Error notification : type %@, code %@, channel %@, msgid %@", type, code, channel_identifier, msgid];
    [self performSelectorOnMainThread:@selector(updateConsoleWithTxt:) withObject:txt waitUntilDone:YES];
}

#pragma mark - buttons actions

- (IBAction)connect:(id)sender {
    [client connect];
}

- (IBAction)disconnect:(id)sender {
    [client disconnect];
}

- (IBAction)publish:(id)sender {
    NSDictionary * publishMsg = [NSDictionary dictionaryWithObjectsAndKeys:@"it works !", @"msg", nil];
    HCMessage * message = [[HCMessage alloc] initWithDictionnary:publishMsg];
    NSString * msgid = [client publishToChannel:self.channel.text message:message];
    NSLog(@"Trying to publish with msgid : %@", msgid);
    NSString * txt = [NSString stringWithFormat:@"%Trying to publish with msgid : %@", msgid];
    [self performSelectorOnMainThread:@selector(updateConsoleWithTxt:) withObject:txt waitUntilDone:YES];
}

- (IBAction)subscribe:(id)sender {
    NSString * msgid = [client subscribeToChannel:self.channel.text];
    NSLog(@"Trying to subscribe with msgid : %@", msgid);
    NSString * txt = [NSString stringWithFormat:@"Trying to subscribe with msgid : %@", msgid];
    [self performSelectorOnMainThread:@selector(updateConsoleWithTxt:) withObject:txt waitUntilDone:YES];
}

- (IBAction)unsubscribe:(id)sender {
    NSString * msgid = [client unsubscribeFromChannel:self.channel.text];
    NSLog(@"Trying to unsubscribe with msgid : %@", msgid);
    NSString * txt = [NSString stringWithFormat:@"Trying to unsubscribe with msgid : %@",msgid];
    [self performSelectorOnMainThread:@selector(updateConsoleWithTxt:) withObject:txt waitUntilDone:YES];
}

- (IBAction)getAllMessages:(id)sender {
    NSString * msgid = [client getMessagesFromChannel:self.channel.text];
    NSLog(@"Trying to get all messages from channel with msgid : %@", msgid);
    NSString * txt = [NSString stringWithFormat:@"Trying to get all messages from channel with msgid : %@", msgid];
    [self performSelectorOnMainThread:@selector(updateConsoleWithTxt:) withObject:txt waitUntilDone:YES];
}

- (IBAction)clear:(id)sender {
    console.text = @"";
}

- (IBAction)closeKeyboard:(id)sender {
    [self.channel resignFirstResponder];
}

@end
