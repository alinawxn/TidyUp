//
//  iAKViewController.m
//  TidyUp
//
//  Created by Xiaonan Wang on 7/31/14.
//  Copyright (c) 2014 iAKTU. All rights reserved.
//

#import "iAKViewController.h"

@implementation iAKViewController

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    self.scene = [[iAKMyScene alloc ]initWithSize:skView.bounds.size state:GameStateMainMenu];
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstStart"]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstStart"];
        NSLog(@"第一次启动");
        NSString *path = [[NSBundle mainBundle]pathForResource:@"LevelLocked" ofType:@"plist"];
        NSDictionary *dic = [[NSDictionary alloc]initWithContentsOfFile:path];
        if (!dic) {
            NSLog(@"dic not found now!!!");
        }
        //NSLog(@"path:%@",path);
        //获取应用程序沙盒的Documents目录
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *plistPath = [paths objectAtIndex:0];
        //得到完整的文件名
        NSString *filename=[plistPath stringByAppendingPathComponent:@"LevelLocked.plist"];
        //输入写入
        //NSLog(@"filename:%@",filename);
        [dic writeToFile:filename atomically:YES];
        
    }else{
        NSLog(@"不是第一次启动");
    }
    
    // Present the scene.
    [skView presentScene:self.scene];
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
