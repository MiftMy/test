//
//  TestViewController.m
//  test
//
//  Created by mifit on 2017/9/29.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "TestViewController.h"
#import "APCutSelView.h"
#import "XMTool.h"

@interface TestViewController ()<UIScrollViewDelegate> {
    CGFloat rotationAngle;
    CGFloat imgRotation;
}
@property (weak, nonatomic) IBOutlet APCutSelView *showView;
@property (weak, nonatomic) IBOutlet UIImageView *sssIF;

@end

@implementation TestViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    rotationAngle = 0;
    imgRotation = 0;
    self.showView.orgImg = [UIImage imageNamed:@"2.jpeg"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)fun1:(id)sender {
    rotationAngle += M_PI_2;
    self.showView.transform = CGAffineTransformMakeRotation(rotationAngle);
    self.showView.angle = rotationAngle;
}

- (IBAction)fun2:(id)sender {
    imgRotation += M_PI/18/5;
    self.showView.rotationAngle = imgRotation;
}

- (IBAction)fun3:(id)sender {
    imgRotation -= M_PI/18/5;
    self.showView.rotationAngle = imgRotation;
}

- (IBAction)fun4:(id)sender {
    self.showView.whRate = 0.5;
}

- (IBAction)fun5:(id)sender {
    [self.showView imageFromCurrent:^(UIImage *img) {
        CGSize ss = img.size;
        self.sssIF.image = img;
//        UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
}

@end
