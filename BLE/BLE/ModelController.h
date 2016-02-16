//
//  ModelController.h
//  BLE
//
//  Created by Kuo Hern Wong on 2/9/16.
//  Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataViewController;

@interface ModelController : NSObject <UIPageViewControllerDataSource>

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(DataViewController *)viewController;

@end
