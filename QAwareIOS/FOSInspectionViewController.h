//
//  FOSInspectionViewController.h
//  QAwareIOS
//
//  Created by Brandon Manson on 9/28/14.
//  Copyright (c) 2014 FlockofSquirrels. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FOSInspectionViewController : UIViewController

@property (weak, nonatomic)IBOutlet UIWebView *inspectionWebView;
@property (strong, nonatomic)NSString *query;


@end
