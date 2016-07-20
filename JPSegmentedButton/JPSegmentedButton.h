//
//  JPSegmentedButton.h
//  JPSegmentedButton
//
//  Created by ovopark_iOS on 16/7/19.
//  Copyright © 2016年 JaryPan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JPSegmentedButtonState) {
    JPSegmentedButtonStateNormal = 0,
    JPSegmentedButtonStateHighlighted,
    JPSegmentedButtonStateSelected,
};

@protocol JPSegmentedButtonDelegate;

@interface JPSegmentedButton : UIScrollView

@property (weak, nonatomic) id<JPSegmentedButtonDelegate>buttonDelegate;

// 供用户传递数据
@property (strong, nonatomic) id userInfo;

// 初始化方法（唯一初始化方法）
- (instancetype)initWithFrame:(CGRect)frame
                        items:(NSArray *)items;

// 添加目标动作的方法
- (void)addTarget:(id)target action:(SEL)action;

// 设置分段标题颜色
- (void)setTitleColor:(UIColor *)color forButtonState:(JPSegmentedButtonState)buttonState;

// 当前选中下标（默认0，如果超出按钮总数，设置之后不会改变原来的选中下标）
@property (assign, nonatomic) NSInteger selectedIndex;

// 分段标题文字大小（默认是系统字体大小17）
@property (strong, nonatomic) UIFont *titleFont;

// 指示条移动的时间间隔（默认0.26）
@property (assign, nonatomic) NSTimeInterval indicatorScrollTimeInterval;

// 指示条的颜色（默认和按钮标题的选中颜色相同）
// 设置indicatorColor必须在“设置按钮选中颜色方法”之后，否则会被按钮选中颜色覆盖
@property (strong, nonatomic) UIColor *indicatorColor;

// 指示条的显隐性 （默认是NO，不隐藏）
@property (assign, nonatomic) BOOL indicatorHidden;

// 视图中可视分段的最大个数（默认是5，设置为0无效，建议设置为奇数）
@property (assign, nonatomic) NSInteger visualMaxNumber;

// 选中分段字体放大效果 （默认是NO）
@property (assign, nonatomic) BOOL biggerTitleWhenSelected;

// 当前所有分段
@property (strong, nonatomic, readonly) NSArray<NSString *> *items;

// 在某个下标处添加一个分段（如果index越界，该方法无效，同时打印出错误信息）
- (void)insertOneSegment:(NSString *)title atIndex:(NSInteger)index;

// 添加一个分段（添加到最后的位置）
- (void)addOneSegment:(NSString *)title;

// 对于删除操作，如果删除之后剩余分段的最大下标比原来的selectedIndex还要小，默认自动选中下标0
// 删除所有与标题相同的分段
- (void)deleteSegment:(NSString *)title;

// 删除某个下标下的分段
- (void)deleteOneSegmentAtIndex:(NSInteger)index;

@end

@protocol JPSegmentedButtonDelegate <NSObject>

@optional
// 如果返回NO，将不会滑动到下个下标
- (BOOL)segmentedButton:(JPSegmentedButton *)segmentedButton shouldScrollToIndex:(NSInteger)newIndex fromIndex:(NSInteger)oldIndex;

- (void)segmentedButton:(JPSegmentedButton *)segmentedButton didScrollToIndex:(NSInteger)newIndex fromIndex:(NSInteger)oldIndex;

@end
