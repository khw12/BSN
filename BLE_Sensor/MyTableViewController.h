//
//  MyTableViewController.h
//
//  BLE_Scan
//  Table view - list of BLE devices in proximity
//
//  Created by Benny Lo on 26/01/2016.
//  Copyright © 2016 Benny Lo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLE_Services.h"

@interface MyTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *StartButton;//the pointer to the 'Start' button
@property (strong,nonatomic)NSMutableArray *BLEdevices;//the array of BLE devices
@property (strong, nonatomic) CBPeripheral *connectedPeripheral;//pointer to the connected periperhal
@property (strong,nonatomic)NSMutableArray *BLEservices;//array of all services provided by the peripheral
@property (strong,nonatomic)NSMutableArray *BLEcharacteristics;//array of all characteristics 
@end
