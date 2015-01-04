//
//  BaseTableView.h
//  PhotoAlbum
//
//  Created by apple on 13-8-19.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ZYQTableView.h"
#import "BezierPathRefreshControl.h"
#import "TableFooterV.h"

@interface BaseTableView : ZYQTableView<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,ZYQTableViewDelegate>{
    BOOL isInit;
}

@property(nonatomic,retain)BezierPathRefreshControl *slimeView;

@property(nonatomic,assign)BOOL isEmpty;

- (id)initWithFrame:(CGRect)frame plist:(NSString*)plist;

@end
