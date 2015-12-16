//
//  StatusBar.m
//  Cordova StatusBar Plugin
//
//  Created by Ville Karavirta on 10/7/13.
//
//

#import "StatusBar.h"
#import <Cordova/CDV.h>

@interface StatusBar () <UIScrollViewDelegate>

@property NSString* eventsCallbackId;
- (void)fireTappedEvent;
- (void)setTapListener:(CDVInvokedUrlCommand*)command;
- (void)_sendPluginResult:(CDVInvokedUrlCommand*)command;

@end

@implementation StatusBar

- (void)pluginInitialize
{
  // blank scroll view to intercept status bar taps
  self.webView.scrollView.scrollsToTop = NO;
  UIScrollView *fakeScrollView = [[UIScrollView alloc] initWithFrame:UIScreen.mainScreen.bounds];
  fakeScrollView.delegate = self;
  fakeScrollView.scrollsToTop = YES;
  [self.viewController.view addSubview:fakeScrollView]; // Add scrollview to the view heirarchy so that it will begin accepting status bar taps
  [self.viewController.view sendSubviewToBack:fakeScrollView]; // Send it to the very back of the view heirarchy
  fakeScrollView.contentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height * 2.0f); // Make the scroll view longer than the screen itself
  fakeScrollView.contentOffset = CGPointMake(0.0f, UIScreen.mainScreen.bounds.size.height); // Scroll down so a tap will take scroll view back to the top
}

- (void)fireTappedEvent
{
  if (_eventsCallbackId == nil) {
    return;
  }
  NSDictionary* payload = @{@"type": @"tap"};
  CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:payload];
  [result setKeepCallbackAsBool:YES];
  [self.commandDelegate sendPluginResult:result callbackId:_eventsCallbackId];
}

- (void)setTapListener:(CDVInvokedUrlCommand*)command
{
  _eventsCallbackId = command.callbackId;
}

- (void)hideStatusBar:(CDVInvokedUrlCommand*)command
{
  // Toggle the visibility of the statusbar if it is not currently hidden
  if (![UIApplication sharedApplication].statusBarHidden)
  {
    [self toggleStatusBar:command];
  }

  // Send the result (the height of the statusbar)
  [self _sendPluginResult:command];
}

- (void)showStatusBar:(CDVInvokedUrlCommand*)command
{
  // Toggle the visibility of the statusbar if it is currently hidden
  if ([UIApplication sharedApplication].statusBarHidden)
  {
    [self toggleStatusBar:command];
  }

  // Send the result (the height of the statusbar)
  [self _sendPluginResult:command];
}

- (void)toggleStatusBar:(CDVInvokedUrlCommand*)command
{
  NSDictionary* options = [command.arguments objectAtIndex:0];
  NSString* animation = options[@"animation"];
  NSInteger animType = UIStatusBarAnimationNone;
  if ([animation isEqualToString:@"slide"]) {
    animType = UIStatusBarAnimationSlide;
  } else if ([animation isEqualToString:@"fade" ]){
    animType = UIStatusBarAnimationFade;
  }
  BOOL newHiddenState = ![UIApplication sharedApplication].statusBarHidden;
  [[UIApplication sharedApplication] setStatusBarHidden:newHiddenState withAnimation:animType];

  // Send the result (the height of the statusbar)
  [self _sendPluginResult:command];
}

- (void) setStyle:(CDVInvokedUrlCommand*)command
{
  NSDictionary* options = [command.arguments objectAtIndex:0];
  NSString* newStyle = options[@"style"];
  // By default use Default style
  NSInteger style = UIStatusBarStyleDefault;
  // ..but if option is lightcontent, use LightContent
  if ([newStyle isEqualToString:@"lightcontent"]) {
    style = UIStatusBarStyleLightContent;
  }
  // Get the option indicating whether ot not to animate the style change
  BOOL animate = (BOOL) options[@"animate"];

  // Set the style
  [[UIApplication sharedApplication] setStatusBarStyle:style animated:animate];

  // Send the result (the height of the statusbar)
  [self _sendPluginResult:command];
}

- (void)height:(CDVInvokedUrlCommand*)command
{
  // Nothing to do but send the result (the height of the statusbar)
  [self _sendPluginResult:command];
}

- (void)_sendPluginResult:(CDVInvokedUrlCommand*)command
{
  CDVPluginResult* pluginResult = nil;
  // Get the app orientation
  NSInteger orient = [UIApplication sharedApplication].statusBarOrientation;
  CGFloat height;
  // If portrait orientation, use height of statusbar
  if (orient == UIInterfaceOrientationPortrait || orient == UIInterfaceOrientationPortraitUpsideDown) {
    height = [UIApplication sharedApplication].statusBarFrame.size.height;
  } else { // In landscape, use width
    height = [UIApplication sharedApplication].statusBarFrame.size.width;
  }
  // Create and send the plugin result
  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:height];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView*)scrollView
{
  [self fireTappedEvent];
  return NO;
}

@end
