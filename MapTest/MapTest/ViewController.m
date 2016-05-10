//
//  ViewController.m
//  MapTest
//
//  Created by Codyy on 16/4/29.
//  Copyright © 2016年 Codyy. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "MapViewController.h"
#import "DocShareViewController.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "SelectInfoView.h"
#import "UIImageView+WebCache.h"

@interface ViewController ()<AMapLocationManagerDelegate,AMapSearchDelegate,SelectInfoViewDelegate>
{
    UILabel *_locationLab;
    AMapSearchAPI *_search;
    UIPickerView *_pickerView;
    BOOL isHaveLocation;
    NSString *cityInfoStr;
    SelectInfoView *_selectInfoView;
}
@property (strong, nonatomic) AMapLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *locationArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _locationArray = [[NSMutableArray alloc] initWithCapacity:0];
    [AMapLocationServices sharedServices].apiKey =@"ea2863d7068674364d28727eac3cce32";
    [AMapSearchServices sharedServices].apiKey = @"ea2863d7068674364d28727eac3cce32";

    self.locationManager = [[AMapLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    //   定位超时时间，可修改，最小2s
    self.locationManager.locationTimeout = 3;
    //   逆地理请求超时时间，可修改，最小2s
    self.locationManager.reGeocodeTimeout = 3;
    
    UIButton *locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [locationBtn setTitle:@"定位" forState:UIControlStateNormal];
    [locationBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    locationBtn.frame = CGRectMake(100, 100, 100, 30);
    [locationBtn addTarget:self action:@selector(locationBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:locationBtn];
    
    _locationLab = [[UILabel alloc] init];
    _locationLab.frame = CGRectMake(10, 150, 300, 60);
    _locationLab.numberOfLines = 0;
    [self.view addSubview:_locationLab];
    
    UIButton *showMapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [showMapBtn setTitle:@"打开地图" forState:UIControlStateNormal];
    [showMapBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    showMapBtn.frame = CGRectMake(100, 250, 100, 30);
    [showMapBtn addTarget:self action:@selector(showMapBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showMapBtn];
    
    UIButton *showDocBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [showDocBtn setTitle:@"打开文档" forState:UIControlStateNormal];
    [showDocBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    showDocBtn.frame = CGRectMake(100, 300, 100, 30);
    [showDocBtn addTarget:self action:@selector(showDocBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showDocBtn];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)locationBtnClick {
    
    if (isHaveLocation) {
        //选择位置
//        [self addPickerView];
        if (_selectInfoView == nil) {
            NSMutableArray *selectArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (AMapPOI *p in _locationArray) {
                [selectArray addObject:p.name];
            }
            _selectInfoView = [[SelectInfoView alloc] init];
            _selectInfoView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            _selectInfoView.selectDataArray = selectArray;
            _selectInfoView.delegate = self;
            [self.navigationController.view addSubview:_selectInfoView];
        } else {
            _selectInfoView.hidden = NO;
        }
    } else {
        //定位
        // 带逆地理（返回坐标和地址信息）
        [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
            
            NSLog(@"location:%@", location);
            
            if (_search == nil) {
                _search = [[AMapSearchAPI alloc] init];
            }
            _search.delegate = self;
            //构造AMapPOIAroundSearchRequest对象，设置周边请求参数
            AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
            request.location = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
            request.radius = 2000;
            request.sortrule = 0;
            request.offset = 30;
            request.page = 0;
            request.keywords = @"街|路|道|巷|弄";
            request.types = @"交通地名";
            //发起周边搜索
            [_search AMapPOIAroundSearch: request];
            
            if (regeocode)
            {
                NSLog(@"reGeocode:%@", regeocode);
                cityInfoStr = [NSString stringWithFormat:@"%@%@%@",regeocode.province,regeocode.city,regeocode.district];
                _locationLab.text = [NSString stringWithFormat:@"%@附近",regeocode.formattedAddress];
                isHaveLocation = YES;
            } else {
                //定位失败
            }
        }];
    }
    
}

//实现POI搜索对应的回调函数
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if(response.pois.count == 0) {
        return;
    }
    
    if (_locationArray.count != 0) {
        [_locationArray removeAllObjects];
    }
    NSMutableArray *selectArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (AMapPOI *p in response.pois) {
        p.name = [self formatAddressName:p.name];
        if (![self isExistWithName:p.name]) {
            [_locationArray addObject:p];
            [selectArray addObject:p.name];
        }
    }
    
    if (_selectInfoView != nil) {
        _selectInfoView.selectDataArray = selectArray;
    }
}

- (void)selectInfoViewCompleteSelectAtIndex:(int)tags {
    AMapPOI *poi = [_locationArray objectAtIndex:tags];
    _locationLab.text = [NSString stringWithFormat:@"%@%@",cityInfoStr,poi.name];
}

#pragma mark -
#pragma mark 格式化地址的信息
- (NSString *)formatAddressName:(NSString *)name {
    NSString *subNames;
    if ([name containsString:@"路"]) {
        
        NSArray *namesArray = [name componentsSeparatedByString:@"路"];
        if (namesArray.count != 0) {
            subNames = [NSString stringWithFormat:@"%@路附近",[namesArray objectAtIndex:0]];
        }
        return subNames;
    } else if ([name containsString:@"街"]) {
        NSArray *namesArray = [name componentsSeparatedByString:@"街"];
        if (namesArray.count != 0) {
            subNames = [NSString stringWithFormat:@"%@街附近",[namesArray objectAtIndex:0]];
        }
        return subNames;
    } else if ([name containsString:@"道"]) {
        NSArray *namesArray = [name componentsSeparatedByString:@"道"];
        if (namesArray.count != 0) {
            subNames = [NSString stringWithFormat:@"%@道附近",[namesArray objectAtIndex:0]];
        }
        return subNames;
    } else if ([name containsString:@"弄"]) {
        NSArray *namesArray = [name componentsSeparatedByString:@"弄"];
        if (namesArray.count != 0) {
            subNames = [NSString stringWithFormat:@"%@弄附近",[namesArray objectAtIndex:0]];
        }
        return subNames;
    } else if ([name containsString:@"巷"]) {
        NSArray *namesArray = [name componentsSeparatedByString:@"巷"];
        if (namesArray.count != 0) {
            subNames = [NSString stringWithFormat:@"%@巷附近",[namesArray objectAtIndex:0]];
        }
        return subNames;
    } else {
        return [NSString stringWithFormat:@"%@附近",name];
    }
}

- (BOOL) isExistWithName:(NSString *)name {
    BOOL isExist = NO;
    for (int i = 0; i < _locationArray.count; i ++) {
        AMapPOI *poi = [_locationArray objectAtIndex:i];
        if ([name isEqualToString:poi.name]) {
            isExist = YES;
        }
    }
    return isExist;
}

- (void)showMapBtnClick {
    MapViewController *mapVC = [[MapViewController alloc] init];
    [self.navigationController pushViewController:mapVC animated:YES];
}

- (void)showDocBtnClick {
    DocShareViewController *docVC = [[DocShareViewController alloc] init];
    [self.navigationController pushViewController:docVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
