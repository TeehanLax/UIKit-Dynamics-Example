//
//  TLContainmentViewController.m
//  UIKit-Dynamics-Example
//
//  Created by Ash Furrow on 2013-07-09.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLContainmentViewController.h"
#import "TLContentViewController.h"

@interface TLContainmentViewController () <TLContentViewControllerDelegate, UIDynamicAnimatorDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *leftScreenEdgeGestureRecognizer;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *rightScreenEdgeGestureRecognizer;

@property (nonatomic, strong) UINavigationController *contentNavigationViewController;
@property (nonatomic, strong) UIViewController *menuViewController;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravityBehaviour;
@property (nonatomic, strong) UIPushBehavior* pushBehavior;
@property (nonatomic, strong) UIAttachmentBehavior *panAttachmentBehaviour;

@property (nonatomic, assign, getter = isMenuOpen) BOOL menuOpen;

@end

@implementation TLContainmentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.leftScreenEdgeGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleScreenEdgePan:)];
    self.leftScreenEdgeGestureRecognizer.edges = UIRectEdgeLeft;
    self.leftScreenEdgeGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.leftScreenEdgeGestureRecognizer];
    
    self.rightScreenEdgeGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleScreenEdgePan:)];
    self.rightScreenEdgeGestureRecognizer.edges = UIRectEdgeRight;
    self.rightScreenEdgeGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.rightScreenEdgeGestureRecognizer];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"contentViewController"]) {
        self.contentNavigationViewController = segue.destinationViewController;
        
        TLContentViewController *contentViewController = (TLContentViewController *)[segue.destinationViewController topViewController];
        contentViewController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"menuViewController"]) {
        self.menuViewController = segue.destinationViewController;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Import to call this only after our view hierarchy is set up.
    [self setupContentViewControllerAnimatorProperties];
}

-(void)setupContentViewControllerAnimatorProperties {
    NSAssert(self.animator == nil, @"Animator is not nil – setupContentViewControllerAnimatorProperties likely called twice.");
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[self.contentNavigationViewController.view]];
    // Need to create a boundary that lies to the left off of the right edge of the screen.
    [collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, 0, 0, -280)];
    [self.animator addBehavior:collisionBehaviour];
    
    self.gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[self.contentNavigationViewController.view]];
    self.gravityBehaviour.xComponent = -1.0f;
    self.gravityBehaviour.yComponent = 0.0f;
    [self.animator addBehavior:self.gravityBehaviour];
    
    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.contentNavigationViewController.view] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.magnitude = 0.0f;
    self.pushBehavior.angle = 0.0f;
    [self.animator addBehavior:self.pushBehavior];
    
    UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[self.contentNavigationViewController.view]];
    itemBehaviour.elasticity = 0.45f;
    [self.animator addBehavior:itemBehaviour];
}

#pragma mark - UIGestureRecognizerDelegate Methods

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.leftScreenEdgeGestureRecognizer && self.isMenuOpen == NO) {
        return YES;
    }
    else if (gestureRecognizer == self.rightScreenEdgeGestureRecognizer == self.isMenuOpen == YES) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Gesture Recognizer Methods

-(void)handleScreenEdgePan:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self.view];
    location.y = CGRectGetMidY(self.contentNavigationViewController.view.bounds);
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self.animator removeBehavior:self.gravityBehaviour];
        
        self.panAttachmentBehaviour = [[UIAttachmentBehavior alloc] initWithItem:self.contentNavigationViewController.view attachedToAnchor:location];
        [self.animator addBehavior:self.panAttachmentBehaviour];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        self.panAttachmentBehaviour.anchorPoint = location;
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.animator removeBehavior:self.panAttachmentBehaviour], self.panAttachmentBehaviour = nil;
        
        CGPoint velocity = [gestureRecognizer velocityInView:self.view];
        
        if (velocity.x > 0) {
            // Open menu
            self.menuOpen = YES;
            
            self.gravityBehaviour.xComponent = 1.0f;
        }
        else {
            // Close menu
            self.menuOpen = NO;
            
            self.gravityBehaviour.xComponent = -1.0f;
        }
        
        [self.animator addBehavior:self.gravityBehaviour];
        
        [self.pushBehavior setXComponent:velocity.x/10.0f yComponent:0];
        self.pushBehavior.active = YES;
    }
}

#pragma mark - TLContentViewControllerDelegate Methods

-(void)contentViewControllerDidPressBounceButton:(TLContentViewController *)viewController {
    [self.pushBehavior setXComponent:35.0f yComponent:0.0f];
    // active is set to NO once the instantaneous force is applied. All we need to do is reactivate it on each button press.
    self.pushBehavior.active = YES;
}

#pragma mark - UIDynamicAnimatorDelegate Methods

- (void)dynamicAnimatorWillResume:(UIDynamicAnimator*)animator {
   
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator*)animator {
    
}

@end
