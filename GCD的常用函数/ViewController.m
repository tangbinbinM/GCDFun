//
//  ViewController.m
//  GCD的常用函数
//
//  Created by YiGuo on 2017/10/23.
//  Copyright © 2017年 tbb. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
/** 图片1 */
@property (nonatomic, strong) UIImage *image1;
/** 图片2 */
@property (nonatomic, strong) UIImage *image2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self group];
}

/**
 队列组
 */
- (void)group{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 创建一个队列组
    dispatch_group_t group = dispatch_group_create();
    
    // 1.下载图片1
    dispatch_group_async(group, queue, ^{
        // 图片的网络路径
        NSURL *url = [NSURL URLWithString:@""];
        
        // 加载图片
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        // 生成图片
        self.image1 = [UIImage imageWithData:data];
    });
    
    // 2.下载图片2
    dispatch_group_async(group, queue, ^{
        // 图片的网络路径
        NSURL *url = [NSURL URLWithString:@""];
        
        // 加载图片
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        // 生成图片
        self.image2 = [UIImage imageWithData:data];
    });
    
    // 3.将图片1、图片2合成一张新的图片
    dispatch_group_notify(group, queue, ^{
        // 开启新的图形上下文
        UIGraphicsBeginImageContext(CGSizeMake(100, 100));
        
        // 绘制图片
        [self.image1 drawInRect:CGRectMake(0, 0, 50, 100)];
        [self.image2 drawInRect:CGRectMake(50, 0, 50, 100)];
        
        // 取得上下文中的图片
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        // 结束上下文
        UIGraphicsEndImageContext();
        
        // 回到主线程显示图片
        dispatch_async(dispatch_get_main_queue(), ^{
            // 4.将新图片显示出来
            self.imageView.image = image;
        });
    });
}
/**
 GCD快速迭代
 
 */
-(void)apply{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSString *from = @"当前文件夹路径";
    NSString *to = @"目标文件夹路径";
    NSFileManager *mgr = [NSFileManager defaultManager];
    NSArray *subpaths = [mgr subpathsAtPath:from];
    
    //向队列加入任务
    dispatch_apply(subpaths.count, queue, ^(size_t index) {
        NSString *subPath = subpaths[index];
        NSString *fromFullpath = [from stringByAppendingPathComponent:subPath];
        NSString *toFullpath = [to stringByAppendingPathComponent:subPath];
        //剪切
        [mgr moveItemAtPath:fromFullpath toPath:toFullpath error:nil];
        NSLog(@"%@-----%@", [NSThread currentThread], subPath);
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
