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

#import "TabBarController.h"
#import "AppDelegate.h"
#import "SimpleClientViewController.h"
#import "ConnectionController.h"
#import "IncomingMessageController.h"
#import "IncomingMessageController.h"
#import "MessageOptionsController.h"
#import "MessageBuilderController.h"
#import "FunctionsController.h"
#import "MessageSenderController.h"

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
    
    appDelegate.incomingMessageController = [[weakSelf viewControllers] objectAtIndex:2];
    appDelegate.messageOptionsController = [[weakSelf viewControllers] objectAtIndex:1];
    appDelegate.messageBuilderController = [[weakSelf viewControllers] objectAtIndex:4];
    appDelegate.functionsController = [[weakSelf viewControllers] objectAtIndex:5];
    appDelegate.messageSenderController = [[weakSelf viewControllers] objectAtIndex:3];
    
    hClient.onStatus = ^(HStatus *status) {
        NSLog(@"Fulljid : %@, resource : %@", hClient.fulljid, hClient.resource);
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
            IncomingMessageController * msgController = [[weakSelf viewControllers] objectAtIndex:2];
            NSError * error = nil;
            msgController.onMessageContent.text = [NSString stringWithFormat:@"%@ \n OnMessage : %@",msgController.onMessageContent.text, [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message options:kNilOptions error:&error] encoding:NSUTF8StringEncoding]];
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
