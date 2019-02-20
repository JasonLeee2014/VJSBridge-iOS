# VJSBridge-iOS
This project make a bridge between Objective-C and JavaScript in a Vue project.  It provides safe and convenient way to call objC code from Vue and call Vue method from objC.



### Features

- based on WKWebView, so faster.
- easy to integrated to existed Vue project, and easy to use. There is no more method registration, no more complex message  handles. Indeed, what you have to do, is just write your own native module like a normal objC object, and done! you can now call this native module from your js code directly, and get the response from native module simply via a callback function.

### Usage

####Vue call native module

**in ios:**

1. Install VJSBridge via cocoapods, your Podfile will be look like this.

   ```ruby
   target 'You Target' do 
       pod 'VJSBridge'
   end
   ```

   Then 

   `pod install`

   Next, open the created workspace to use VJSBridge in your project.

2. you have to load your website in a `NativeWebView`, this class is actually identical to the `WKWebView` except it can handle the communication between js and objC code automatically for you.

   Your code will be look like this

   ```objective-c
   #import <NativeWebView.h>
   ...
   - (void)viewDidLoad {
       [super viewDidLoad];
       WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
       webView = [[NativeWebView alloc] initWithFrame:CGRectZero configuration:config];
       webView.parentViewController = self;//you have to remember to set current ViewController to the webView's parentViewController attribute, so that you could access current viewcontroller in your native module later.
       
       [self.view addSubview:webView];
       
       [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"your url"]]];
       
   }
   ...
   ```

3. After these setups, now you have to create some **native modules** to do some **native works**, here, I mean you have to create a subclass of `NativeModule`, and write your native functionality code in this class.

   It is quite easy, just like this

   ```objective-c
   //"DemoNativeModule.h"
   #import "DemoNativeModule.h"
   
   @interface DemoNativeModule : NativeModule
   
   -(void)nativeMethod:(NSString*)jsonData;
   
   @end
       
   //"DemoNativeModule.m"
   #import "DemoNativeModule.h"
   #import <UIKit/UIKit.h>
   
   @implementation DemoNativeModule
   
   //⚠️remember. Your method should always like this: !!!one parameter !!!
   -(id)nativeMethod:(NSString*)jsonData{
       //you can get current webView and current viewcontroller from these 2 attributes:
       //@property(nonatomic,weak) NativeWebView* currentWebView;
       //@property(nonatomic,weak) UIViewController* currentViewController;
       
       return jsonData;//you can natively return some results, so that js can get the results in callback, you don't have to create callback functions in your js context, VJSBridge will handle it automatically.
   }
   ```

4. Final step, add your native modules into your webView in one line

   ```objective-c
   [webView addNativeModule:[[DemoNativeModule alloc] init]];
   ```

   And done!👏

   These are all the things you have to do in your iOS project.

   You might wonder why you haven't set the bridgename or method name like usual, so that the js can call the right native method.

   Well, actually, you have already done that, or in other words, VJSBridge have helped you done that~

   Indeed, you can call the native method in your Vue project like this

   ```js
   this.$native('DemoNativeModule.nativeMethod',{data:'data'},(value)=>{
       //here the value are the response from the return statement in your native module.
       console.log(value)
   })
   ```

   but before that, you have to do some setups, so that your Vue project can understand how to call the native method.

**In Vue project:**

GET MORE INFO FROM [link](https://github.com/JasonLeee2014/jj-vue-bridge)

1. install `jj-vue-bridge` plugin

   `npm install jj-vue-bridge`

   import it, and use it

   ```js
   import Native from 'jj-vue-bridge'
   ...
   Vue.use(Native)
   ...
   ```

2. call the native method

   ```js
   this.$native('DemoNativeModule.nativeMethod',{data:'data'},(value)=>{
       //here the value are the response from the return statement in your native module.
       console.log(value)
   })
   ```

   There are 3 arguments in this function

   - native method name, format like this ：className.methodName
   - data send to the native module, an object
   - Callback

#### Native call Vue method

**In Vue project:**

all you have to do is register method into your Vue project. 2 ways:

```js
//1
this.$regist('methodName',()=>{
    //do something
    return something
})

//2
this.$regist('methodName',method)//method is defined in your vue options.
```

you can revoke the registration anytime later

Like this

```js
this.$revoke('methodName')
```

**In iOS:**

you call can the registered Vue method like this

```objective-c
[webView callJSMethod:@"methodName" params:@{@"deta":@"data"} completeHandler:^(id  _Nullable value) {
        //here value, is the return value in the Vue js method.
    }];
```

