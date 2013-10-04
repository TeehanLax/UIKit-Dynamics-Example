//
//  TLContainmentViewController.m
//  UIKit-Dynamics-Example
//
//  Created by Ash Furrow on 2013-07-09.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLContainmentViewController.h"
#import "TLContentViewController.h"

#import <QuartzCore/QuartzCore.h>

@interface TLContainmentViewController () <TLContentViewControllerDelegate, UIDynamicAnimatorDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UIView *contentView;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *leftScreenEdgeGestureRecognizer;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *rightScreenEdgeGestureRecognizer;

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

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Important to call this only after our view is on screen (ie: we can trust the view geometry).
    [self setupContentViewControllerAnimatorProperties];
    
    self.contentView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.contentView.layer.shadowOpacity = 1.0f;
    self.contentView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.contentView.bounds] CGPath];
    self.contentView.layer.shadowOffset = CGSizeZero;
    self.contentView.layer.shadowRadius = 5.0f;
}

-(void)setupContentViewControllerAnimatorProperties {
    NSAssert(self.animator == nil, @"Animator is not nil – setupContentViewControllerAnimatorProperties likely called twice.");
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[self.contentView]];
    // Need to create a boundary that lies to the left off of the right edge of the screen.
    [collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, 0, 0, -280)];
    [self.animator addBehavior:collisionBehaviour];
    
    self.gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[self.contentView]];
    self.gravityBehaviour.gravityDirection = CGVectorMake(-1, 0);
    [self.animator addBehavior:self.gravityBehaviour];
    
    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.contentView] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.magnitude = 0.0f;
    self.pushBehavior.angle = 0.0f;
    [self.animator addBehavior:self.pushBehavior];
    
    UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[self.contentView]];
    itemBehaviour.elasticity = 0.45f;
    [self.animator addBehavior:itemBehaviour];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"contentViewController"]) {
        TLContentViewController *contentViewController = (TLContentViewController *)[segue.destinationViewController topViewController];
        contentViewController.delegate = self;
    }
}

#pragma mark - UIGestureRecognizerDelegate Methods

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.leftScreenEdgeGestureRecognizer && self.isMenuOpen == NO) {
        return YES;
    }
    else if (gestureRecognizer == self.rightScreenEdgeGestureRecognizer && self.isMenuOpen == YES) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Gesture Recognizer Methods

-(void)handleScreenEdgePan:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self.view];
    location.y = CGRectGetMidY(self.contentView.bounds);
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self.animator removeBehavior:self.gravityBehaviour];
        
        self.panAttachmentBehaviour = [[UIAttachmentBehavior alloc] initWithItem:self.contentView attachedToAnchor:location];
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
            
            self.gravityBehaviour.gravityDirection = CGVectorMake(1, 0);
        }
        else {
            // Close menu
            self.menuOpen = NO;
            
            self.gravityBehaviour.gravityDirection = CGVectorMake(-1, 0);
        }
        
        [self.animator addBehavior:self.gravityBehaviour];
        
        self.pushBehavior.pushDirection = CGVectorMake(velocity.x / 10.0f, 0);
        self.pushBehavior.active = YES;
    }
}

#pragma mark - TLContentViewControllerDelegate Methods

-(void)contentViewControllerDidPressBounceButton:(TLContentViewController *)viewController {
    self.pushBehavior.pushDirection = CGVectorMake(35.0f, 0.0f);
    // active is set to NO once the instantaneous force is applied. All we need to do is reactivate it on each button press.
    self.pushBehavior.active = YES;
}

#pragma mark - UIDynamicAnimatorDelegate Methods

- (void)dynamicAnimatorWillResume:(UIDynamicAnimator*)animator {
   
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator*)animator {
    
}

@end
