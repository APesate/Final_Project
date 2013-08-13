//
//  ViewController.h
//  AA(Chipmunk)
//
//  Created by Grimi on 8/11/13.
//  Copyright (c) 2013 MobileMakers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "chipmunk.h"

@interface ViewController : UIViewController
{
    UIImageView * floor;
    UIImageView * ball;
    
    cpSpace * space;
}

-(void)setupChipmuck;
-(void)tick:(NSTimer*)timer;
void updateShape(void *ptr, void* unused);
@end
