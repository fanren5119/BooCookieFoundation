# BooCookieFoundation
## BooCookieFoundation使用使用
### 1.只使用剪贴板
```
这里传递的参数是一个正则表达式,用来判断从剪贴板拿到的字符串,是否符合要求
    [BooCookieGetManager getCookieWithPlaseBoard:nil completeBlock:^(NSDictionary *cookie) {
        NSLog(@"cookie = %@", cookie);
    }];
```
### 2.只使用SafariViewController
```
这里传递的参数是一个地址,用来打开SafariViewController
    [BooCookieGetManager getCookieWithSafariURL:nil completeBlock:^(NSDictionary *cookie) {
        NSLog(@"cookie = %@", cookie);
    }];
	同时在AppDelegate中,要实现下边的代理方法
	- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
	{
    	[BooCookieGetManager applicationOpenURL:url options:options];
    	return YES;
	}
```
### 3.剪贴板和SafariViewController一起使用
```
    [BooCookieGetManager getCookieWithSafariURL:nil regexpString:nil completeBlock:^(NSDictionary *cookie) {
        NSLog(@"cookie = %@", cookie);
    }];
	- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
	{
    	[BooCookieGetManager applicationOpenURL:url options:options];
    	return YES;
	}
```

