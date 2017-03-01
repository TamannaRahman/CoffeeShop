//
//  DetailViewController.m
//  CoffeeShop
//
//  Created by CQUGSR on 28/02/2017.
//  Copyright © 2017 Tamanna. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)configureView {
    // Update the user interface for the detail item.
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    NSLog(@"_urlString %@",_urlString);
    NSURL *url = [NSURL URLWithString:_urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:urlRequest];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Managing the detail item




@end
