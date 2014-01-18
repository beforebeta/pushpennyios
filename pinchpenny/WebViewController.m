//
//  WebViewController.m
//  pinchpenny
//
//  Created by Tackable Inc on 11/4/13.
//  Copyright (c) 2013 tackable. All rights reserved.
//

#import "WebViewController.h"
#import "Flurry.h"

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;

@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, [UIFont fontWithName:@"Avenir-Light" size:18.0], UITextAttributeFont,nil];
    UIImage *buttonImage = [UIImage imageNamed:@"btn-back.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 30, 30);
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = customBarItem;
    _labelTitle.text = _strSourceName;
    NSLog(@"_strSourceName = %@",_strSourceName);
    _webView.delegate = self;
    NSString *fullURL;
    if (!_strURL) {
        fullURL = @"http://pushpenny.com/";
    } else {
        fullURL = _strURL;
    }
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:requestObj];
    self.screenName = @"Webview Screen";

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [Flurry logPageView];
}


-(void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [_activityIndicator startAnimating];
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView;
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_activityIndicator stopAnimating];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_activityIndicator stopAnimating];
}

@end
