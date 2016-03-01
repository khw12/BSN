//
//  PaintingViewController.m
//  BLE_Sensor
//
//  Created by Kuo Hern Wong on 3/1/16.
//  Copyright © 2016 Benny Lo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaintingViewController.h"

@implementation PaintingViewController

- (void)viewDidLoad
{//initialise the objects
    
    self.view.frame = CGRectMake(10,10, 200, 200);
    UIImageView *imageview = [[UIImageView alloc] init];
    imageview.frame = CGRectMake(10,10, 200, 200);
    UIImage *myimg = [UIImage imageNamed:@"image.jpg"];
    
    imageview.image=myimg;
    imageview.frame = CGRectMake(50, 50, 200, 200); // pass your frame here
    [self.view addSubview:imageview];
    
    UINavigationController *navController = self.navigationController;
}

@end