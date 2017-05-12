//
//  ViewController.h
//  OpenDocOrDocx
//
//  Created by 高小伟 on 16/4/18.
//  Copyright © 2016年 高小伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
@interface ViewController : UIViewController

//打开word文档需要引入的视图控制器
@property(nonatomic,strong) QLPreviewController *previewController;

@end

