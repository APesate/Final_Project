//
//  AlertViewController.h
//  AirHockey
//
//  Created by Andrés Pesate on 8/23/13.
//  Copyright (c) 2013 Andrés Pesate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertViewController : UIViewController

@property (retain, nonatomic) NSString* alertTitle;
@property (retain, nonatomic) NSString* alertMessage;
@property (retain, nonatomic) NSString* alertOkBtn;
@property (retain, nonatomic) NSString* alertDismissBtn;

@end
