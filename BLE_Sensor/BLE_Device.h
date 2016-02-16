//
//  BLE_Device.h
//  BLE_Scan
//
//  Object to encapsulate the details about the BLE device
//
//  Created by Benny Lo on 26/01/2016.
//  Copyright © 2016 Benny Lo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BLE_Device : NSObject
@property NSString *deviceName; //Name of the BLE device
@property NSString *identifier; //The unique ID of the device
@property NSNumber *RSSI;       //The RSSI value
@property CBPeripheral *peripheral;//pointer to the BLE perherial 
@end
