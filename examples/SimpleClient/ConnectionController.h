//
//  ConnectionController.h
//  SimpleClient
//
//  Created by Novedia Agency on 06/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConnectionController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *publisher;
@property (weak, nonatomic) IBOutlet UITextField *password;

@property (weak, nonatomic) IBOutlet UITextField *endpoints;
@property (weak, nonatomic) IBOutlet UITextField *serverHost;
@property (weak, nonatomic) IBOutlet UITextField *serverPort;

@property (weak, nonatomic) IBOutlet UILabel *connStatus;
@property (weak, nonatomic) IBOutlet UILabel *errorCode;
@property (weak, nonatomic) IBOutlet UILabel *errorMsg;

- (IBAction)hideKeyboard:(id)sender;

- (IBAction)connect:(id)sender;
- (IBAction)disconnect:(id)sender;




@end
