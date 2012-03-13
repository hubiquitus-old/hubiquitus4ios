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
    client = [HCClient clientWithUsername:@"" password:@"" options:options delegate:self];
    
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

- (void)notifyIncomingItem:(id)item {
    NSLog(@"Incoming item %@ \n", item);
    
    //fill the satus text field
    NSString * itemString = [item objectAtIndex:0];
    NSString * contentToAdd = @"";
    
    NSDictionary * item_data = [NSJSONSerialization JSONObjectWithData:[itemString dataUsingEncoding:NSASCIIStringEncoding] options:0 error:nil];
    
    contentToAdd = [NSString stringWithFormat:@"%@ \n\n\n\n ********************************* \n\n\n\n %@",contentToAdd, item_data];
    
    items.text = [NSString stringWithFormat:@"%@\n%@", items.text, contentToAdd];
}

- (void)notifyStatusUpdate:(NSString *)status {
    //fill the satus text field
    NSString * contentToAdd = status;
    statuses.text = [NSString stringWithFormat:@"%@\n%@", statuses.text, contentToAdd];
    
    NSLog(@"status update : %@", status);
    
    //make some test with the api
    /*if ([status compare:@"Connected"] == NSOrderedSame) {

    }*/
}

- (IBAction)connect:(id)sender {
    [client connect];
}

- (IBAction)disconnect:(id)sender {
    [client disconnect];
}

- (IBAction)publish:(id)sender {
    NSLog(@"Trying to publish");
    NSDictionary * publishMsg = [NSDictionary dictionaryWithObjectsAndKeys:@"it works !", @"msg", nil];
    [client publishToNode:@"" items:[NSArray arrayWithObjects:publishMsg, nil]];
}

- (IBAction)subscribe:(id)sender {
    NSLog(@"Trying to subscribe");
    [client subscribeToNode:@""];
}

- (IBAction)unsubscribe:(id)sender {
    NSLog(@"Trying to unsubscribe");
    [client unsubscribeFromNode:@"" withSubID:nil];
}
@end
