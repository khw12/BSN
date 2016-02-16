//
//  GraphView.m
//  BLE_Sensor
//
//  Plotting the data on graph
//
//  Created by Benny Lo on 31/01/2016.
//  Copyright © 2016 Benny Lo. All rights reserved.
//

#import "GraphView.h"

//constants defines the grid
#define GRID_START_Y        70.0
#define GRID_SPACE          32

#define GAP_BETWEEN_GRAPHS  5.0//space between each graph

CGColorRef CreateDeviceGrayColor(CGFloat w, CGFloat a){
    //create a gray color
    CGColorSpaceRef gray=CGColorSpaceCreateDeviceRGB();
    CGFloat comps[]={0,0,0,a};
    CGColorRef color=CGColorCreate(gray,comps);
    CGColorSpaceRelease(gray);
    return color;
}
CGColorRef CreateDeviceRGBColor(CGFloat r,CGFloat g, CGFloat b,CGFloat a){
    //create the color from RGB values
    CGColorSpaceRef rgb=CGColorSpaceCreateDeviceRGB();
    CGFloat comps[]={r,g,b,a};
    CGColorRef color=CGColorCreate(rgb,comps);
    CGColorSpaceRelease(rgb);
    return color;
}
CGColorRef graphBackgroundColor(){//background color of the graph
    static CGColorRef c=NULL;
    if (c==NULL) c=CreateDeviceGrayColor(0.6,1.0);
    return c;
}
CGColorRef graphLegendBackgroundColor(){//background color of the graph's legend
    static CGColorRef c=NULL;
    if (c==NULL) c=CreateDeviceRGBColor(0.3,0.3,0.3,1.0);
    return c;
}
CGColorRef graphLineColor(){//color of the grid lines
    static CGColorRef c=NULL;
    if (c==NULL) c=CreateDeviceRGBColor(0.5,0.5,0.5, 1.0);
    return c;
}
CGColorRef graphAxesColor(){//color of axes
    static CGColorRef c=NULL;
    if (c==NULL) c=CreateDeviceRGBColor(0.5,0,0.5, 1.0);
    return c;
}
CGColorRef graphXColor(){//color of the x-axis data
    static CGColorRef c=NULL;
    if (c==NULL) c=CreateDeviceRGBColor(1.0,0.0,0.0,1.0);
    return c;
}
CGColorRef graphYColor(){//color of the y-axis data
    static CGColorRef c=NULL;
    if (c==NULL) c=CreateDeviceRGBColor(0.0, 1.0, 0.0, 1.0);
    return c;
}
CGColorRef graphZColor(){//color of the z-axis data
    static CGColorRef c=NULL;
    if (c==NULL) c=CreateDeviceRGBColor(0.0, 0.0, 1.0, 1.0);
    return c;
}

CGColorRef graphCursorColor(){//color of the cursor
    static CGColorRef c=NULL;
    if (c==NULL) c=CreateDeviceRGBColor(1.0,1.0, 1.0, 1.0);
    return c;
}
CGFloat window_height()   {//find the height of the iOS device screen
    return [[UIScreen mainScreen] bounds].size.height;
}

CGFloat window_width()   {//find the width of the iOS device screen
     return [[UIScreen mainScreen] bounds].size.width;
}
@implementation GraphView
@synthesize graphtitle;//title of the graph
@synthesize graphwidth;//width and height of the graph view
@synthesize graphheight;
@synthesize xarray,yarray,zarray;//array of the sensor signals
@synthesize context;//context for drawing on the graph view
@synthesize curpos,curbufpos;//cursor
@synthesize xbuf,ybuf,zbuf;//buffer for scaling the data for plotting
@synthesize bufsize;//size of the buffer
@synthesize xmean,ymean,zmean,xvar,yvar,zvar;//mean and variance of the sensor data in 3 axes
@synthesize window_pos;//the vertial position of the graph view
@synthesize curx,cury,curz;//current position of pointer in buffer
@synthesize grid_start_y;//the y-origin of the grid
@synthesize total_no_graphs;//total number of graphs in the view
@synthesize novars;//no of variables for plotting
@synthesize maxrange;//max range of the variable
@synthesize initialised;
@synthesize receivedanything;
- (id)initWithFrame:(CGRect)frame
{   self = [super initWithFrame:frame];
    graphtitle =NULL;
    initialised=false;
    if (self!=nil) {
        // Initialization
    }
    return self;
}
//designated initialiser
-(id)initWithCoder:(NSCoder *)aDecoder
{//initialise the object
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    //initialise the variables
    curbufpos=0;
    xbuf=NULL;ybuf=NULL;zbuf=NULL;
    bufsize=1024;
    context=NULL;
    xmean=0;ymean=0;zmean=0;xvar=0;yvar=0;zvar=0;
    window_pos=0;
    curx=0;cury=0;curz=0;//set the current position of buffer pointers
    grid_start_y=GRID_START_Y;
    total_no_graphs=4;
    initialised=false;
    receivedanything=false;
   
    self=[super initWithCoder:aDecoder];
    if (self!=nil)
    {
        // [self commonInit];
    }
    return self;
}
-(void)dealloc
{//release the notification
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void) ConfigGraph:(NSString *)title nographs:(int)nographs window_pos:(int)pwindow_pos novars:(int)pnovars maxrange:(double)pmaxrange
{
    if (title)//set the title of the graph
        graphtitle=[[NSString alloc]initWithString:title];
    total_no_graphs=nographs;
    window_pos=pwindow_pos;//set the vertial position of the graph
    if (window_pos)
        grid_start_y=0;
    novars=pnovars;
    maxrange=pmaxrange;
//    [self reset];
}
- (void) orientationChanged:(NSNotification *)note
{//handle to orientation change
    UIDevice * device = note.object;
    [self reset];
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
            /* start special animation */
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            /* start special animation */
            break;
            
        default:
            break;
    };
}
//====================================================
- (void) DrawGridLines
{//draw the grid lines
    if (!context)return;
    if (!initialised)return;
    CGFloat pheight=(int32_t)((graphheight)/GRID_SPACE)*GRID_SPACE;
    for (int32_t y=grid_start_y;y<pheight;y+=GRID_SPACE)
    {
        CGContextMoveToPoint(context, 0, y);
        CGContextAddLineToPoint(context, graphwidth, y);
    }
    CGContextMoveToPoint(context, 0, pheight);
    CGContextAddLineToPoint(context, graphwidth, pheight);
    CGContextSetStrokeColorWithColor(context, graphLineColor());
    CGContextStrokePath(context);
    for (int32_t x=0;x<graphwidth;x+=GRID_SPACE)
    {
        CGContextMoveToPoint(context, x,grid_start_y);
        CGContextAddLineToPoint(context, x, pheight);
    }
    CGContextSetStrokeColorWithColor(context, graphLineColor());
    CGContextStrokePath(context);
    CGContextMoveToPoint(context, graphwidth/2,  grid_start_y);
    CGContextAddLineToPoint(context, graphwidth/2,  pheight);
    CGContextMoveToPoint(context, 0,  pheight/2);
    CGContextAddLineToPoint(context, graphwidth,  pheight/2);
    CGContextSetStrokeColorWithColor(context,graphAxesColor());
    CGContextSetLineWidth(context, 2.0);
    CGContextStrokePath(context);
    
    //-------------------------------------
    if (graphtitle)
    {//show the title of the graph
        NSString *text;
        text=[[NSString alloc]initWithString:graphtitle];
        NSDictionary *attr= @{
                              NSFontAttributeName:[UIFont fontWithName:@"Arial" size:12.0],
                              NSForegroundColorAttributeName:[UIColor whiteColor]
                              };
        CGSize fontWidth = [text sizeWithAttributes:attr];
        CGRect theRect=CGRectMake(graphwidth/2-fontWidth.width/2,grid_start_y,graphwidth,grid_start_y+fontWidth.height);
        
        [text drawInRect:theRect withAttributes:attr];
    }
}
- (void) ShowCurrentValues:(CGFloat) curdata axis:(NSString *)axis posy:(int)posy pcolor:(UIColor *)pcolor
{//show the current value of the sensor signal on legend
    if (!context)return;    if (!initialised)return;
    NSString *text;
    text=[[NSString alloc]initWithFormat:@"%@:%f",axis,curdata];
    NSDictionary *attr= @{
                          NSFontAttributeName:[UIFont fontWithName:@"Arial" size:12.0],
                          NSForegroundColorAttributeName:pcolor
                          };
    CGSize fontWidth = [text sizeWithAttributes:attr];
    CGRect theRect=CGRectMake(0,grid_start_y+posy*fontWidth.height,fontWidth.width,fontWidth.height);
    CGContextSetFillColorWithColor(context, graphLegendBackgroundColor());
    CGContextFillRect(context, theRect);
    [text drawInRect:theRect withAttributes:attr];
    
}
- (void) DrawLines:(CGFloat *)data pcolor:(CGColorRef)pcolor pmean:(CGFloat)pmean pvar:(CGFloat) pvar
{//plot a sensor signal - array of data
    CGFloat base=1.0;
    if (pvar !=0)base=pvar;
    if (!context) return;
    if (!initialised)return;
    CGFloat pdata=-data[0]/maxrange * graphheight+grid_start_y+graphheight/2.0;
    if (pdata <0)pdata=0;
    if (pdata>=graphheight)pdata=graphheight-1;
    CGContextMoveToPoint(context, 0,pdata);
    for (int x=0;x<graphwidth;x++)
    {
        CGFloat y=-data[x]/maxrange * graphheight+grid_start_y+graphheight/2;
        if (y<0) y=0;
        if (y>=graphheight)y=graphheight-1;
        CGContextAddLineToPoint(context, x, y);
    }
    CGContextSetStrokeColorWithColor(context, pcolor);
    CGContextStrokePath(context);
}

- (void) DrawCursor:(CGColorRef) pcolor
{//draw a cursor - white line on the graph
    if (!context) return;
    if (!initialised)return;
    CGContextMoveToPoint(context,curpos,0);
    CGContextAddLineToPoint(context,curpos, graphheight);
    CGContextSetStrokeColorWithColor(context, pcolor);
    CGContextStrokePath(context);
}

//====================================================

-(void)addX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z
{//add a point to the array
        if (!initialised)return;
    @try {
        if (xarray == NULL) return;
        xarray[curpos]=x;        yarray[curpos]=y;        zarray[curpos]=z;
        curx=x;cury=y;curz=z;
        curpos++;
        if (curpos>=graphwidth) curpos=0;
        receivedanything=true;
        [self setNeedsDisplay];//refresh the graph
    }
    @catch (NSException *exception)
    {
        NSLog(@"exception");
    }
}
- (void)reset
{//reset the graph
    context=UIGraphicsGetCurrentContext() ;
    if (!context) return;
    //fill in the background
    CGContextSetFillColorWithColor(context, graphBackgroundColor());
    CGContextFillRect(context, self.bounds);
    graphwidth=self.bounds.size.width;
    graphheight=self.bounds.size.height;
    //allocate the memory for sensor data arrays
    free(xarray);free(yarray);free(zarray);
    free(xbuf);free(ybuf);free(zbuf);
    xarray=malloc(sizeof(CGFloat)*graphwidth);
    yarray=malloc(sizeof(CGFloat)*graphwidth);
    zarray=malloc(sizeof(CGFloat)*graphwidth);
    xbuf=malloc(sizeof(CGFloat)*bufsize);
    ybuf=malloc(sizeof(CGFloat)*bufsize);
    zbuf=malloc(sizeof(CGFloat)*bufsize);
    //initialise the buffers/arrays
    for (int i=0;i<graphwidth;i++)
    {
        xarray[i]=0;    yarray[i]=0;   zarray[i]=0;
        xbuf[i]=0;ybuf[i]=0;zbuf[i]=0;
    }
    curpos=0;
    curbufpos=0;
    [self setNeedsDisplay];//inform core animation to redraw the layer
}

-(void) drawRect:(CGRect)rect
{
    context=UIGraphicsGetCurrentContext() ;
    if (!context)return;
    //resize the graphs
    CGRect prect;
    prect=self.frame;
    prect.size.width=window_width();
    prect.origin.y=((window_height()-GAP_BETWEEN_GRAPHS*(total_no_graphs-1))/total_no_graphs)*window_pos+GAP_BETWEEN_GRAPHS*window_pos;
    prect.size.height=((window_height()-GAP_BETWEEN_GRAPHS*(total_no_graphs-1))/total_no_graphs);
    self.frame=prect;
    initialised=true;
    //fill in the background
    CGContextSetFillColorWithColor(context, graphBackgroundColor());
    CGContextFillRect(context, self.bounds);
    graphwidth=self.bounds.size.width;
    graphheight=self.bounds.size.height;
    if (xarray == NULL)
    {//allocate the memory for arrays
        xarray=malloc(sizeof(CGFloat)*graphwidth);
        yarray=malloc(sizeof(CGFloat)*graphwidth);
        zarray=malloc(sizeof(CGFloat)*graphwidth);
        xbuf=malloc(sizeof(CGFloat)*bufsize);
        ybuf=malloc(sizeof(CGFloat)*bufsize);
        zbuf=malloc(sizeof(CGFloat)*bufsize);
        for (int i=0;i<graphwidth;i++)
        {
            //        xarray[i]=200*sin(0.2*i);
            xarray[i]=0;
            yarray[i]=0;
            zarray[i]=0;
            xbuf[i]=0;ybuf[i]=0;zbuf[i]=0;
        }
        curpos=0;
        curbufpos=0;
        receivedanything=false;
    }
    
    [self DrawGridLines];//draw grid lines
    
    if (!receivedanything) return;
    if (novars==1)
    {
        [self DrawLines:xarray pcolor:graphXColor() pmean:xmean pvar:xvar];//plot the sensor signals
        [self ShowCurrentValues:curx axis:@"v" posy:0 pcolor:[UIColor redColor]]; //show the current values
    }
    else {//plot the sensor signals
        [self DrawLines:xarray pcolor:graphXColor() pmean:xmean pvar:xvar];
        [self DrawLines:yarray pcolor:graphYColor() pmean:ymean pvar:yvar];
        [self DrawLines:zarray pcolor:graphZColor() pmean:zmean pvar:zvar];
         //show the current values
        [self ShowCurrentValues:curx axis:@"x" posy:0 pcolor:[UIColor redColor]];
        [self ShowCurrentValues:cury axis:@"y" posy:1 pcolor:[UIColor greenColor]];
        [self ShowCurrentValues:curz axis:@"z" posy:2 pcolor:[UIColor blueColor]];
    }
    //draw a cursor on the screen
    [self DrawCursor:graphCursorColor()];
}

@end
