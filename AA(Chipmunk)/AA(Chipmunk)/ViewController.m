//
//  ViewController.m
//  AA(Chipmunk)
//
//  Created by Grimi on 8/11/13.
//  Copyright (c) 2013 MobileMakers. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad
{
    
    floor = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"floor.png"]];
    
    floor.center = CGPointMake(160, 350);
    
    ball = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ball.png"]];
    
    ball.center = CGPointMake(160, 230);
    
    [self.view addSubview:floor];
    
    [self.view addSubview:ball];

    

    [super viewDidLoad];
    
    [self setupChipmuck];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (void)setupChipmuck {
	// Start chipmuck
	cpInitChipmunk();
	
	// Create a space object
	space = cpSpaceNew();
	
	// Define a gravity vector
	space->gravity = cpv(0, -100);
	
	// Add some elastic effects to the simulation
    
	space->elasticIterations = 10;
	
	// Creates a timer firing at a constant interval (desired framerate)
	// Note that if you are using too much CPU the real framerate will be lower and
	// the timer might fire before the last frame was complete.
	// There are techniques you can use to avoid this but I won't approach them here.
	[NSTimer scheduledTimerWithTimeInterval:1.0f/60.0f target:self selector:@selector(tick:) userInfo:nil repeats:YES];
	
	// Create our ball's body with 100 mass and infinite moment
	cpBody *ballBody = cpBodyNew(100.0, INFINITY);
	
	// Set the initial position
	ballBody->p = cpv(60, 250);
	
	// Add the body to the space
	cpSpaceAddBody(space, ballBody);
	
	// Create our shape associated with the ball's body
	cpShape *ballShape = cpCircleShapeNew(ballBody, 20.0, cpvzero);
	ballShape->e = 0.5; // Elasticity
	ballShape->u = 0.1; // Friction
	ballShape->data = ball.image; // Associate with out ball's UIImageView
	ballShape->collision_type = 1; // Collisions are grouped by types
	
	// Add the shape to out space
	cpSpaceAddShape(space, ballShape);
	
	// Create our floor's body and set it's position
	cpBody *floorBody = cpBodyNew(INFINITY, INFINITY);
	floorBody->p = cpv(160, 480-350);
	
	// Define our shape's vertexes
	cpVect verts1[] = { cpv(0.0, 0.0), cpv(50.0, 0.0), cpv(45.0, -15.0), cpv(0.0, -15.0) };
	
	cpVect verts2[] = {	cpv(50.0, 0.0), cpv(116.0, -66.0), cpv(110.0, -81.0), cpv(45.0, -15.0) };
	
	cpVect verts3[] = { cpv(116.0, -66.0), cpv(204.0, -66.0), cpv(210.0, -81.0), cpv(110.0, -81.0) };
	
	cpVect verts4[] = { cpv(204.0, -66.0), cpv(270.0, 0.0), cpv(275.0, -15.0), cpv(210.0, -81.0) };
	
	cpVect verts5[] = { cpv(270.0, 0.0), cpv(320.0, 0.0), cpv(320.0, -15.0), cpv(275.0, -15.0) };
	
	// Create all shapes
	cpShape *floorShape = cpPolyShapeNew(floorBody, 4, verts1, cpv(-320.0f / 2, 81.0f / 2));
	floorShape->e = 0.5; floorShape->u = 0.5; floorShape->collision_type = 0;
	floorShape->data = floor;
	cpSpaceAddStaticShape(space, floorShape);
	
	floorShape = cpPolyShapeNew(floorBody, 4, verts2, cpv(-320.0f / 2, 81.0f / 2));
	floorShape->e = 0.5; floorShape->u = 0.5; floorShape->collision_type = 0;
	floorShape->data = floor;
	cpSpaceAddStaticShape(space, floorShape);
	
	floorShape = cpPolyShapeNew(floorBody, 4, verts3, cpv(-320.0f / 2, 81.0f / 2));
	floorShape->e = 0.5; floorShape->u = 0.5; floorShape->collision_type = 0;
	floorShape->data = floor;
	cpSpaceAddStaticShape(space, floorShape);
	
	floorShape = cpPolyShapeNew(floorBody, 4, verts4, cpv(-320.0f / 2, 81.0f / 2));
	floorShape->e = 0.5; floorShape->u = 0.5; floorShape->collision_type = 0;
	floorShape->data = floor;
	cpSpaceAddStaticShape(space, floorShape);
	
	floorShape = cpPolyShapeNew(floorBody, 4, verts5, cpv(-320.0f / 2, 81.0f / 2));
	floorShape->e = 0.5; floorShape->u = 0.5; floorShape->collision_type = 0;
	floorShape->data = floor;
	cpSpaceAddStaticShape(space, floorShape);
}


// Called at each "frame" of the simulation

- (void)tick:(NSTimer *)timer {
    
    // Tell Chipmunk to take another "step" in the simulation
    
    cpSpaceStep(space, 1.0f/60.0f);
    cpSpaceHashEach(space->activeShapes, &updateShape, nil);

    
}

void updateShape(void *ptr, void* unused) {
    
    // Get our shape
    
    cpShape *shape = (cpShape*)ptr;
    
    // Make sure everything is as expected or tip & exit
    
    if(shape == nil || shape->body == nil || shape->data == nil) {
        
        NSLog(@"Unexpected shape please debug here...");
        
        return;
        
    }
    
    // Lastly checks if the object is an UIView of any kind
    
    // and update its position accordingly
    
    if([shape->data isKindOfClass:[UIView class]]) {
        
        [(UIView *)shape->data setCenter:CGPointMake(shape->body->p.x, 480-shape->body->p.y)];
        
    }
    
    else
        
        NSLog(@"The shape data wasn't updateable using this code.");
    
}


@end
