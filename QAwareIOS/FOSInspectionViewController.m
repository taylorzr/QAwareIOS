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
    NSString *url = self.inspectionWebView.request.URL.absoluteString;
    if ([url isEqualToString: @"http://qaware.herokuapp.com/forms/confirmation"])
    {
        [self.navigationController popViewControllerAnimated:YES];
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
