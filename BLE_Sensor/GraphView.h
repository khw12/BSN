//
//  GraphView.h
//  BLE_Sensor
//
// Graph View for plotting the signals o
//
//  Created by Benny Lo on 31/01/2016.
//  Copyright © 2016 Benny Lo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphView : UIView
@property (nonatomic)CGFloat graphwidth,graphheight;//width and height of the graph
@property (nonatomic, strong) NSString *graphtitle;//title of the graph
@property (nonatomic)CGFloat *xarray;//data of the x-axis
@property (nonatomic)CGFloat *yarray;//data of the y-axis
@property (nonatomic)CGFloat *zarray;//data of the z-axis
@property (nonatomic) CGContextRef context;//context for drawing
@property (nonatomic) int32_t curpos,curbufpos;//position of cursor
@property (nonatomic) CGFloat *xbuf,*ybuf,*zbuf;//buffer for scaling hte data
@property (nonatomic) int32_t bufsize;//buffer size
@property (nonatomic) CGFloat xmean,ymean,zmean,xvar,yvar,zvar;//the mean and variance of the signa;s
@property (nonatomic) int window_pos;//y-position of the graph view
@property (nonatomic) CGFloat curx,cury,curz;//current position of buffer for the current value
@property (nonatomic) int grid_start_y;//the start of the grid
@property (nonatomic) int total_no_graphs;//total number of graphs in the view
@property (nonatomic) int novars;//no of variables to plot
@property (nonatomic) double maxrange;//maximum range of the variable
@property (nonatomic) bool initialised;
@property (nonatomic) bool receivedanything;
- (void)addX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z;//the function for plotting the data
-(void)reset;//reset the graph
- (void) ConfigGraph:(NSString *)title nographs:(int)nographs window_pos:(int)pwindow_pos novars:(int)pnovars maxrange:(double)pmaxrange;//set the title of the window, no of graphs in view and the vertial position of the graph view
@end
