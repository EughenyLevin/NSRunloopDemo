//
//  ViewController.m
//  Lab#8.2
//  Created by Evgheny on 29.11.16.
//  Copyright © 2016 Eugheny_Levin. All rights reserved.
//

#import "ViewController.h"
#import "LEBarrierView.h"

@interface ViewController ()
{
    BOOL contains;
}

@property (strong,nonatomic) UIView *myView1;
@property (strong,nonatomic) UIView *myView2;
@property (strong,nonatomic) UIView *myView3;

@property (strong,nonatomic) NSTimer *timer;
@property (strong,nonatomic) NSTimer *timer2;
@property (strong,nonatomic) NSTimer *timer3;

@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;

@property (strong,atomic) NSThread *thread1;
@property (strong,atomic) NSThread *thread2;
@property (strong,atomic) NSThread *thread3;

@property (strong,nonatomic)  LEBarrierView *barrier;
@property (weak, nonatomic) IBOutlet UIProgressView *progressFirstThread;
@property (weak, nonatomic) IBOutlet UIProgressView *progressSecondThreat;

@property (strong,atomic) NSLock *lock;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lock = [[NSLock alloc]init];
    [self.progressFirstThread setFrame:CGRectMake(-135, 290, 300, 25)];
   _progressFirstThread.transform = CGAffineTransformRotate(self.progressFirstThread.transform, 90.0/180*M_PI*3);
    _progressFirstThread.progress = 0.0;
    
    [self.progressSecondThreat setFrame:CGRectMake(158, 290, 300, 25)];
    _progressSecondThreat.transform = CGAffineTransformRotate(self.progressSecondThreat.transform, 90.0/180*M_PI*3);
    _progressSecondThreat.progress = 0.0;
 
    
    CGFloat margins = 10;
    _myView1 = [[UIView alloc]initWithFrame:CGRectMake(margins*2, CGRectGetMaxY(self.progressBar.frame)-105,120, 100)];
    _myView1.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_myView1];
    
    _myView2 = [[UIView alloc]initWithFrame:CGRectMake(margins*3+150, CGRectGetMaxY(self.progressBar.frame)-105,120, 100)];
    _myView2.backgroundColor = [UIColor redColor];
    [self.view addSubview:_myView2];

    
    float boundWidth = self.view.bounds.size.width - (margins*4);
    _barrier = [[LEBarrierView alloc]initWithFrame:CGRectMake(margins*2, 62, boundWidth, 100)];
    [self.view addSubview:_barrier];
}

#pragma mark - View1 -

- (IBAction)onStart:(id)sender {
    
    self.thread1 = [[NSThread alloc]initWithTarget:self selector:@selector(thread1Start) object:nil];
    [self.thread1 start];
    
}
-(void)thread1Start{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(drawView) userInfo:nil repeats:YES];
    
     NSRunLoop *r1 = [NSRunLoop currentRunLoop];
    [r1 run];
    //z[[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode]; // 
}


-(void)drawView{
        self.myView1.contentMode = UIViewContentModeRedraw;
        CGRect  bounds =   self.myView1.bounds;
        CGPoint center =   self.myView1.center;
    
        bounds.size.height += 20;
        NSLog(@"View1 height: %f",_myView1.frame.origin.y);
        center.y -= 10;
    if ([self didIntersectView1]){
       
        while (![self didIntersectView2]) {
             NSLog(@"LOCKING!!");
            [self.lock tryLock];
        }
        if ([self didIntersectView2]) {
          
            [self.lock unlock];
            
        }
    }
        self.myView1.bounds = bounds;
        self.myView1.center = center;
        self.progressFirstThread.progress +=0.08;
    if (self.myView1.frame.origin.y<=60) {
        [self.timer invalidate];
        [self.thread1 cancel];
    }
}


-(BOOL)didIntersectView1{
    
    CGPoint compare = CGPointMake( self.barrier.frame.origin.x,  self.barrier.frame.origin.y+45);
    contains = CGRectContainsPoint(self.myView1.frame, compare);
    if (contains) {
        NSLog(@"View1 intersts!");
    return YES;
    }
    else return NO;
    
}
-(BOOL)didIntersectView2{
    
    CGPoint compare = CGPointMake( self.barrier.frame.origin.x+200,  self.barrier.frame.origin.y+45);
    contains = CGRectContainsPoint(self.myView2.frame, compare);
    if (contains) {
        NSLog(@"View2 intersts!");
        return YES;
    }
    else return NO;
    
}

- (IBAction)onStop:(id)sender {
    [self.thread1 cancel];
    [self.timer invalidate];
}

////////////////////
#pragma mark - View2 -


- (IBAction)onStartThread2:(id)sender {
    self.thread2 = [[NSThread alloc]initWithTarget:self selector:@selector(thread2Start) object:nil];
    self.thread2.name = @"MyThread2";
    [self.thread2 start];
}

-(void)thread2Start{
    
    self.timer2 = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(drawView2) userInfo:nil repeats:YES];
    NSRunLoop *r2 = [NSRunLoop currentRunLoop];
    [r2 run];
    [r2 addTimer:_timer2 forMode:NSDefaultRunLoopMode];
}
-(void)drawView2{
    
    self.myView2.contentMode = UIViewContentModeRedraw;
    CGRect  bounds =   self.myView2.bounds;
    CGPoint center =   self.myView2.center;
    
    bounds.size.height += 20;
    NSLog(@"View2 height: %f",_myView2.frame.origin.y);
    center.y -=10;
    if ([self didIntersectView2]) {
        while (![self didIntersectView1]) {
            NSLog(@"LOCKING View2!!");
            [self.lock tryLock];
        }
        if ([self didIntersectView1]) {
            
            [self.lock unlock];
            
        }
    }
    self.myView2.bounds = bounds;
    self.myView2.center = center;
    self.progressSecondThreat.progress +=0.08;
    if (self.myView2.frame.origin.y<=60) {
        [self.timer2 invalidate];
        [self.thread2 cancel];
    }
    
}

- (IBAction)onStopThread2:(id)sender {
    [[NSThread currentThread]cancel];
    [self.timer2 invalidate];
}

//////////////////////////
#pragma mark - All Threads - 

- (IBAction)onStartAllThreads:(id)sender {
    self.thread1 = [[NSThread alloc]initWithTarget:self selector:@selector(thread1Start) object:nil];
    self.thread1.name = @"MyThread2";
    [self.thread1 start];
    
    ///////////////////////
    self.thread2 = [[NSThread alloc]initWithTarget:self selector:@selector(thread2Start) object:nil];
    self.thread2.name = @"MyThread2";
    [self.thread2 start];

}

- (IBAction)onStopAllThreads:(id)sender {
    [[NSThread currentThread]cancel];
    [self.timer invalidate];
    ///////////
    [[NSThread currentThread]cancel];
    [self.timer2 invalidate];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
    
}


@end
