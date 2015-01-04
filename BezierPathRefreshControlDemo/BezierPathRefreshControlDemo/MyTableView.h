//
//  MyTableView.h
//  ZYQTableVDemo
//
//  Created by Zhao Yiqi on 13-8-21.
//  Copyright (c) 2013年 Zhao Yiqi. All rights reserved.
//

#import "BaseTableView.h"

@interface MyTableView : BaseTableView<UITableViewDelegate,UITableViewDataSource,ZYQTableViewDelegate,UIScrollViewDelegate>{
    NSMutableArray *items;
}

- (id)initWithFrame:(CGRect)frame plist:(NSString *)plist;

- (void) addItemsOnTop;
- (void) addItemsOnBottom;
- (NSString *) createRandomValue;

@end
