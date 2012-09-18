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
#import "HClient.h"
#import "IncomingMessageController.h"
#import "MessageOptionsController.h"
#import "MessageBuilderController.h"
#import "FunctionsController.h"
#import "MessageSenderController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) HClient * hClient;
@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, weak) IncomingMessageController * incomingMessageController;
@property (nonatomic, weak) MessageOptionsController * messageOptionsController;
@property (nonatomic, weak) MessageBuilderController * messageBuilderController;
@property (nonatomic, weak) FunctionsController * functionsController;
@property (nonatomic, weak) MessageSenderController * messageSenderController;

@end
