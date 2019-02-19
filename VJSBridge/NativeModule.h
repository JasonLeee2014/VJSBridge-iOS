//
//  NativeModule.h
//  nos
//
//  Created by zaka on 2019/2/19.
//  Copyright © 2019 zaka. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NativeWebView;
@class UIViewController;

@interface NativeModule : NSObject

@property(nonatomic,weak) NativeWebView* currentWebView;
@property(nonatomic,weak) UIViewController* currentViewController;

@end

NS_ASSUME_NONNULL_END
