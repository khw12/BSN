//
//  MyTableViewController.m
//  BLE_Scan
//
//  Table view - list of BLE devices in proximity
//
//  Created by Benny Lo on 26/01/2016.
//  Copyright © 2016 Benny Lo. All rights reserved.
//
#import <CoreBluetooth/CoreBluetooth.h>
#import "MyTableViewController.h"
#import "BLE_Device.h"
#import "MySensorDataViewController.h"
#import "BLE_Services.h"

#define CONFIG_FILE_NAME @"config.csv"

@implementation MyTableViewController
@synthesize StartButton;//the pointer to the 'Start' button
@synthesize  BLEdevices;//the array of BLE devices
@synthesize BLEcharacteristics;//array of BLE characteristics
@synthesize connectedPeripheral;//pointer to the connected peripheral
@synthesize BLEservices;//the array of BLE services
CBCentralManager *centralManager;//BLE central manager - scanning BLE devices
bool startScan; //flag to indiciate whether or not the program is scanning for BLE devices
MySensorDataViewController *destViewController;//pointer to the sensor data view controller (graphs)
float accelx,accely,accelz;//variable for storing the current accelerometer values
float gyrox,gyroy,gyroz;//variable for storing the current gyroscope values
float magx,magy,magz;//variable for storing the current magnetometer values
float temperature;//variable for storing the current temperature values
float dust=0;//variable for storing the current dust value
NSString *filepath=NULL;//file path for storing data
bool storedatainfile=true;//store data in file
bool showAccel=true,showGyro=true,showMag=true,showTemp=true,showDust=false;//flags to show sensor signals

NSArray *painting;
bool isNearPainting;
NSNumber *timeStartNearPainting;
NSNumber *timeStampSinceNearPainting;
bool viewingPainting;

- (void)viewDidLoad
{//initialise the objects
    [super viewDidLoad];
    startScan=false;
    centralManager =[[CBCentralManager alloc] initWithDelegate:(id)self queue:nil];//iniitliase the BLE central manager
    BLEdevices = [[NSMutableArray alloc]init];//initialise the list of devices
    BLEservices=[[NSMutableArray alloc]init];//initialise the list of BLE services
    BLEcharacteristics=[[NSMutableArray alloc]init];//initialise the list of characteristics
    connectedPeripheral=nil;
    //create a file name based on the time of hte date
    UInt32 pdate=[[NSDate date] timeIntervalSince1970];
    NSString *filename=[NSString stringWithFormat:@"Sensor_data_%ld.csv",(unsigned long)pdate];
    filepath=[self GetFilePath:filename];
    
    painting = [[NSArray alloc] initWithObjects:@"4",@"1",nil];
    isNearPainting = false;
    viewingPainting = false;
}

-(void) cleanup
{//disconnect the peripheral
    //See if we are subscribed to a characteristic on the peripheral
    if (connectedPeripheral==nil) return;//if nothing is connected -> quit
    if (connectedPeripheral.services!=nil)
    {
        for (CBService *service in connectedPeripheral.services)
        {//disconnect all services
            if (service.characteristics!=nil)
            {//disconnect all characteristics
                for (CBCharacteristic *characteristic in service.characteristics){
                    if (characteristic.isNotifying)
                    {//disable the notification of the characteristic
                        [connectedPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                        return;
                    }
                }
            }
        }
    }
    [centralManager cancelPeripheralConnection:connectedPeripheral];//cancel the connection to the peripheral
}
- (void) centralManagerDidUpdateState:(CBCentralManager *)central{
    //the BLE central manager state is updated
    if (central.state!=CBCentralManagerStatePoweredOn )//if it has been switched off
        return;
    else {//scan
       
    }
}
#pragma mark - Table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
-(NSInteger)tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger)section
{//return the number of rows in the section
    return [BLEdevices count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{//show the text of the item on the table list
    static NSString *CellIdenifier=@"DeviceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdenifier forIndexPath:indexPath];//pointer  to the specific cell
    BLE_Device *pdevice=[self.BLEdevices objectAtIndex:indexPath.row];//pointer to the device in the list
    cell.textLabel.text=[NSString stringWithFormat:@"%@ (%@)[%@]",pdevice.deviceName,pdevice.RSSI,pdevice.identifier];//show the name of the device, its RSSI and the ID
    return cell;
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
                [BLEdevices removeObject:item];
                item.RSSI=RSSI;//update RSSI
                [BLEdevices insertObject:item atIndex:0];
                [self.tableView reloadData];
                
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
    [self.tableView reloadData];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{//fail to connect to a peripheral
    NSLog(@"Failed to connect");
    [self cleanup];
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{//a peripheral is connected
    NSLog(@"Connected");
    [centralManager stopScan];
    
    peripheral.delegate=(id)self;
    [peripheral discoverServices:[[NSArray alloc]initWithObjects:[CBUUID UUIDWithString:BSN_IoT],[CBUUID UUIDWithString:BLE_UUID_DEVICE_INFORMATION], nil]];//discover only the IMU service
}
#pragma mark - data parsing
- (float *)GetTemperatureData:(NSData *)pdata{
    //extract the temperature data from the received packet
    int16_t temp;
    char scratchVal[pdata.length];
    [pdata getBytes:&scratchVal length:pdata.length];
    temp=((scratchVal[1]&0xff)|((scratchVal[2]<<8)&0xff00));
    float *result=(float *) malloc(sizeof(float)*1);
    result[0]=temp/10.0;
    return result;
}
- (float *)GetDustData:(NSData *)pdata{
    //extract the PM2.5 data from the received packet
    int16_t pdust;
    char scratchVal[pdata.length];
    [pdata getBytes:&scratchVal length:pdata.length];
    pdust=((scratchVal[1]&0xff)|((scratchVal[2]<<8)&0xff00));
    float *result=(float *) malloc(sizeof(float)*1);
    result[0]=pdust;
    return result;
}
-(float *)GetSensorData:(NSData*)pdata{
    //extract the sensor data from the received packet
    int16_t x,y,z;
    char scratchVal[pdata.length];
    [pdata getBytes:&scratchVal length:pdata.length];
    x=((scratchVal[1]&0xff)|((scratchVal[2]<<8)&0xff00));
    y=((scratchVal[3]&0xff)|((scratchVal[4]<<8)&0xff00));
    z=((scratchVal[5]&0xff)|((scratchVal[6]<<8)&0xff00));
    float *result=(float *) malloc(sizeof(float)*3);
    result[0]=x;
    result[1]=y;
    result[2]=z;
    return result;
}

#pragma mark - Peripheral
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{//Finish discovering the services
    if (error)
    {
        [self cleanup];
        return;
    }
    //NSLog(@"Service discovered:%lu",(unsigned long)peripheral.services.count);
    for (CBService *service in peripheral.services)
    {
        [BLEservices addObject:service];//add to the service list
        CBService *pservice=nil;
        if ([service.UUID isEqual:[CBUUID UUIDWithString:BSN_IoT]])
                pservice=service;
        if (pservice)
        {
            [connectedPeripheral discoverCharacteristics:nil forService:pservice];
            destViewController.title=[NSString stringWithFormat:@"%@[%@]",peripheral.name,[peripheral.identifier UUIDString]];
            //            destViewController.characteristics=BLEcharacteristics;
        }

    }
}
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{//discorvered the characteristics of the service
    if (error)
    {  [self cleanup];return; }
    // NSLog(@"Discover characteristics");
    bool pshowaccel=false,pshowgyro=false,pshowmag=false,pshowtemp=false,pshowdust=false;
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        [BLEcharacteristics addObject:characteristic];//add the characteristic to the array
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BSN_IoT_CHAR_ACCEL]]||
            [characteristic.UUID isEqual:[CBUUID UUIDWithString:BSN_IoT_CHAR_GYRO]]||
            [characteristic.UUID isEqual:[CBUUID UUIDWithString:BSN_IoT_CHAR_MAG]]||
            [characteristic.UUID isEqual:[CBUUID UUIDWithString:BSN_IoT_CHAR_TEMP]]||
            [characteristic.UUID isEqual:[CBUUID UUIDWithString:BSN_IoT_CHAR_DUST]])
        {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];//tell the sensor that the App wants to read this characteristic values
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BSN_IoT_CHAR_DUST]])
                showDust=true;
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BSN_IoT_CHAR_LED]])
        {//set the pointers for the app to switch on/off the LEDs
            [destViewController setLED_characteristic:characteristic peripherial:peripheral];
        }
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{//an update of the notification state is received for a characteristic
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]])
    {
        return;
    }
    NSLog(@"didudpatenotification");
    if (characteristic.isNotifying)
    {
        NSLog(@"Notification began on %@",characteristic);
    }else {
        //notification is stopped
        [centralManager cancelPeripheralConnection:peripheral];
    }
}
#pragma mark - Characteristics
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{//a value of a characteristic is updated -> i.e. new sensor data received
    if (error)
    {
        NSLog(@"Error");
        return;
    }
    @try {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BSN_IoT_CHAR_ACCEL]])
        {
            float *value=[self GetSensorData:characteristic.value];
            accelx=value[0];
            accely=value[1];
            accelz=value[2];
            free(value);
           //store sensor data in file -> use iTune to retrieve the file
            if (storedatainfile)
            {
                UInt32 pdate=[[NSDate date] timeIntervalSince1970];
                NSString *pstr=[[NSString alloc] initWithFormat:@"%ld,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n",(unsigned long)pdate,accelx,accely,accelz,gyrox,gyroy,gyroz,magx,magy,magz,temperature,dust];
                [self AppendDataToFile:filepath firstline:"Time,AccelX,AccelY,AccelZ,GyroX,GyroY,GyroZ,MagX,MagY,MagZ,Temperature,PM2.5\n" line:pstr];
            }
            //plot data on graph
            if (destViewController) [destViewController UpdateAccelData:accelx y:accely z:accelz];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BSN_IoT_CHAR_GYRO]])
        {
            float *value=[self GetSensorData:characteristic.value];
            gyrox=value[0];  gyroy=value[1]; gyroz=value[2];
            free(value);
            if (destViewController) [destViewController UpdateGyroData:gyrox y:gyroy z:gyroz];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BSN_IoT_CHAR_MAG]])
        {
            float *value=[self GetSensorData:characteristic.value];
            magx=value[0];magy=value[1];  magz=value[2];
            free(value);
            if (destViewController) [destViewController UpdateMagData:magx y:magy z:magz];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BSN_IoT_CHAR_TEMP]])
        {
            float *value=[self GetTemperatureData:characteristic.value];
            if (value)
            {
                temperature=value[0];
                free(value);
               if (destViewController) [destViewController UpdateTempData:temperature];
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BSN_IoT_CHAR_DUST]])
        {
            float *value=[self GetDustData:characteristic.value];
            if (value)
            {
                dust=value[0];
                free(value);
                if (destViewController) [destViewController UpdateDustData:dust];
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CHAR_BATTERY_LEVEL]])
        {//reading battery level
            char scratchVal[characteristic.value.length];
            [characteristic.value getBytes:&scratchVal length:characteristic.value.length];
            NSLog(@"Battery level:%d",scratchVal[0]&0xff);
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CHAR_MANUFACTURER_NAME]])
        {//read the maufacturer name
            NSLog(@"Manufacturer:%@",characteristic.value);
        }
    }
    @catch (...)
    {
        NSLog(@"caught the exception");
    }
}
-(void)centralManager:(CBCentralManager*)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{//the peripheral is disconnected
    connectedPeripheral=nil;
    [centralManager scanForPeripheralsWithServices:nil options:nil];//start scanning for devices again
}
#pragma mark - Writing data to file
-(void)AppendDataToFile:(NSString *)filepath firstline:(char *) firstline line:(NSString *)line{
    //******************************************
    //Append to the end of file
    NSFileHandle *filehandle=[NSFileHandle fileHandleForWritingAtPath:filepath];
    if (filehandle ==nil)
    {//file does not exist -> so write to a new file
        NSData *pdata=[[NSData alloc]initWithBytes:firstline length:strlen(firstline)];
        [pdata writeToFile:filepath atomically:YES];
        filehandle=[NSFileHandle fileHandleForWritingAtPath:filepath];
    }
    //append to the end of the file
    [filehandle seekToEndOfFile];
    NSData *pdata=[line dataUsingEncoding:NSUTF8StringEncoding];
    [filehandle writeData:pdata];
    [filehandle closeFile];
    
}
-(NSString *)GetFilePath:(NSString *)filename{//get the file path for storing/retrieving data
    NSArray *dirPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir=[dirPaths objectAtIndex:0];
    NSString *result=[docsDir stringByAppendingPathComponent:filename];
    return result;
}


#pragma mark - Start/Stop Button
- (IBAction)StartScan:(id)sender {
    if (!startScan) {//start scanning the BLE devices
        startScan=true;
        [centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];//scan for all BLE devices
        NSLog(@"BLE Scan started");
        [StartButton setTitle:@"Stop"];
    }
    else {//stop scannign the devices
        startScan=false;
        [centralManager stopScan];//stop scanning for BLE devices
        NSLog(@"BLE Scan stopped");
        [BLEdevices removeAllObjects];//empty the device list
        [StartButton setTitle:@"Start"];//change the label of the button
        [BLEcharacteristics removeAllObjects];//empty the characteristic list
    }

}
#pragma mark - Device is selected
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{//an item on the table is selected
    if ([segue.identifier isEqualToString:@"ConnectDevice"])
    {//open the sensor data view control;er
        if (startScan)
        {
            startScan=false;
            [centralManager stopScan];//stop scanning for BLE devices
            NSLog(@"BLE Scan stopped");
            [StartButton setTitle:@"Start"];
        }
        [BLEservices removeAllObjects];//empty the device list
        NSIndexPath *indexPath=nil;
        destViewController=segue.destinationViewController;//pointer to the sensor data view controller
        destViewController.showAccel=(showAccel)?1:0;
        destViewController.showGyro=(showGyro)?1:0;
        destViewController.showMag=(showMag)?1:0;
        destViewController.showTemp=(showTemp)?1:0;
        destViewController.showDust=(showDust)?1:0;
        indexPath=[self.tableView indexPathForSelectedRow];//index to the device selected
        BLE_Device *pdevice=[BLEdevices objectAtIndex:indexPath.row];//point to the device selected
        [centralManager connectPeripheral:pdevice.peripheral options:nil];//connect to the peripheral
        connectedPeripheral=pdevice.peripheral;//set the pointer to the connected peripheral
    }
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
    self.locationLabel.text = [NSString stringWithFormat:@"Location = (%.2f,%.2f)", Xpos, Ypos];
    
    double distance = [self diffDistance:position :painting];
    if (distance <= 0.5) {
        if (isNearPainting) {
            timeStampSinceNearPainting = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
            if (timeStampSinceNearPainting.doubleValue >= 30000) {
                if (!viewingPainting) {
                    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    UIViewController *viewController = [sb instantiateViewControllerWithIdentifier: @"PaintingViewController"];
                    [self presentViewController:viewController animated:YES completion:nil];
                    viewingPainting = true;
                }
            }
        } else {
            timeStartNearPainting = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
            isNearPainting = true;
        }
    } else {
        if (isNearPainting) {
            isNearPainting = false;
        }
    }
    
    return position;
}

@end
