//
//  FOSInspectionViewController.m
//  QAwareIOS
//
//  Created by Brandon Manson on 9/28/14.
//  Copyright (c) 2014 FlockofSquirrels. All rights reserved.
//

#import "FOSInspectionViewController.h"

@interface FOSInspectionViewController () <UIWebViewDelegate>

@property BOOL initialPage;

@end

@implementation FOSInspectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.initialPage = YES;
    self.inspectionWebView.delegate = self;
    // Do any additional setup after loading the view.
    NSString *base = @"http://qaware.herokuapp.com/";
    NSURL *inspectionURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", base, _query]];
    NSLog(@"%@", inspectionURL);
    NSURLRequest *request = [NSURLRequest requestWithURL:inspectionURL];
    [self.inspectionWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:webView.request];
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)[cachedResponse response];
    long code = response.statusCode;
    NSLog(@"HTTP Response code: %ld", code);
    if (self.initialPage) {
        NSLog(@"This is the first time a page loaded");
        self.initialPage = NO;
    } else {
        if (code == 302){
            NSLog(@"Happiness has been achieved");
        } else if (code == 422) {
            NSLog(@"You did something very stupid");
        } else {
            NSLog(@"Either you cancelled or something went terribly wrong");
        }
    }
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
