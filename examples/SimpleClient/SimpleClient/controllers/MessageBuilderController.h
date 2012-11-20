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

#import <UIKit/UIKit.h>
#import "HClient.h"
#import "SimpleClientViewController.h"

@interface MessageBuilderController: UIViewController<UITextFieldDelegate, UIGestureRecognizerDelegate, SimpleClientViewController>

@property (strong, nonatomic) HClient * hClient;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) UITextField *activeField;
@property (weak, nonatomic) IBOutlet UIImageView *connector;
@property (weak, nonatomic) IBOutlet UITextField *cmd_status_unit;
@property (weak, nonatomic) IBOutlet UITextField *params_result_value;
@property (weak, nonatomic) IBOutlet UITextField *alert_ack;
@property (weak, nonatomic) IBOutlet UITextField *convstate_convid;
@property (weak, nonatomic) IBOutlet UITextField *errors;


- (IBAction)hideKeyboard:(id)sender;
- (void)registerForKeyboardNotifications;
- (void)keyboardWasShown:(NSNotification*)aNotification;
- (void)keyboardWillBeHidden:(NSNotification*)aNotification;

- (IBAction)buildCmd:(id)sender;
- (IBAction)buildResult:(id)sender;
- (IBAction)buildMeasure:(id)sender;
- (IBAction)buildAck:(id)sender;
- (IBAction)buildAlert:(id)sender;
- (IBAction)buildConvstate:(id)sender;

- (IBAction)clear:(id)sender;

@end
