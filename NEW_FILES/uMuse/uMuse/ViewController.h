//
//  ViewController.h
//  uMuse
//
//  Created by Christopher Mower on 06/03/2016.
//  Copyright © 2016 ChrisKuoApp.uk.ac.imperial.ChrisKuoApp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController : UIViewController

// basic viewing stuff
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *endButton;
@property (weak, nonatomic) IBOutlet UILabel *appModeLabel;
@property (weak, nonatomic) IBOutlet UILabel *xpos;
@property (weak, nonatomic) IBOutlet UILabel *ypos;
@property (weak, nonatomic) IBOutlet UIImageView *applogo;

// image stuff
@property (weak, nonatomic) IBOutlet UIImageView *imageViewer;
@property (weak, nonatomic) IBOutlet UILabel *imageTitle;
@property (weak, nonatomic) IBOutlet UILabel *painterName;
@property (weak, nonatomic) IBOutlet UITextView *imageInfo;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;

// suggestion stuff
@property (weak, nonatomic) IBOutlet UIButton *suggestionButton;
@property (weak, nonatomic) IBOutlet UIButton *suggestButton;
@property (weak, nonatomic) IBOutlet UILabel *suggestionLabel;

// sensor stuff
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong,nonatomic)NSMutableArray *BLEdevices;//the array of BLE devices
@property (strong,nonatomic)NSMutableArray *BLEservices;//array of all services provided by the peripheral
@property (strong, nonatomic) CBPeripheral *connectedPeripheral;//pointer to the connected periperhal
@property (strong,nonatomic)NSMutableArray *BLEcharacteristics;//array of all characteristics

@end

