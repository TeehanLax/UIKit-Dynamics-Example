//
//  TLContainmentViewController.m
//  UIKit-Dynamics-Example
//
//  Created by Ash Furrow on 2013-07-09.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLContainmentViewController.h"
#import "TLContentViewController.h"

@interface TLContainmentViewController () <TLContentViewControllerDelegate>

@property (nonatomic, strong) TLContentViewController *contentViewController;
@property (nonatomic, strong) UIViewController *menuViewController;

@end

@implementation TLContainmentViewController

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
	// Do any additional setup after loading the view.
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

#pragma mark - TLContentViewControllerDelegate Methods

-(void)contentViewControllerDidPressBounceButton:(TLContentViewController *)viewController {
    NSLog(@"Bounce!");
}

@end
