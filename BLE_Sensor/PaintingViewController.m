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
    UIImageView *imageview = [[UIImageView alloc] init];
    UIImage *myimg = [UIImage imageNamed:@"image.jpg"];
    imageview.image=myimg;
    imageview.frame = CGRectMake(50, 50, 140, 105); // pass your frame here
    [self.view addSubview:imageview];
}

@end