//
//  TLContentViewController.h
//  UIKit-Dynamics-Example
//
//  Created by Ash Furrow on 2013-07-09.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TLContentViewController;

@protocol TLContentViewControllerDelegate <NSObject>

-(void)contentViewControllerDidPressBounceButton:(TLContentViewController *)viewController;

@end

@interface TLContentViewController : UITableViewController

@property (nonatomic, weak) id<TLContentViewControllerDelegate> delegate;

@end
