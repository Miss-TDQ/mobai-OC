//
//  ViewController.m
//  mobai
//
//  Created by miss on 2017/9/28.
//  Copyright © 2017年 miss. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
@interface ViewController ()

@property (nonatomic,strong)UIGravityBehavior *gravity;
//物理仿真动画
@property (nonatomic,strong)UIDynamicAnimator *animator;
//传感器
@property (nonatomic)CMMotionManager *motionManager;
@property (nonatomic)CMPedometer *pter;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor cyanColor];
    
    [self creatBallWithImageArr:@[@"01",@"02",@"03",@"04",@"01",@"02",@"03",@"04",@"01",@"02",@"03",@"04"] diameter:40];
    [self initGyroManager];
}

-(void)creatBallWithImageArr:(NSArray *)imageArr diameter:(CGFloat)diameter
{
    NSMutableArray *ballViewArr = [NSMutableArray array];
    for(int i=0;i<imageArr.count;i++)
    {
        UIImageView * imgView = [[UIImageView alloc]initWithFrame:CGRectMake(arc4random()%((int)(self.view.bounds.size.width-diameter)), 0, diameter, diameter)];
        imgView.image = [UIImage imageNamed:imageArr[i]];
        imgView.layer.masksToBounds = YES;
        imgView.layer.cornerRadius = diameter/2;
        [self.view addSubview:imgView];
        
        [ballViewArr addObject:imgView];
    }
    
    //_animator为全局定义的，否则不会生效，self.view为力学参考系，动力效果才能生效
    _animator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    
    
    //添加重力
    _gravity = [[UIGravityBehavior alloc]initWithItems:ballViewArr];
    [_animator addBehavior:_gravity];
    
    //添加碰撞
    UICollisionBehavior *collision = [[UICollisionBehavior alloc]initWithItems:ballViewArr];
    collision.translatesReferenceBoundsIntoBoundary = YES;
    [_animator addBehavior:collision];
    
    //添加弹性
    UIDynamicItemBehavior *dyItem = [[UIDynamicItemBehavior alloc]initWithItems:ballViewArr];
    dyItem.allowsRotation = YES;
    dyItem.elasticity = 0.8;        //弹性系数
    [_animator addBehavior:dyItem];
    
    //还有很多behavior:UIAttachmentBehavior(附着行为)、UISnapBehavior(捕捉行为)、UIPushBehavior(推动行为)、UIDynamicItemBehavior(动力元素行为)
}

-(void)initGyroManager
{
    self.motionManager = [[CMMotionManager alloc]init];
    self.motionManager.deviceMotionUpdateInterval = 0.01;
    
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        //返回至原点的方位角
        double rotation = atan2(motion.attitude.pitch, motion.attitude.roll);
        NSLog(@"rotation:%f",motion.attitude.pitch);
        self.gravity.angle = rotation;
    }];
}
-(void)dealloc
{
    [self.motionManager stopDeviceMotionUpdates];
}


@end
