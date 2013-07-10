//
//  TLContainmentViewController.m
//  UIKit-Dynamics-Example
//
//  Created by Ash Furrow on 2013-07-09.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLContainmentViewController.h"
#import "TLContentViewController.h"

@interface TLContainmentViewController () <TLContentViewControllerDelegate, UIDynamicAnimatorDelegate>

@property (nonatomic, strong) TLContentViewController *contentViewController;
@property (nonatomic, strong) UIViewController *menuViewController;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravityBehaviour;

@end

@implementation TLContainmentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"contentViewController"]) {
        self.contentViewController = (TLContentViewController *)[segue.destinationViewController topViewController];
        self.contentViewController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"menuViewController"]) {
        self.menuViewController = segue.destinationViewController;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Import to call this only after our view hierarchy is set up
    [self setupContentViewControllerAnimatorProperties];
}

-(void)setupContentViewControllerAnimatorProperties {
    NSAssert(self.animator == nil, @"Animator is not nil – setupContentViewControllerAnimatorProperties likely called twice.");
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[self.contentViewController.view]];
    // Need to create a boundary that lies to the left of the left edge of the screen
    [collisionBehaviour addBoundaryWithIdentifier:@"leftEdge" fromPoint:CGPointMake(-1, CGFLOAT_MIN) toPoint:CGPointMake(-1, CGFLOAT_MAX)];
    [self.animator addBehavior:collisionBehaviour];
    
    self.gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[self.contentViewController.view]];
    self.gravityBehaviour.xComponent = -1.0f;
    self.gravityBehaviour.yComponent = 0.0f;
    [self.animator addBehavior:self.gravityBehaviour];
}

#pragma mark - TLContentViewControllerDelegate Methods

-(void)contentViewControllerDidPressBounceButton:(TLContentViewController *)viewController {
    NSLog(@"Bounce!");
}

#pragma mark - UIDynamicAnimatorDelegate Methods

- (void)dynamicAnimatorWillResume:(UIDynamicAnimator*)animator {
   
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator*)animator {
    
}

@end
