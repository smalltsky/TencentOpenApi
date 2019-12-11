//
//  UICommonDefine.h
//  sdkDemo
//
//  Created by xianminxiao on 2019/4/22.
//  Copyright © 2019年 qqconnect. All rights reserved.
//

#ifndef UICommonDefine_h
#define UICommonDefine_h

#define RGBAColor(r,g,b,a)  [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define RGBColor(r,g,b)     RGBAColor(r,g,b,1.0)
#define RGBColorC(c)        RGBColor((((int)c) >> 16),((((int)c) >> 8) & 0xff),(((int)c) & 0xff))

#endif /* UICommonDefine_h */
