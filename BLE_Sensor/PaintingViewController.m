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
CBCentralManager *centralManager;//BLE central manager - scanning BLE devices
NSArray *painting;
@synthesize  BLEdevices;//the array of BLE devices
bool isNearPainting;
NSNumber *timeStampStartAway;
NSNumber *timeStampSinceAway;

- (void)viewDidLoad
{//initialise the objects
    
    self.view.frame = CGRectMake(10,10, 200, 200);
    UIImageView *imageview = [[UIImageView alloc] init];
    imageview.frame = CGRectMake(10,10, 200, 200);
    UIImage *myimg = [UIImage imageNamed:@"image.jpg"];
    
    imageview.image=myimg;
    imageview.frame = CGRectMake(50, 50, 200, 200); // pass your frame here
    [self.view addSubview:imageview];
    
    BLEdevices = [[NSMutableArray alloc]init];//initialise the list of devices
    painting = [[NSArray alloc] initWithObjects:@"4",@"1",nil];
    
    centralManager =[[CBCentralManager alloc] initWithDelegate:(id)self queue:nil];//iniitliase the BLE central manager
    [centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    isNearPainting = true;
}

- (void) centralManagerDidUpdateState:(CBCentralManager *)central{
    //the BLE central manager state is updated
    if (central.state!=CBCentralManagerStatePoweredOn )//if it has been switched off
        return;
    else {//scan
        
    }
}

#pragma mark - BLE central manager
//=====================================================================
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{//discovered a peripheral
    //search to see if the device is already on the list
    for (int i=0;i<[BLEdevices count];i++)
    {
        BLE_Device *item=[BLEdevices objectAtIndex:i];
        if ([item.identifier isEqualToString:[peripheral.identifier UUIDString]])
        {//already in the list
            if (RSSI.intValue<=0)
            {
                item.RSSI=RSSI;//update RSSI
            }
            [self find3NearestSensor];
            return;
        }
    }
    
    if ([peripheral.name length] >= 7 && [[peripheral.name substringToIndex:7] isEqualToString:@"BSN-IoT"]) {
        //a new device is found -> add to the list
        BLE_Device *item1=[[BLE_Device alloc] init];
        item1.deviceName= peripheral.name;
        item1.identifier=[peripheral.identifier UUIDString];
        item1.peripheral=peripheral;
        item1.RSSI=RSSI;
        [BLEdevices addObject:item1];
        [self find3NearestSensor];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{//fail to connect to a peripheral
    NSLog(@"Failed to connect");
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{//a peripheral is connected
    NSLog(@"Connected");
    [centralManager stopScan];
    
    peripheral.delegate=(id)self;
    [peripheral discoverServices:[[NSArray alloc]initWithObjects:[CBUUID UUIDWithString:BSN_IoT],[CBUUID UUIDWithString:BLE_UUID_DEVICE_INFORMATION], nil]];//discover only the IMU service
}

//compute distance given n, R1 and RSSI of sensor
- (double) computeDistance:(double)n :(double)R1 :(double)RSSI {
    double diffR = R1 - RSSI;
    diffR /= (10 * n);
    return pow(10, diffR);
}

- (double) diffDistance:(NSArray *)point1 :(NSArray *)point2 {
    return sqrt(pow([point1[0] doubleValue] - [point2[0] doubleValue], 2) + pow([point1[1] doubleValue] - [point2[1] doubleValue], 2));
}

// find 3 nearest sensor to perform triangulation
- (void) find3NearestSensor {
    NSMutableArray *sensorArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [BLEdevices count]; i++) {
        BLE_Device *item=[BLEdevices objectAtIndex:i];
        if ([[item.identifier substringWithRange:NSMakeRange(0, 8)] isEqualToString:@"27FE3990"]) {
            item.location = [[NSArray alloc] initWithObjects:@"0",@"0",nil];
            item.n = -0.99;
            item.R1 = -92.3;
            item.distance = [self computeDistance:item.n :item.R1 :[item.RSSI doubleValue]];
            [sensorArray addObject:item];
        } else if ([[item.identifier substringWithRange:NSMakeRange(0, 8)] isEqualToString:@"B002CE6D"]) {
            item.location = [[NSArray alloc] initWithObjects:@"3",@"2",nil];
            item.n = -1.47;
            item.R1 = -92;
            item.distance = [self computeDistance:item.n :item.R1 :[item.RSSI doubleValue]];
            [sensorArray addObject:item];
        } else if ([[item.identifier substringWithRange:NSMakeRange(0, 8)] isEqualToString:@"63D045BC"]) {
            item.location = [[NSArray alloc] initWithObjects:@"6",@"0",nil];
            item.n = -1.16;
            item.R1 = -93.7;
            item.distance = [self computeDistance:item.n :item.R1 :[item.RSSI doubleValue]];
            [sensorArray addObject:item];
        } else if ([[item.identifier substringWithRange:NSMakeRange(0, 8)] isEqualToString:@"F164ED61"]) {
            item.location = [[NSArray alloc] initWithObjects:@"9",@"3",nil];
            item.n = -0.76;
            item.n = -94;
            item.distance = [self computeDistance:item.n :item.R1 :[item.RSSI doubleValue]];
            [sensorArray addObject:item];
        }
    }
    
    [sensorArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES]]];
    
    if ([sensorArray count] >= 3) {
        BLE_Device *item1 = sensorArray[0];
        BLE_Device *item2 = sensorArray[1];
        BLE_Device *item3 = sensorArray[2];
        [self computePosition: item1.distance :item1.location :item2.distance :item2.location :item3.distance :item3.location];
    }
}

//compute position given distance from S1, S2, S3 and S4. 3 out of 4 would be enough.
- (NSArray *) computePosition:(double)D1 :(NSArray *)S1 :(double)D2 :(NSArray *)S2 :(double)D3 :(NSArray *)S3{
    double x1 = [S1[0] doubleValue];
    double y1 = [S1[1] doubleValue];
    double x2 = [S2[0] doubleValue];
    double y2 = [S2[1] doubleValue];
    double x3 = [S3[0] doubleValue];
    double y3 = [S3[1] doubleValue];
    double alpha = pow(x1, 2) + pow(y1, 2) - pow(D1, 2);
    double beta = pow(x2, 2) + pow(y2, 2) - pow(D2, 2);
    double gamma = pow(x3, 2) + pow(y3, 2) - pow(D3, 2);
    NSMutableArray *position = [NSMutableArray array];
    double top = (alpha * (y3 - y2)) + (beta * (y1 - y3)) + (gamma * (y2 - y1));
    double total = top / (2 * ((x1 * (y3 - y2)) + (x2 * (y1 - y3)) + (x3 * (y2 - y1))));
    [position insertObject:[NSNumber numberWithDouble:total] atIndex:0];
    top = alpha*(x3 - x2) + beta*(x1 - x3) + gamma*(x2 - x1);
    total = top / (2 * ((y1 * (x3 - x2)) + (y2 * (x1 - x3)) + (y3 * (x2 - x1))));
    [position insertObject:[NSNumber numberWithDouble:total] atIndex:1];
    //NSNumberFormatter *fmt = [[NSNumberFormatter alloc ]] // *** EDIT HERE ***
    NSNumber * XposNS = [position objectAtIndex:0];
    NSNumber * YposNS = [position objectAtIndex:1];
    double Xpos, Ypos;
    Xpos = [XposNS doubleValue];
    Ypos = [YposNS doubleValue];
    
    double distance = [self diffDistance:position :painting];
    if (distance > 0.5) {
        if (isNearPainting) {
            timeStampStartAway = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
            isNearPainting = false;
        } else {
            timeStampSinceAway = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
            timeStampSinceAway = [NSNumber numberWithDouble:[timeStampSinceAway doubleValue] - [timeStampStartAway doubleValue]];
            if ([timeStampSinceAway doubleValue] >= 30000) {
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController *viewController = [sb instantiateViewControllerWithIdentifier: @"MyTableViewController"];
                [self presentModalViewController:viewController animated:YES];
            }
        }
    } else if (!isNearPainting) {
        isNearPainting = true;
    }
    return position;
}



@end