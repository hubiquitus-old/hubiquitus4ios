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

#import <UIKit/UIKit.h>

@interface ConnectionController : UIViewController<UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) UITextField *activeField;

@property (weak, nonatomic) IBOutlet UITextField *publisher;
@property (weak, nonatomic) IBOutlet UITextField *password;

@property (weak, nonatomic) IBOutlet UITextField *endpoints;
@property (weak, nonatomic) IBOutlet UITextField *serverHost;
@property (weak, nonatomic) IBOutlet UITextField *serverPort;

@property (weak, nonatomic) IBOutlet UILabel *connStatus;
@property (weak, nonatomic) IBOutlet UILabel *errorCode;
@property (weak, nonatomic) IBOutlet UILabel *errorMsg;

- (IBAction)hideKeyboard:(id)sender;
- (void)registerForKeyboardNotifications;
- (void)keyboardWasShown:(NSNotification*)aNotification;
- (void)keyboardWillBeHidden:(NSNotification*)aNotification;

- (IBAction)connect:(id)sender;
- (IBAction)disconnect:(id)sender;

@end
