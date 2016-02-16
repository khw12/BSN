//
//  MySensorDataViewController.h
//  BLE_Sensor
//
// View Controller to plot hte data on graphs
//
//  Created by Benny Lo on 30/01/2016.
//  Copyright © 2016 Benny Lo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "GraphView.h"
@interface MySensorDataViewController : UIViewController
@property (nonatomic, strong) IBOutlet GraphView *graph;    //graph for accelerometer readings
@property (nonatomic, strong) IBOutlet GraphView *graph1;   //graph for gyroscope readings
@property (nonatomic, strong) IBOutlet GraphView *graph2;   //graph for magnetometer readings
@property (nonatomic, strong) IBOutlet GraphView *graph3;   //graph for temperature readings
@property (nonatomic, strong) IBOutlet GraphView *graph4;   //graph for dust readings
@property (nonatomic,strong)CBCharacteristic *LED_characteristic; //pointer to the characteristic of the LEDs
@property (strong, nonatomic) CBPeripheral *connectedPeripheral;//pointer to the peripheral
@property (nonatomic) bool yellowLED,greenLED;//flags for the LEDs
@property (nonatomic) int total_no_graphs;//total number of graphs in the view
@property (nonatomic) int showAccel,showGyro,showMag,showTemp,showDust;//show the signals
- (void) UpdateAccelData:(float)x y:(float) y z:(float)z;//add an accelerometer reading
- (void) UpdateGyroData:(float)x y:(float) y z:(float)z;//add a gyroscope reading
- (void) UpdateMagData:(float)x y:(float) y z:(float)z;//add a magnetometer reading
- (void) UpdateTempData:(float)t;//add a temperature reading
- (void) UpdateDustData:(float)d;//add a temperature reading
- (void) setLED_characteristic:(CBCharacteristic *)pLED_characteristic peripherial:(CBPeripheral*)peripheral;
@end
