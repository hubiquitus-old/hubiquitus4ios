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

#import "TabBarController.h"
#import "AppDelegate.h"
#import "SimpleClientViewController.h"
#import "ConnectionController.h"
#import "MessageController.h"
#import "SBJson.h"

@interface TabBarController ()

@end

@implementation TabBarController
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
    // Do any additional setup after loading the view from its nib.
    AppDelegate *appDelegate = (AppDelegate *)[ [UIApplication sharedApplication] delegate];
    self.hClient = appDelegate.hClient;
    
    __weak TabBarController *weakSelf = self;
    
    hClient.onStatus = ^(HStatus *status) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            UIViewController *selectedViewController = [weakSelf selectedViewController];
            if([selectedViewController conformsToProtocol:@protocol(SimpleClientViewController)]) {
                id<SimpleClientViewController> viewController = (id<SimpleClientViewController>)selectedViewController;
                [viewController updateConnectorStatus:status.status];
            }
            
            //update connection view
            ConnectionController * connController = [[weakSelf viewControllers] objectAtIndex:0];
            connController.connStatus.text = [NSString stringWithFormat:@"%d",status.status];
            connController.errorCode.text = [NSString stringWithFormat:@"%d",status.errorCode];
            connController.errorMsg.text = status.errorMsg;
        });
    };
    
    hClient.onMessage = ^(HMessage *message) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            //update connection view
            MessageController * msgController = [[weakSelf viewControllers] objectAtIndex:1];
            msgController.onMessageContent.text = [NSString stringWithFormat:@"%@ \n Callback : %@",msgController.onMessageContent.text, [message JSONRepresentation]];
        });
    };

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
