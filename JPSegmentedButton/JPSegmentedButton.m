//
//  JPSegmentedButton.m
//  JPSegmentedButton
//
//  Created by ovopark_iOS on 16/7/19.
//  Copyright © 2016年 JaryPan. All rights reserved.
//

#define kJPSegmentedButtonHorizontalPadding 5.0

// 处理 target - action 警告
#define kJPSegmentedButtonSuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#import "JPSegmentedButton.h"

@interface JPSegmentedButton ()
{
    NSMutableArray<NSString *> *totalItems; // 所有按钮标题数组
    
    UIColor *normalTitleColor;
    UIColor *highlightedTitleColor;
    UIColor *selectedTitleColor;
    
    UIView *indicatorBar; // 指示条
}

@property (weak, nonatomic) id target;
@property (assign, nonatomic) SEL action;

@property (assign, nonatomic) BOOL shouldPerformSelectorWhenChangeSelectedIndex;

@end

@implementation JPSegmentedButton

#pragma mark - 初始化方法（唯一初始化方法）
- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)items
{
    if (self = [super initWithFrame:frame]) {
        // 初始化部分变量
        totalItems = [NSMutableArray array];
        [totalItems addObjectsFromArray:items];
        
        normalTitleColor = [UIColor blackColor];
        highlightedTitleColor = [UIColor grayColor];
        selectedTitleColor = [UIColor blueColor];
        
        self.titleFont = [UIFont systemFontOfSize:17];
        
        self.indicatorScrollTimeInterval = 0.26;
        self.indicatorColor = selectedTitleColor;
        
        self.visualMaxNumber = 5;
        
        // 添加子控件
        [self addSubviews];
        
        //注册通知监测横竖屏
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    
    return self;
}

// 添加子控件
- (void)addSubviews
{
    // 隐藏自身的滑动条
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    // 计算button总数
    NSInteger buttonCount = totalItems.count;
    
    // 设置button高度
    CGFloat buttonHeight = self.frame.size.height - 10;
    
    // 设置按钮宽度
    CGFloat buttonWidth = 0;
    // 修改按钮宽度
    if (buttonCount > 0 && buttonCount <= self.visualMaxNumber) {
        buttonWidth = (self.frame.size.width - kJPSegmentedButtonHorizontalPadding * (buttonCount + 1))/buttonCount;
    } else if (buttonCount > self.visualMaxNumber) {
        buttonWidth = (self.frame.size.width - kJPSegmentedButtonHorizontalPadding * (self.visualMaxNumber + 1))/self.visualMaxNumber;
    }
    
    //  添加按钮
    for (NSInteger i = 0; i < totalItems.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(kJPSegmentedButtonHorizontalPadding * (i + 1) + buttonWidth * i, 5, buttonWidth, buttonHeight);
        button.tag = 10000 + i;
        [button setTitle:totalItems[i] forState:UIControlStateNormal];
        [button setTitleColor:normalTitleColor forState:UIControlStateNormal];
        [button setTitleColor:highlightedTitleColor forState:UIControlStateHighlighted];
        [button setTitleColor:selectedTitleColor forState:UIControlStateSelected];
        button.titleLabel.font = self.titleFont;
        if (i == 0) {
            button.selected = YES;
        }
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    
    // 设置滑动范围
    self.contentSize = CGSizeMake((kJPSegmentedButtonHorizontalPadding + buttonWidth) * totalItems.count + kJPSegmentedButtonHorizontalPadding, 0);
    
    // 设置指示条
    indicatorBar = [[UIView alloc] initWithFrame:CGRectMake(kJPSegmentedButtonHorizontalPadding, self.frame.size.height - 2, buttonWidth, 2)];
    indicatorBar.backgroundColor = self.indicatorColor;
    [self addSubview:indicatorBar];
}


#pragma mark - 收到横竖屏切换通知的方法
- (void)deviceOrientationDidChange:(NSNotification *)sender
{
    // 计算button总数
    NSInteger buttonCount = totalItems.count;
    
    // 设置button高度
    CGFloat buttonHeight = self.frame.size.height - 10;
    
    // 设置按钮宽度
    CGFloat buttonWidth = 0;
    // 修改按钮宽度
    if (buttonCount > 0 && buttonCount <= self.visualMaxNumber) {
        buttonWidth = (self.frame.size.width - kJPSegmentedButtonHorizontalPadding * (buttonCount + 1))/buttonCount;
    } else if (buttonCount > self.visualMaxNumber) {
        buttonWidth = (self.frame.size.width - kJPSegmentedButtonHorizontalPadding * (self.visualMaxNumber + 1))/self.visualMaxNumber;
    }
    
    //  修改按钮位置
    for (UIButton *button in [self subviews]) {
        if ([button isKindOfClass:[UIButton class]] && button.tag >= 10000) {
            NSInteger index = button.tag - 10000;
            button.frame = CGRectMake(kJPSegmentedButtonHorizontalPadding * (index + 1) + buttonWidth * index, 5, buttonWidth, buttonHeight);
        }
    }
    
    // 设置滑动范围
    self.contentSize = CGSizeMake((kJPSegmentedButtonHorizontalPadding + buttonWidth) * buttonCount + kJPSegmentedButtonHorizontalPadding, 0);
    
    // 设置偏移量
    if (totalItems.count > self.visualMaxNumber) {
        if (self.selectedIndex < ceil(self.visualMaxNumber/2.0)) {
            // 选中了可视范围前一半的按钮
            [UIView animateWithDuration:self.indicatorScrollTimeInterval animations:^{
                self.contentOffset = CGPointMake(0, 0);
            }];
        } else if (self.selectedIndex >= ceil(self.visualMaxNumber/2.0) && self.selectedIndex <= totalItems.count - ceil(self.visualMaxNumber/2.0)) {
            // 选中了可视范围中间的按钮
            [UIView animateWithDuration:self.indicatorScrollTimeInterval animations:^{
                self.contentOffset = CGPointMake((self.selectedIndex + 1 - ceil(self.visualMaxNumber/2.0)) * (kJPSegmentedButtonHorizontalPadding + indicatorBar.frame.size.width), 0);
            }];
        } else {
            // 选中了可视范围后一半的按钮
            [UIView animateWithDuration:self.indicatorScrollTimeInterval animations:^{
                self.contentOffset = CGPointMake((totalItems.count - self.visualMaxNumber) * (kJPSegmentedButtonHorizontalPadding + indicatorBar.frame.size.width), 0);
            }];
        }
    }
    
    // 设置指示条的位置
    [UIView animateWithDuration:self.indicatorScrollTimeInterval animations:^{
        indicatorBar.frame = CGRectMake(kJPSegmentedButtonHorizontalPadding + (kJPSegmentedButtonHorizontalPadding + indicatorBar.frame.size.width) * self.selectedIndex, indicatorBar.frame.origin.y, indicatorBar.frame.size.width, indicatorBar.frame.size.height);
    }];
}


#pragma mark - 按钮的点击方法
- (void)buttonAction:(UIButton *)sender
{
    // 修改选中下标的方法中可以实现目标动作
    self.shouldPerformSelectorWhenChangeSelectedIndex = YES;
    
    // 设置选中的下标
    self.selectedIndex = sender.tag - 10000;
    
    // 修改完选中下标之后就要立刻设置为不能实现目标动作（防止用户在按钮方法中设置selectedIndex导致循环多次执行self.selector）
    self.shouldPerformSelectorWhenChangeSelectedIndex = NO;
}


#pragma mark - 添加目标动作的方法
- (void)addTarget:(id)target action:(SEL)action
{
    self.target = target;
    self.action = action;
}


#pragma mark - 设置分段标题颜色
- (void)setTitleColor:(UIColor *)color forButtonState:(JPSegmentedButtonState)buttonState
{
    switch (buttonState) {
        case JPSegmentedButtonStateNormal:
            normalTitleColor = color;
            for (UIButton *button in [self subviews]) {
                if ([button isKindOfClass:[UIButton class]] && button.tag >= 10000) {
                    [button setTitleColor:color forState:UIControlStateNormal];
                }
            }
            break;
            
        case JPSegmentedButtonStateHighlighted:
            highlightedTitleColor = color;
            for (UIButton *button in [self subviews]) {
                if ([button isKindOfClass:[UIButton class]] && button.tag >= 10000) {
                    [button setTitleColor:color forState:UIControlStateHighlighted];
                }
            }
            break;
            
        case JPSegmentedButtonStateSelected:
            selectedTitleColor = color;
            for (UIButton *button in [self subviews]) {
                if ([button isKindOfClass:[UIButton class]] && button.tag >= 10000) {
                    [button setTitleColor:color forState:UIControlStateSelected];
                }
            }
            break;
            
        default:
            break;
    }
}


#pragma mark - 设置选中下标
- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    // 判断是否越界
    if (selectedIndex >= totalItems.count) {
        NSLog(@"ERROR:JPSegmentedButton无法设置越界下标“%ld”", selectedIndex);
        return;
    }
    
    
    // 判断是否可以滑动到指定位置
    BOOL canScroll = YES;
    if (self.buttonDelegate && [self.buttonDelegate respondsToSelector:@selector(segmentedButton:shouldScrollToIndex:fromIndex:)]) {
        canScroll = [self.buttonDelegate segmentedButton:self shouldScrollToIndex:selectedIndex fromIndex:_selectedIndex];
    }
    if (!canScroll) {
        return;
    }
    
    
    // 赋值
    NSInteger oldIndex = _selectedIndex;
    _selectedIndex = selectedIndex;
    
    
    // 实现目标动作机制
    if (self.target && self.action && self.shouldPerformSelectorWhenChangeSelectedIndex) {
        kJPSegmentedButtonSuppressPerformSelectorLeakWarning([self.target performSelector:self.action withObject:self]);
    }
    
    
    // 滑动的动画效果
    [self scrollToIndex:selectedIndex fromIndex:oldIndex];
}
- (void)scrollToIndex:(NSInteger)newIndex fromIndex:(NSInteger)oldIndex
{
    // 设置偏移量
    if (totalItems.count > self.visualMaxNumber) {
        if (newIndex < ceil(self.visualMaxNumber/2.0)) {
            // 选中了可视范围前一半的按钮
            [UIView animateWithDuration:self.indicatorScrollTimeInterval animations:^{
                self.contentOffset = CGPointMake(0, 0);
            }];
        } else if (newIndex >= ceil(self.visualMaxNumber/2.0) && newIndex < totalItems.count - ceil(self.visualMaxNumber/2.0)) {
            // 选中了可视范围中间的按钮
            [UIView animateWithDuration:self.indicatorScrollTimeInterval animations:^{
                self.contentOffset = CGPointMake((newIndex + 1 - ceil(self.visualMaxNumber/2.0)) * (kJPSegmentedButtonHorizontalPadding + indicatorBar.frame.size.width), 0);
            }];
        } else {
            // 选中了可视范围后一半的按钮
            [UIView animateWithDuration:self.indicatorScrollTimeInterval animations:^{
                self.contentOffset = CGPointMake((totalItems.count - self.visualMaxNumber) * (kJPSegmentedButtonHorizontalPadding + indicatorBar.frame.size.width), 0);
            }];
        }
    }
    
    // 设置指示条的位置
    [UIView animateWithDuration:self.indicatorScrollTimeInterval animations:^{
        indicatorBar.frame = CGRectMake(kJPSegmentedButtonHorizontalPadding + (kJPSegmentedButtonHorizontalPadding + indicatorBar.frame.size.width) * newIndex, indicatorBar.frame.origin.y, indicatorBar.frame.size.width, indicatorBar.frame.size.height);
    }];
    
    // 修改按钮选中状态
    for (UIButton *button in [self subviews]) {
        if ([button isKindOfClass:[UIButton class]]) {
            if (button.tag - 10000 == newIndex) {
                button.selected = YES;
                if (self.biggerTitleWhenSelected) {
                    button.titleLabel.font = [UIFont systemFontOfSize:self.titleFont.pointSize + 5];
                }
            } else {
                button.selected = NO;
                button.titleLabel.font = self.titleFont;
            }
        }
    }
    
    
    // 实现代理
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.indicatorScrollTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.buttonDelegate && [self.buttonDelegate respondsToSelector:@selector(segmentedButton:didScrollToIndex:fromIndex:)]) {
            [self.buttonDelegate segmentedButton:self didScrollToIndex:newIndex fromIndex:oldIndex];
        }
    });
}


#pragma mark - 分段标题文字大小
- (void)setTitleFont:(UIFont *)titleFont
{
    if (_titleFont != titleFont) {
        _titleFont = titleFont;
    }
    
    for (UIButton *button in [self subviews]) {
        if ([button isKindOfClass:[UIButton class]] && button.tag >= 10000) {
            button.titleLabel.font = titleFont;
        }
    }
}


#pragma mark - 指示条的颜色
- (void)setIndicatorColor:(UIColor *)indicatorColor
{
    if (_indicatorColor != indicatorColor) {
        _indicatorColor = indicatorColor;
    }
    
    indicatorBar.backgroundColor = indicatorColor;
}


#pragma mark - 指示条的显隐性
- (void)setIndicatorHidden:(BOOL)indicatorHidden
{
    _indicatorHidden = indicatorHidden;
    indicatorBar.hidden = indicatorHidden;
}


#pragma mark - 视图中可视分段的最大个数
- (void)setVisualMaxNumber:(NSInteger)visualMaxNumber
{
    BOOL changed = (visualMaxNumber != _visualMaxNumber);
    
    _visualMaxNumber = visualMaxNumber;
    
    if (changed) {
        // 计算button总数
        NSInteger buttonCount = totalItems.count;
        
        // 设置button高度
        CGFloat buttonHeight = self.frame.size.height - 10;
        
        // 设置按钮宽度
        CGFloat buttonWidth = 0;
        // 修改按钮宽度
        if (buttonCount > 0 && buttonCount <= visualMaxNumber) {
            buttonWidth = (self.frame.size.width - kJPSegmentedButtonHorizontalPadding * (buttonCount + 1))/buttonCount;
        } else if (buttonCount > visualMaxNumber) {
            buttonWidth = (self.frame.size.width - kJPSegmentedButtonHorizontalPadding * (self.visualMaxNumber + 1))/self.visualMaxNumber;
        }
        
        //  修改按钮尺寸
        for (UIButton *button in [self subviews]) {
            if ([button isKindOfClass:[UIButton class]] && button.tag >= 10000) {
                NSInteger index = button.tag - 10000;
                button.frame = CGRectMake(kJPSegmentedButtonHorizontalPadding * (index + 1) + buttonWidth * index, 5, buttonWidth, buttonHeight);
            }
        }
        
        // 设置滑动范围
        self.contentSize = CGSizeMake((kJPSegmentedButtonHorizontalPadding + buttonWidth) * buttonCount + kJPSegmentedButtonHorizontalPadding, 0);
        
        // 设置指示条
        indicatorBar.frame = CGRectMake(kJPSegmentedButtonHorizontalPadding + (kJPSegmentedButtonHorizontalPadding + indicatorBar.frame.size.width) * self.selectedIndex, self.frame.size.height - 2, buttonWidth, 2);
    }
}


#pragma mark - 选中分段字体放大效果
- (void)setBiggerTitleWhenSelected:(BOOL)biggerTitleWhenSelected
{
    _biggerTitleWhenSelected = biggerTitleWhenSelected;
    
    if (biggerTitleWhenSelected) {
        // 放大选中的按钮标题
        for (UIButton *button in [self subviews]) {
            if ([button isKindOfClass:[UIButton class]] && button.tag >= 10000) {
                if (button.isSelected) {
                    button.titleLabel.font = [UIFont systemFontOfSize:self.titleFont.pointSize + 5];
                } else {
                    button.titleLabel.font = self.titleFont;
                }
            }
        }
    } else {
        // 还原所有的按钮标题大小
        for (UIButton *button in [self subviews]) {
            if ([button isKindOfClass:[UIButton class]] && button.tag >= 10000) {
                button.titleLabel.font = self.titleFont;
            }
        }
    }
}


#pragma mark - 当前所有按钮
- (NSArray<NSString *> *)items
{
    return [NSArray arrayWithArray:totalItems];
}


#pragma mark - 在某个下标处添加一个分段（如果index越界，该方法无效，同时打印出错误信息）
- (void)insertOneSegment:(NSString *)title atIndex:(NSInteger)index
{
    // 判断是否越界
    if (index > totalItems.count) {
        NSLog(@"ERROR:JPSegmentedButton无法在越界下标“%ld”处添加按钮“%@”", index, title);
        return;
    }
    
    
    // 将标题加入到数组中
    [totalItems insertObject:title atIndex:index];
    
    // 修改原有button的tag值
    for (UIButton *button in [self subviews]) {
        if ([button isKindOfClass:[UIButton class]] && button.tag >= 10000) {
            if (button.tag - 10000 >= index) {
                button.tag = button.tag + 1;
            }
        }
    }
    
    // 创建一个新的按钮
    // 计算button总数
    NSInteger buttonCount = totalItems.count;
    // 设置button高度
    CGFloat buttonHeight = self.frame.size.height - 10;
    // 设置按钮宽度
    CGFloat buttonWidth = 0;
    // 修改按钮宽度
    if (buttonCount > 0 && buttonCount <= self.visualMaxNumber) {
        buttonWidth = (self.frame.size.width - kJPSegmentedButtonHorizontalPadding * (buttonCount + 1))/buttonCount;
    } else if (buttonCount > self.visualMaxNumber) {
        buttonWidth = (self.frame.size.width - kJPSegmentedButtonHorizontalPadding * (self.visualMaxNumber + 1))/self.visualMaxNumber;
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(kJPSegmentedButtonHorizontalPadding * (index + 1) + buttonWidth * index, 5, buttonWidth, buttonHeight);
    button.tag = 10000 + index;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:normalTitleColor forState:UIControlStateNormal];
    [button setTitleColor:highlightedTitleColor forState:UIControlStateHighlighted];
    [button setTitleColor:selectedTitleColor forState:UIControlStateSelected];
    button.titleLabel.font = self.titleFont;
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];

    // 重新设置按钮的位置和选中状态
    for (UIButton *button in [self subviews]) {
        if ([button isKindOfClass:[UIButton class]] && button.tag >= 10000) {
            button.frame = CGRectMake(kJPSegmentedButtonHorizontalPadding * (button.tag - 10000 + 1) + buttonWidth * (button.tag - 10000), 5, buttonWidth, buttonHeight);
            if (button.tag - 10000 == self.selectedIndex) {
                button.selected = YES;
                if (self.biggerTitleWhenSelected) {
                    button.titleLabel.font = [UIFont systemFontOfSize:self.titleFont.pointSize + 5];
                } else {
                    button.titleLabel.font = self.titleFont;
                }
            } else {
                button.selected = NO;
                button.titleLabel.font = self.titleFont;
            }
        }
    }
    
    // 设置滑动范围
    self.contentSize = CGSizeMake((kJPSegmentedButtonHorizontalPadding + buttonWidth) * buttonCount + kJPSegmentedButtonHorizontalPadding, 0);
    
    // 设置指示条
    indicatorBar.frame = CGRectMake(kJPSegmentedButtonHorizontalPadding + (kJPSegmentedButtonHorizontalPadding + indicatorBar.frame.size.width) * self.selectedIndex, self.frame.size.height - 2, buttonWidth, 2);
}


#pragma mark - 添加一个分段（添加到最后的位置）
- (void)addOneSegment:(NSString *)title
{
    [self insertOneSegment:title atIndex:totalItems.count];
}


#pragma mark - 删除所有与标题相同的分段
- (void)deleteSegment:(NSString *)title
{
    NSArray *items = [NSArray arrayWithArray:totalItems];
    
    // 需要删除的按钮的个数
    [totalItems removeObject:title];
    NSInteger deleteCount = items.count - totalItems.count;
    
    // 删除按钮
    for (NSInteger i = 0; i < deleteCount; i++) {
        for (UIButton *button in [self subviews]) {
            if ([button isKindOfClass:[UIButton class]] && button.tag >= 10000) {
                [button removeFromSuperview];
                break;
            }
        }
    }
    
    // 修改剩余按钮的tag值
    NSInteger tag = 10000;
    for (UIButton *button in [self subviews]) {
        if ([button isKindOfClass:[UIButton class]] && button.tag >= 10000) {
            button.tag = tag;
            tag++;
        }
    }
    
    // 重新设置剩余按钮的位置和选中状态
    // 计算button总数
    NSInteger buttonCount = totalItems.count;
    // 设置button高度
    CGFloat buttonHeight = self.frame.size.height - 10;
    // 设置按钮宽度
    CGFloat buttonWidth = 0;
    // 修改按钮宽度
    if (buttonCount > 0 && buttonCount <= self.visualMaxNumber) {
        buttonWidth = (self.frame.size.width - kJPSegmentedButtonHorizontalPadding * (buttonCount + 1))/buttonCount;
    } else if (buttonCount > self.visualMaxNumber) {
        buttonWidth = (self.frame.size.width - kJPSegmentedButtonHorizontalPadding * (self.visualMaxNumber + 1))/self.visualMaxNumber;
    }
    for (UIButton *button in [self subviews]) {
        if ([button isKindOfClass:[UIButton class]] && button.tag >= 10000) {
            button.frame = CGRectMake(kJPSegmentedButtonHorizontalPadding * (button.tag - 10000 + 1) + buttonWidth * (button.tag - 10000), 5, buttonWidth, buttonHeight);
            if (button.tag - 10000 == self.selectedIndex) {
                button.selected = YES;
                if (self.biggerTitleWhenSelected) {
                    button.titleLabel.font = [UIFont systemFontOfSize:self.titleFont.pointSize + 5];
                } else {
                    button.titleLabel.font = self.titleFont;
                }
            } else {
                button.selected = NO;
                button.titleLabel.font = self.titleFont;
            }
        }
    }
    
    // 设置滑动范围
    self.contentSize = CGSizeMake((kJPSegmentedButtonHorizontalPadding + buttonWidth) * buttonCount + kJPSegmentedButtonHorizontalPadding, 0);
    
    // 判断原来的selectedIndex是否超出了最后一个按钮的下标
    if (self.selectedIndex >= totalItems.count) {
        self.selectedIndex = 0;
    }
    
    // 设置指示条
    indicatorBar.frame = CGRectMake(kJPSegmentedButtonHorizontalPadding + (kJPSegmentedButtonHorizontalPadding + indicatorBar.frame.size.width) * self.selectedIndex, self.frame.size.height - 2, buttonWidth, 2);
}


#pragma mark - 删除某个下标下的分段
- (void)deleteOneSegmentAtIndex:(NSInteger)index
{
    // 判断是否越界
    if (index >= totalItems.count) {
        NSLog(@"ERROR:JPSegmentedButton无法在越界下标“%ld”处删除按钮", index);
        return;
    }
    
    
    // 删除数组中的对应标题
    [totalItems removeObjectAtIndex:index];
    
    // 删除对应的按钮
    for (UIButton *button in [self subviews]) {
        if ([button isKindOfClass:[UIButton class]] && button.tag == 10000 + index) {
            [button removeFromSuperview];
            break;
        }
    }
    
    // 修改原有button的tag值
    for (UIButton *button in [self subviews]) {
        if ([button isKindOfClass:[UIButton class]] && button.tag >= 10000) {
            if (button.tag - 10000 > index) {
                button.tag = button.tag - 1;
            }
        }
    }
    
    // 重新设置剩余按钮的位置和选中状态
    // 计算button总数
    NSInteger buttonCount = totalItems.count;
    // 设置button高度
    CGFloat buttonHeight = self.frame.size.height - 10;
    // 设置按钮宽度
    CGFloat buttonWidth = 0;
    // 修改按钮宽度
    if (buttonCount > 0 && buttonCount <= self.visualMaxNumber) {
        buttonWidth = (self.frame.size.width - kJPSegmentedButtonHorizontalPadding * (buttonCount + 1))/buttonCount;
    } else if (buttonCount > self.visualMaxNumber) {
        buttonWidth = (self.frame.size.width - kJPSegmentedButtonHorizontalPadding * (self.visualMaxNumber + 1))/self.visualMaxNumber;
    }
    for (UIButton *button in [self subviews]) {
        if ([button isKindOfClass:[UIButton class]] && button.tag >= 10000) {
            button.frame = CGRectMake(kJPSegmentedButtonHorizontalPadding * (button.tag - 10000 + 1) + buttonWidth * (button.tag - 10000), 5, buttonWidth, buttonHeight);
            if (button.tag - 10000 == self.selectedIndex) {
                button.selected = YES;
                if (self.biggerTitleWhenSelected) {
                    button.titleLabel.font = [UIFont systemFontOfSize:self.titleFont.pointSize + 5];
                } else {
                    button.titleLabel.font = self.titleFont;
                }
            } else {
                button.selected = NO;
                button.titleLabel.font = self.titleFont;
            }
        }
    }
    
    // 设置滑动范围
    self.contentSize = CGSizeMake((kJPSegmentedButtonHorizontalPadding + buttonWidth) * buttonCount + kJPSegmentedButtonHorizontalPadding, 0);
    
    // 判断原来的selectedIndex是否超出了最后一个按钮的下标
    if (self.selectedIndex >= totalItems.count) {
        self.selectedIndex = 0;
    }
    
    // 设置指示条
    indicatorBar.frame = CGRectMake(kJPSegmentedButtonHorizontalPadding + (kJPSegmentedButtonHorizontalPadding + indicatorBar.frame.size.width) * self.selectedIndex, self.frame.size.height - 2, buttonWidth, 2);
}


#pragma mark - 在dealloc方法中注销通知
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
