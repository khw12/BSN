//
//  MySensorDataViewController.m
//  BLE_Sensor
//
// View controller to plot the sensor data
//
//  Created by Benny Lo on 30/01/2016.
//  Copyright © 2016 Benny Lo. All rights reserved.
//

#import "MySensorDataViewController.h"
@implementation MySensorDataViewController
@synthesize graph;//graph to plot the acceleromter readings
@synthesize graph1;//graph to plot the gyroscope readings
@synthesize graph2;//graph to plot the magnetometer readings
@synthesize graph3;//graph to plot the temperature readings
@synthesize graph4;//graph to plot the PM2.5 readings
@synthesize yellowLED;//flag for controlling the yellow LED
@synthesize greenLED;//flag for controlling the green LED
@synthesize connectedPeripheral;//pointer to the peripheral
@synthesize LED_characteristic;//pointer to the LED characteristic
@synthesize total_no_graphs;//total no of graphs in the view
@synthesize showAccel,showGyro,showMag,showTemp,showDust;//flags to show/hide sensor signals
- (void)viewDidAppear:(BOOL)animated
{//set up the graphs and variables
    [super viewDidLoad];
    greenLED=false;
    yellowLED=false;
    total_no_graphs=showAccel+showGyro+showMag+showTemp+showDust;
    int pos=0;
    if (showAccel)
    {
        [graph setHidden:NO];
        [graph setIsAccessibilityElement:YES];
        [graph setAccessibilityLabel:NSLocalizedString(@"Graph", @"")];
        [graph ConfigGraph:@"Accelerometer" nographs:total_no_graphs window_pos:pos++ novars:3 maxrange:65536];
    }
    else {
        [graph setHidden:YES];
    }
    if (showGyro)
    {
        [graph1 setHidden:NO];
        [graph1 setIsAccessibilityElement:YES];
        [graph1 setAccessibilityLabel:NSLocalizedString(@"Graph", @"")];
        [graph1 ConfigGraph:@"Gyroscope" nographs:total_no_graphs window_pos:pos++ novars:3 maxrange:65536];
    }
    else [graph1 setHidden:YES];
    if (showMag)
    {
        [graph2 setHidden:NO];
        [graph2 setIsAccessibilityElement:YES];
        [graph2 setAccessibilityLabel:NSLocalizedString(@"Graph", @"")];
        [graph2 ConfigGraph:@"Magnetometer" nographs:total_no_graphs window_pos:pos++ novars:3 maxrange:65536];
    }
    else [graph2 setHidden:YES];
    if (showTemp)
    {
        [graph3 setHidden:NO];
        [graph3 setIsAccessibilityElement:YES];
        [graph3 setAccessibilityLabel:NSLocalizedString(@"Graph", @"")];
        [graph3 ConfigGraph:@"Temperature" nographs:total_no_graphs window_pos:pos++ novars:1 maxrange:50];
    }else [graph3 setHidden:YES];
    if (showDust)
    {
        [graph4 setHidden:NO];
        [graph4 setIsAccessibilityElement:YES];
        [graph4 setAccessibilityLabel:NSLocalizedString(@"Graph", @"")];
        [graph4 ConfigGraph:@"PM2.5" nographs:total_no_graphs window_pos:pos++ novars:1 maxrange:400];
    }else [graph4 setHidden:YES];
}

- (void) UpdateAccelData:(float)x y:(float) y z:(float)z
{//add a data to the accelerometer graph
    if (showAccel) [graph addX:x y:y z:z];
}
- (void) UpdateGyroData:(float)x y:(float) y z:(float)z
{//add a data point to the gyroscope graph
    if (showGyro)[graph1 addX:x y:y z:z];
}
- (void) UpdateMagData:(float)x y:(float) y z:(float)z
{//add a data point to the magnetometer graph
    if (showMag)[graph2 addX:x y:y z:z];
}
- (void) UpdateTempData:(float)t
{//add a data point to the temperature graph
    if (showTemp)[graph3 addX:t y:t z:t];
}
- (void) UpdateDustData:(float)t
{//add a data point to the temperature graph
    if (showDust)[graph4 addX:t y:t z:t];
}
- (void) setLED_characteristic:(CBCharacteristic *)pLED_characteristic peripherial:(CBPeripheral*)peripheral
{//set up the pointers to the peripheral and LED control characteristic
    LED_characteristic=pLED_characteristic;
    connectedPeripheral=peripheral;
}
- (IBAction)Green_LED:(id)sender {//green LED button is selected
    uint8_t pdata=0;
    greenLED=!greenLED;//toggle the green LED flag
    if (greenLED)pdata|=0x2;
    if (yellowLED)pdata|=1;
    [connectedPeripheral writeValue:[NSData dataWithBytes:&pdata length:1] forCharacteristic:LED_characteristic type:CBCharacteristicWriteWithResponse];//send the command to the sensor
}
- (IBAction)LED_switch:(id)sender {//yellow LED button is selected;
    uint8_t pdata = 0;
    yellowLED=!yellowLED;//toggle the yellow LED flag
    if (yellowLED)pdata|=0x1;
    if(greenLED)pdata|=0x2;
    [connectedPeripheral writeValue:[NSData dataWithBytes:&pdata length:1] forCharacteristic:LED_characteristic type:CBCharacteristicWriteWithResponse];//send the command to the sensor
}
@end
