//
//  DocShareViewController.m
//  MapTest
//
//  Created by Codyy on 16/5/5.
//  Copyright © 2016年 Codyy. All rights reserved.
//

#import "DocShareViewController.h"

@interface DocShareViewController ()<UIDocumentInteractionControllerDelegate>

@property (nonatomic, retain)UIDocumentInteractionController *documentController;
@end

@implementation DocShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"文档";
    
    UIButton *showDocBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [showDocBtn setTitle:@"打开文档" forState:UIControlStateNormal];
    [showDocBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    showDocBtn.frame = CGRectMake(100, 200, 100, 30);
    [showDocBtn addTarget:self action:@selector(showDocBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showDocBtn];
    // Do any additional setup after loading the view.
}

- (void)showDocBtnClick {
    NSString *filePathStr = [[NSBundle mainBundle]pathForResource:@"3" ofType:@"txt"];
//    [self transformEncodingFromFilePath:filePathStr];
//    filePathStr = [[NSBundle mainBundle]pathForResource:@"3" ofType:@"txt"];

    _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePathStr]];
    _documentController.delegate = self;
    //预览并在第三方打开
//    [documentController presentPreviewAnimated:YES];
    //直接用第三方打开
    CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [_documentController presentOptionsMenuFromRect:rect inView:self.view animated:YES];
//    [documentController presentOpenInMenuFromRect:rect inView:self.view animated:YES];
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}

- (UIView*)documentInteractionControllerViewForPreview:(UIDocumentInteractionController*)controller {     return self.view;
}

 - (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller {      return self.view.frame;
 }

 - (NSString *)examineTheFilePathStr:(NSString *)str{
     NSStringEncoding *useEncodeing = nil;
     //带编码头的如utf-8等，这里会识别出来
     NSString *body = [NSString stringWithContentsOfFile:str usedEncoding:useEncodeing error:nil];
     if (!body) {
         body = [NSString stringWithContentsOfFile:str encoding:0x80000632 error:nil];
     }
     
     if (!body) {
         body = [NSString stringWithContentsOfFile:str encoding:0x80000631 error:nil];
     }
     
     return body;
 }

 - (void)transformEncodingFromFilePath:(NSString *)filePath{
     //调用上述转码方法获取正常字符串
     NSString *body = [self examineTheFilePathStr:filePath];
     //转换为二进制
     NSData *data = [body dataUsingEncoding:NSUTF16StringEncoding];
     //覆盖原来的文件
     
     [data writeToFile:filePath atomically:YES];
     //此时在读取该文件，就是正常格式啦
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

@end
