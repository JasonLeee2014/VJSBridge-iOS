//
//  NativeWebView.h
//  nos
//
//  Created by zaka on 2019/2/19.
//  Copyright © 2019 zaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "NativeModule.h"

@interface NativeWebView : WKWebView <WKScriptMessageHandler>

@property(nonatomic,weak) UIViewController* parentViewController;

-(void)callJSMethod:(NSString*) method params:(NSDictionary*)params completeHandler:(void (^)(id  _Nullable value))completionHandler;

-(void)addNativeModule:(NativeModule*) nativeModule;



@end
