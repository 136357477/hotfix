//
//  ViewController.m
//  hotfixdemo
//
//  Created by guohui on 2017/2/6.
//  Copyright © 2017年 guohui. All rights reserved.
//

#import "ViewController.h"
#import "JPEngine.h"
#import "SGDirWatchdog.h"
#import "JPCleaner.h"
#import "JPErrorMsgViewController.h"
@interface ViewController ()
{
    int i ;
    NSArray *array ;
}
@property (nonatomic) NSMutableArray *watchDogs;
@property (nonatomic) UIWindow *errorWindow;
@property (nonatomic) NSString *errMsg;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
//    i = 0 ;
//    [self dataFilePath];
//    for ( ; i < array.count ; i ++) {
//        NSFileManager* fm=[NSFileManager defaultManager];
//         [fm subpathsAtPath:NSHomeDirectory()];
//        NSString *str = [NSString stringWithFormat:@"%@/%@",NSHomeDirectory(),@"Library/.com.tencent.bugly/jspatch/main.js"];
//        NSLog(@"%@",str);
////        if(![fm fileExistsAtPath:[self dataFilePath]]){
//        
//            //下面是对该文件进行制定路径的保存
////            [fm createDirectoryAtPath:[self dataFilePath] withIntermediateDirectories:YES attributes:nil error:nil];
//            NSLog(@"%@\n%@",[self dataFilePath],fm);
//            //取得一个目录下得所有文件名
//            NSArray *files = [fm subpathsAtPath: [self dataFilePath] ];
//            NSLog(@"%@",files);
//            //读取某个文件
//            NSData *data = [fm contentsAtPath:[self dataFilePath]];
//            NSLog(@"%@",data);
//            //或者
//            NSData *data2 = [NSData dataWithContentsOfFile:[self dataFilePath]];
//            NSLog(@"%@",data2);
//            
////        }
//    }
    
#if TARGET_IPHONE_SIMULATOR
    NSString *rootPath = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"projectPath"];
#else
    NSString *rootPath = [[NSBundle mainBundle] bundlePath];
#endif
    
    [JPEngine handleException:^(NSString *msg) {
        if (!self.errorWindow) {
            self.errorWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
            self.errorWindow.windowLevel = UIWindowLevelStatusBar + 1.0f;
            self.errorWindow.backgroundColor = [UIColor blackColor];
            UIButton *errBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, [UIScreen mainScreen].bounds.size.width - 10, 20)];
            errBtn.titleLabel.font = [UIFont systemFontOfSize:10];
            [errBtn setTitle:msg forState:UIControlStateNormal];
            [errBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            errBtn.tag = 100;
            [errBtn addTarget:self action:@selector(handleTapErrorBtn) forControlEvents:UIControlEventTouchDown];
            [self.errorWindow addSubview:errBtn];
            [self.errorWindow makeKeyAndVisible];
        } else {
            UIButton *errBtn = [self.errorWindow viewWithTag:100];
            [errBtn setTitle:msg forState:UIControlStateNormal];
        }
        self.errMsg = msg;
        
        self.errorWindow.hidden = NO;
    }];
    
    NSString *scriptRootPath = [rootPath stringByAppendingPathComponent:@"src"];
    

    
    
    NSString *mainScriptPath3 = [NSString stringWithFormat:@"%@/%@", scriptRootPath, @"/main.js"]; //获取本地文件的 main.js
    NSLog(@"scriptRootPath:\n%@\n\nmainScriptPath3:\n%@",scriptRootPath,mainScriptPath3);
    NSString *mainScriptPath = [NSString stringWithFormat:@"%@/%@",NSHomeDirectory(),@"Library/.com.tencent.bugly/jspatch/main.js"]; // 获取网络的 main.js
    NSLog(@"mainScriptPath~~~~:\n%@",mainScriptPath);
    [JPEngine evaluateScriptWithPath:mainScriptPath];
    
    self.watchDogs = [[NSMutableArray alloc] init];
    NSArray *contentOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:scriptRootPath error:NULL];
    [self watchFolder:scriptRootPath mainScriptPath:mainScriptPath];
    for (NSString *aPath in contentOfFolder) {
        NSString * fullPath = [scriptRootPath stringByAppendingPathComponent:aPath];
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) {
            [self watchFolder:fullPath mainScriptPath:mainScriptPath];
        }
    }
    [self showController];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 50)];
    [btn setTitle:@"Push Playground" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showController) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:btn];
}


- (void)handleTapErrorBtn
{
    JPErrorMsgViewController *errorMsgVC = [[JPErrorMsgViewController alloc] initWithMsg:self.errMsg];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:errorMsgVC];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)watchFolder:(NSString *)folderPath mainScriptPath:(NSString *)mainScriptPath
{
    SGDirWatchdog *watchDog = [[SGDirWatchdog alloc] initWithPath:folderPath update:^{
        self.errorWindow.hidden = YES;
        [JPCleaner cleanAll];
        [JPEngine evaluateScriptWithPath:mainScriptPath];
        [self.navigationController popToRootViewControllerAnimated:NO];
        [self showController];
    }];
    [watchDog start];
    [self.watchDogs addObject:watchDog];
}

- (void)showController
{
    //override in JSPatch
    NSLog(@"hhhh");
    
}

- (NSString *)dataFilePath{
    // 获取沙盒主目录路径
    NSString *homeDir = NSHomeDirectory();
    // 获取Documents目录路径
    NSArray *document_paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [document_paths objectAtIndex:0];
    // 获取Caches目录路径
    NSArray *caches_paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [caches_paths objectAtIndex:0];
    // 获取tmp目录路径
    NSString *tmpDir =  NSTemporaryDirectory();
    array = @[homeDir,docDir,cachesDir,tmpDir];
    return array[i];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
