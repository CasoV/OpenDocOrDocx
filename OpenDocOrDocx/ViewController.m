//
//  ViewController.m
//  OpenDocOrDocx
//
//  Created by 高小伟 on 16/4/18.
//  Copyright © 2016年 高小伟. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"

#define DOC_URL @"http://42.243.111.150:56602/GXMIS.Server/service/DownloadFile.action?attachmentId=1469062"
@interface ViewController ()<UIWebViewDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate>

//保存本地的地址
@property (nonatomic ,copy) NSString *path;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initWeb];
    
}

- (void)initWeb
{

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
    button.frame = CGRectMake(20, self.view.frame.size.height/2, 130, 30);
    [button setTitle:@"查看文档" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(attachmentAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    

}

//查看文档
-(void)attachmentAction:(UIButton *)button
{

    //附件下载地址
        NSString *urlStr = DOC_URL;
    //沙盒保存地址
        NSString *savedPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/通知附件"];
        
        [self downloadFileWithOption:nil withInferface:urlStr savedPath:savedPath downloadSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        } downloadFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        } progress:^(float progress) {
            
        }];
  
}


//下载文档,并保存
- (void)downloadFileWithOption:(NSDictionary *)paramDic withInferface:(NSString*)requestURL savedPath:(NSString*)savedPath downloadSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success downloadFailure:(void (^)(AFHTTPRequestOperation *operation,NSError *error))failure progress:(void (^)(float progress))progress

{
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *request =[serializer requestWithMethod:@"GET" URLString:requestURL parameters:paramDic error:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:savedPath append:NO]];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float p = (float)totalBytesRead / totalBytesExpectedToRead;
        progress(p);
        //        NSLog(@"download：%f", (float)totalBytesRead / totalBytesExpectedToRead);
        
    }];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
        _path = nil;
        
        NSDictionary *dic = operation.response.allHeaderFields;
        NSLog(@"下载成功,%@",dic);
        
        NSString *fileName = dic[@"Content-Disposition"];
        if(fileName){
            if ([fileName rangeOfString:@".docx"].location !=NSNotFound) {
                
                //            NSLog(@"docx文档");
                NSFileManager *manager = [NSFileManager new];
                _path = [savedPath stringByAppendingString:@".docx"];
                [manager moveItemAtPath:savedPath toPath:_path error:nil];
                
                
            }else if ([fileName rangeOfString:@".doc"].location !=NSNotFound){
                
                //            NSLog(@"doc文档");
                NSFileManager *manager = [NSFileManager new];
                _path = [savedPath stringByAppendingString:@".doc"];
                [manager moveItemAtPath:savedPath toPath:_path error:nil];
                
                
            }else if([fileName rangeOfString:@".png"].location !=NSNotFound){
                
                //            NSLog(@"图片");
                _path = [savedPath stringByAppendingString:@".png"];
                NSFileManager *manager = [NSFileManager new];
                _path = [savedPath stringByAppendingString:@".png"];
                [manager moveItemAtPath:savedPath toPath:_path error:nil];
                
            }else if([fileName rangeOfString:@".jpg"].location !=NSNotFound){
                
                //            NSLog(@"图片");
                
                _path = [savedPath stringByAppendingString:@".jpg"];
                NSFileManager *manager = [NSFileManager new];
                _path = [savedPath stringByAppendingString:@".jpg"];
                [manager moveItemAtPath:savedPath toPath:_path error:nil];
                
            }
        }
  
        if (_path) {
            self.previewController = [QLPreviewController new];
            self.previewController.dataSource = self;
            [self.previewController setDelegate:self];
            
            //跳转到打开world文档页面
            [self presentViewController:self.previewController animated:YES completion:nil];
        }
        
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        success(operation,error);
        NSLog(@"下载失败,error==%@",error);
        
    }];
    
    
    [operation start];
    
}

#pragma QLPreViewDelegate
- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1;
}
- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [NSURL fileURLWithPath:_path];
}
- (void)previewControllerDidDismiss:(QLPreviewController *)controller

{
    
    if(![_path  isEqual: @""]){
        NSFileManager * fileManager = [[NSFileManager alloc]init];
        [fileManager removeItemAtPath:_path error:nil];
    }
    
}

@end
