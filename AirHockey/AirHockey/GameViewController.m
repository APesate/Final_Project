//
//  GameViewController.m
//  AirHockey
//
//  Created by Andrés Pesate on 8/16/13.
//  Copyright (c) 2013 Andrés Pesate. All rights reserved.
//

#import "GameViewController.h"

//@interface GameViewController ()
//
//@property (nonatomic, strong) IBOutlet UILabel *centerLabel;
//
//@end
//
//@implementation GameViewController
//
//@synthesize delegate = _delegate;
//@synthesize game = _game;
//
//@synthesize centerLabel = _centerLabel;
//
//- (void)dealloc
//{
//#ifdef DEBUG
//	NSLog(@"dealloc %@", self);
//#endif
//    [super dealloc];
//}
//
//- (void)viewDidLoad
//{
//	[super viewDidLoad];
//}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
//}
//
//#pragma mark - Actions
//
//- (IBAction)exitAction:(id)sender
//{
//	[self.game quitGameWithReason:QuitReasonUserQuit];
//}
//
//#pragma mark - GameDelegate
//
//- (void)game:(Game *)game didQuitWithReason:(QuitReason)reason
//{
//	[self dismissViewControllerAnimated:NO completion:^
//     {
//         [self.delegate gameViewController:self didQuitWithReason:reason];
//     }];
//}
//
//- (void)gameWaitingForClientsReady:(Game *)game
//{
//	self.centerLabel.text = NSLocalizedString(@"Waiting for other players...", @"Status text: waiting for clients");
//}
//
//- (void)gameWaitingForServerReady:(Game *)game
//{
//	self.centerLabel.text = NSLocalizedString(@"Waiting for game to start...", @"Status text: waiting for server");
//}
//@end

@interface GameViewController ()

@property (nonatomic, retain) IBOutlet UILabel *centerLabel;

@end

@implementation GameViewController

@synthesize delegate = _delegate;
@synthesize game = _game;

@synthesize centerLabel = _centerLabel;

//- (void)dealloc
//{
//#ifdef DEBUG
//	NSLog(@"dealloc %@", self);
//#endif
//    [super dealloc];
//}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Actions

- (IBAction)exitAction:(id)sender
{
	[self.game quitGameWithReason:QuitReasonUserQuit];
}

#pragma mark - GameDelegate

- (void)game:(Game *)game didQuitWithReason:(QuitReason)reason
{
	[self.delegate gameViewController:self didQuitWithReason:reason];
}

- (void)gameWaitingForServerReady:(Game *)game
{
	self.centerLabel.text = NSLocalizedString(@"Waiting for game to start...", @"Status text: waiting for server");
}

- (void)gameWaitingForClientsReady:(Game *)game
{
	self.centerLabel.text = NSLocalizedString(@"Waiting for other players...", @"Status text: waiting for clients");
}

@end