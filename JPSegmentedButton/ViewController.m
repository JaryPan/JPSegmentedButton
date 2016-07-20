//
//  ViewController.m
//  JPSegmentedButton
//
//  Created by ovopark_iOS on 16/7/19.
//  Copyright © 2016年 JaryPan. All rights reserved.
//

#import "ViewController.h"
#import "JPSegmentedButton.h"

@interface ViewController () <JPSegmentedButtonDelegate>
{
    JPSegmentedButton *segmentedButton;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor grayColor];
    
    // 创建一个分段按钮
    segmentedButton = [[JPSegmentedButton alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 40) items:@[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10"]];
    segmentedButton.buttonDelegate = self; // 设置代理对象
    segmentedButton.backgroundColor = [UIColor whiteColor];
    segmentedButton.biggerTitleWhenSelected = YES; // 设置选中放大效果
    segmentedButton.selectedIndex = 0; // 设置当前的选中下标
    [segmentedButton addTarget:self action:@selector(segmentedButtonAction:)];
    [self.view addSubview:segmentedButton];
    
    // 添加
    [segmentedButton addOneSegment:@"11"];
    
    [segmentedButton insertOneSegment:@"12" atIndex:segmentedButton.items.count];
}

- (void)segmentedButtonAction:(JPSegmentedButton *)sender
{
    NSLog(@"%ld", sender.selectedIndex);
}

- (BOOL)segmentedButton:(JPSegmentedButton *)segmentedButton shouldScrollToIndex:(NSInteger)newIndex fromIndex:(NSInteger)oldIndex
{
    NSLog(@"将要滑动到newIndex:%ld, oldIndex:%ld", newIndex, oldIndex);
//    if (newIndex == 0) {
//        return NO;
//    }
    return YES;
}

- (void)segmentedButton:(JPSegmentedButton *)segmentedButton didScrollToIndex:(NSInteger)newIndex fromIndex:(NSInteger)oldIndex
{
    NSLog(@"已经滑动到newIndex:%ld, oldIndex:%ld", newIndex, oldIndex);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    segmentedButton.frame = CGRectMake(0, 100, size.width, 40);
    
    if (size.width > size.height) {
        // 横屏
        segmentedButton.visualMaxNumber = 7;
    } else {
        segmentedButton.visualMaxNumber = 5;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
