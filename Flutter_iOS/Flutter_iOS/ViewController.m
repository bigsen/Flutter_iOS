//
//  ViewController.m
//  Flutter_iOS
//
//  Created by sen on 2018/11/9.
//  Copyright © 2018年 sen. All rights reserved.
//

#import "ViewController.h"
#import <Flutter/FlutterViewController.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    FlutterViewController* flutterViewController = [[FlutterViewController alloc] initWithProject:nil nibName:nil bundle:nil];
    flutterViewController.navigationItem.title = @"Flutter Demo";
    
    [self presentViewController:flutterViewController animated:YES completion:nil];
}

@end
