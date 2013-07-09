//
//  TLContentViewController.m
//  UIKit-Dynamics-Example
//
//  Created by Ash Furrow on 2013-07-09.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLContentViewController.h"

@interface TLContentViewController ()

@end

@implementation TLContentViewController

-(IBAction)userPressedBounceButton:(id)sender {
    [self.delegate contentViewControllerDidPressBounceButton:self];
}

@end
