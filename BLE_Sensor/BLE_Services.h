//
//  BLE_Services.h
//  BLE_Sensor
//
//  Created by Benny Lo on 30/01/2016.
//  Copyright © 2016 Benny Lo. All rights reserved.
//

#ifndef BLE_Services_h
#define BLE_Services_h
#define TRANSFER_SERVICE_UUID           @"FB694B90-F49E-4597-8306-171BBA78F846"
#define TRANSFER_CHARACTERISTIC_UUID    @"EB6727C4-F184-497A-A656-76B0CDAC633A"

//--------------------------------------------
//BLE defined services
#define BLE_UUID_ALERT_NOTIFICATION         @"1811"
#define BLE_UUID_BATTERY_SERVICE            @"180F"
#define BLE_UUID_BLOOD_PRESSURE             @"1810"
#define BLE_UUID_BODY_COMPPOSITION          @"181B"
#define BLE_UUID_GLUCOSE_CONTINUOUS         @"181F"
#define BLE_UUID_CURRENT_TIME               @"1805"
#define BLE_UUID_CYCLING_POWER              @"1818"
#define BLE_UUID_CYCLING_SPEED_CADENCE      @"1816"
#define BLE_UUID_DEVICE_INFORMATION         @"180A"
#define BLE_UUID_ENVIRONMENT_SENSING        @"181A"
#define BLE_UUID_GENERIC_ACCESS             @"1800"
#define BLE_UUID_GENERIC_ATTRIBUTE          @"1801"
#define BLE_UUID_GLUCOSE                    @"1808"
#define BLE_UUID_HEALTH_THERMOMETER         @"1809"
#define BLE_UUID_HEART_RATE                 @"180D"
#define BLE_UUID_HUMAN_INTERFACE_DEVICE     @"1812"
#define BLE_UUID_IMMEDIATE_ALERT            @"1802"
#define BLE_UUID_INTERNET_PROTOCOL_SUPPORT  @"1820"
#define BLE_UUID_LINK_LOSS                  @"1803"
#define BLE_UUID_LOCATION_AND_NAVIGATION    @"1819"
#define BLE_UUID_NEXT_DST_CHANGE_SERVICE    @"1807"
#define BLE_UUID_PHONE_ALERT_STATUS_SERVICE @"180E"
#define BLE_UUID_REFERENCE_TIME_UPDATE      @"1806"
#define BLE_UUID_RUNNING_SPEED_CADENCE      @"1814"
#define BLE_UUID_SCAN_PARAMETERS            @"1813"
#define BLE_UUID_TX_POWER                   @"1804"
#define BLE_UUID_USER_DATA                  @"181C"
#define BLE_UUID_WEIGHT_SCALE               @"181D"
//-------------------------------------------------
//BLE Characteristics - Heart rate
#define BLE_CHAR_HEART_RATE_MEASURE         @"2A37" //send a heart rate measurement
#define BLE_CHAR_BODY_SENSOR_LOCATION       @"2A38" //intended location of the heart rate measurement
#define BLE_CHAR_HEART_RATE_CONTROL_POINT   @"2A39" //enable a client to write control points to a server to control behaviour
//BLE Characteristics - Battery level
#define BLE_CHAR_BATTERY_LEVEL              @"2A19" //current charge level of the battery
//BLE Characteristics - Device Information
#define BLE_CHAR_MANUFACTURER_NAME          @"2A29" //UTF-8 string -> manufacturer's name
#define BLE_CHAR_MODEL_NUMBER               @"2A24" //model number of the device
#define BLE_CHAR_SERIAL_NUMBER              @"2A25" //serial number of hte devcie
#define BLE_CHAR_HARDWARE_REVISION          @"2A27" //hardware revision
#define BLE_CHAR_FIRMWARE_REVISION          @"2A26" //firmware revision
#define BLE_CHAR_SOFTWARE_REVISION          @"2A28" //Software revision
#define BLE_CHAR_SYSTEM_ID                  @"2A23" ///System ID
#define BLE_CHAR_IEEE11073_20601            @"2A2A" //IEEE 11073-20601 Regulatory certification data list
#define BLE_CHAR_PHP_ID                     @"2A50" //set of values which used to create unique service ID

//-------------------------------
//Benny's service
#define BSN_IoT                          @"47442014-0F63-5B27-9122-728099603712"
#define BSN_IoT_CHAR_ACCEL               @"47442015-0F63-5B27-9122-728099603712"
#define BSN_IoT_CHAR_GYRO                @"47442016-0F63-5B27-9122-728099603712"
#define BSN_IoT_CHAR_MAG                 @"47442017-0F63-5B27-9122-728099603712"
#define BSN_IoT_CHAR_TEMP                @"47442018-0F63-5B27-9122-728099603712"
#define BSN_IoT_CHAR_HUMIDITY            @"47442019-0F63-5B27-9122-728099603712"
#define BSN_IoT_CHAR_LED                 @"4744201A-0F63-5B27-9122-728099603712"
#define BSN_IoT_CHAR_SCREENTIMEMESSAGE   @"4744201B-0F63-5B27-9122-728099603712"
#define BSN_IoT_CHAR_IBEACON             @"4744201C-0F63-5B27-9122-728099603712"
#define BSN_IoT_CHAR_DUST                @"4744201D-0F63-5B27-9122-728099603712"


#endif /* BLE_Services_h */
