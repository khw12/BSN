//
//  PaintingViewController.h
//  BLE_Sensor
//
//  Created by Kuo Hern Wong on 3/1/16.
//  Copyright © 2016 Benny Lo. All rights reserved.
//

#ifndef PaintingViewController_h
#define PaintingViewController_h


#endif /* PaintingViewController_h */

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLE_Services.h"
#import "BLE_Device.h"

@interface PaintingViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *cancel;
@property (strong,nonatomic)NSMutableArray *BLEdevices;//the array of BLE devices

@end
