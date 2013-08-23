//
//  AlertViewController.m
//  AirHockey
//
//  Created by Andrés Pesate on 8/23/13.
//  Copyright (c) 2013 Andrés Pesate. All rights reserved.
//

#import "AlertViewController.h"

@interface AlertViewController (){
    
    IBOutlet UILabel *title;
    IBOutlet UILabel *message;
    IBOutlet UIButton *okBtn;
    IBOutlet UIButton *dismissBtn;
}
- (IBAction)okAction:(id)sender;
- (IBAction)dismissAction:(id)sender;

@end

@implementation AlertViewController

@synthesize alertDismissBtn, alertMessage, alertOkBtn, alertTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [title release];
    [message release];
    [okBtn release];
    [dismissBtn release];
    [super dealloc];
}
- (IBAction)okAction:(id)sender {
}

- (IBAction)dismissAction:(id)sender {
}
@end
