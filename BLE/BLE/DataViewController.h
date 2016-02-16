//
//  DataViewController.h
//  BLE
//
//  Created by Kuo Hern Wong on 2/9/16.
//  Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
@property (strong, nonatomic) id dataObject;

@end
