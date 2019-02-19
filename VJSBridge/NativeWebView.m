//
//  NativeWebView.m
//  nos
//
//  Created by zaka on 2019/2/19.
//  Copyright © 2019 zaka. All rights reserved.
//

#import "NativeWebView.h"
#import "Utils.h"
#import <objc/message.h>


@implementation NativeWebView{
    NSMutableDictionary<NSString*,id>* nativeModules;
    NSMutableDictionary<NSString*,id>* jsCallbackHandlers;
}

-(instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration{
    nativeModules = [[NSMutableDictionary alloc] init];
    jsCallbackHandlers = [[NSMutableDictionary alloc] init];
    configuration.userContentController = [[WKUserContentController alloc] init];
    
    [configuration.userContentController addScriptMessageHandler:self name:@"_private_bridge"];
    
    self = [super initWithFrame:frame configuration:configuration];
    if(self){
        [self setCustomUserAgent:@"native-webview"];
    }
    
    return self;
}

-(void)addNativeModule:(NativeModule*)nativeModule{
    nativeModule.currentWebView = self;
    nativeModule.currentViewController = self.parentViewController;
    [nativeModules setObject:nativeModule forKey:NSStringFromClass([nativeModule class])];
    [self registNativeModule:nativeModule];
}

-(void)registNativeModule:(NativeModule*)nativeModule{
    [self.configuration.userContentController addScriptMessageHandler:self name:NSStringFromClass([nativeModule class])];
}

-(void)callJSMethod:(NSString*) method params:(NSDictionary*)params completeHandler:(void (^)(id  _Nullable value))completionHandler{
    NSString* js = [NSString stringWithFormat:@"%@(%@);",method,[Utils convertToJsonData:params]];
    
    [jsCallbackHandlers setObject:completionHandler forKey:method];
    
    [self evaluateJavaScript:js completionHandler:nil];
}

-(void)callJSMethodInternal:(NSString*) method params:(NSDictionary*)params{
    NSString* js = [NSString stringWithFormat:@"%@(%@);",method,[Utils convertToJsonData:params]];
    [self evaluateJavaScript:js completionHandler:nil];
}

-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSString* moduleName = message.name;
    
    if([moduleName isEqualToString:@"_private_bridge"]){
        NSDictionary* messageBody = message.body;
        NSString* methodName = [messageBody objectForKey:@"method"];
        void (^ completionHandler)(id  _Nullable value) = jsCallbackHandlers[methodName];
        completionHandler([messageBody objectForKey:@"data"]);
        return;
    }
    
    NativeModule* module = nativeModules[moduleName];
    
    NSDictionary* messageBody = message.body;
    NSString* methodName = [messageBody objectForKey:@"method"];
    id dataJson = [messageBody objectForKey:@"data"];
    NSString* callbackName = [messageBody objectForKey:@"cbName"];
    
    
    id ret = NULL;
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@:",methodName]);
    if([module respondsToSelector:sel]){
        id(*action)(id,SEL,id) = (id(*)(id,SEL,id))objc_msgSend;
        ret = action(module,sel,dataJson);
    }
    
    if(ret && callbackName){
        [self callJSMethodInternal:callbackName params:@{@"ret":ret}];
    }
}

@end
