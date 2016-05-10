//
//  MapViewController.m
//  MapTest
//
//  Created by Codyy on 16/5/3.
//  Copyright © 2016年 Codyy. All rights reserved.
//

#import "MapViewController.h"
#import <MAMapKit/MAMapKit.h>

@interface MapViewController ()<MAMapViewDelegate>
{
    MAMapView *_mapView;
    CLLocationCoordinate2D userCoordinate;
    MAPointAnnotation *pointAnnotation;
}
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"地图";
    [MAMapServices sharedServices].apiKey = @"ea2863d7068674364d28727eac3cce32";
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    _mapView.delegate = self;
    _mapView.language = MAMapLanguageZhCN;
    _mapView.showsUserLocation = YES;
    [self.view addSubview:_mapView];
    
    //添加标注
    pointAnnotation = [[MAPointAnnotation alloc] init];
    [_mapView addAnnotation:pointAnnotation];
    // Do any additional setup after loading the view.
}

-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation) {
        //取出当前位置的坐标
        if (userCoordinate.latitude == 0) {
            userCoordinate = userLocation.coordinate;
            _mapView.centerCoordinate = userLocation.coordinate;
            pointAnnotation.coordinate = userLocation.coordinate;;
            pointAnnotation.title = userLocation.title;
            pointAnnotation.subtitle = userLocation.subtitle;
        }
        NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple;
        return annotationView;
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
