//
//  SelectInfoView.m
//  MapTest
//
//  Created by Codyy on 16/5/4.
//  Copyright © 2016年 Codyy. All rights reserved.
//

#import "SelectInfoView.h"

@implementation SelectInfoView
- (id)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    
    bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT/2);
    [self addSubview:bgView];
    
    UIButton *completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [completeBtn setTitle:@"完成" forState:UIControlStateNormal];
    [completeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    completeBtn.frame = CGRectMake(SCREEN_WIDTH - 60, 10,40, 30);
    [completeBtn addTarget:self action:@selector(completeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:completeBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    cancelBtn.frame = CGRectMake(20, 10,40, 30);
    [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:cancelBtn];
    
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0,50, SCREEN_WIDTH,SCREEN_HEIGHT/2 - 50)];
    _pickerView.backgroundColor = [UIColor whiteColor];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    _pickerView.userInteractionEnabled = YES;
    [bgView addSubview:_pickerView];
    
    [self addPickerView];
    
}

- (void)completeBtnClick {
    
    NSInteger row = [_pickerView selectedRowInComponent:0];
    if ([_delegate respondsToSelector:@selector(selectInfoViewCompleteSelectAtIndex:)]) {
        [_delegate selectInfoViewCompleteSelectAtIndex:row];
    }
    [self hiddenPickerView];
}

- (void)cancelBtnClick {
    [self hiddenPickerView];
}

#pragma mark -
#pragma mark 显示和隐藏pickerView
- (void)addPickerView {
    [_pickerView reloadAllComponents];
    [UIView animateWithDuration:0.5 animations:^{
        CGRect newFrame = bgView.frame;
        newFrame.origin.y = SCREEN_HEIGHT/2;
        bgView.frame = newFrame;
    }];
}

- (void)hiddenPickerView {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect newFrame = bgView.frame;
        newFrame.origin.y = SCREEN_HEIGHT;
        bgView.frame = newFrame;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

#pragma mark -
#pragma mark UIPickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _selectDataArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *name = [_selectDataArray objectAtIndex:row];
    return name;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (!hidden) {
        [self addPickerView];
    }
}

- (void)setSelectDataArray:(NSMutableArray *)selectDataArray {
    _selectDataArray = selectDataArray;
    [_pickerView reloadAllComponents];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hiddenPickerView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
