//
//  SelectInfoView.h
//  MapTest
//
//  Created by Codyy on 16/5/4.
//  Copyright © 2016年 Codyy. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SelectInfoViewDelegate <NSObject>

@optional

-(void)selectInfoViewCompleteSelectAtIndex:(int)tags;

@end

@interface SelectInfoView : UIView<UIPickerViewDelegate,UIPickerViewDataSource>
{
    UIView *bgView;//背景图片
    UIPickerView *_pickerView;
}

@property (strong, nonatomic)NSMutableArray *selectDataArray;
@property (weak, nonatomic) id<SelectInfoViewDelegate>delegate;

@end
