//
//  CVDataSource.h
//  ColV
//
//  Created by Igor Bogatchuk on 3/7/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CVDataSource;

@protocol CVDataSourceDelegate<NSObject>

- (void)dataSourceDidLoadData:(CVDataSource*)datasource;
- (void)dataSourceDidRefresh:(CVDataSource*)datasource;

@end

@interface CVDataSource : NSObject

@property (nonatomic, weak) id<CVDataSourceDelegate> delegate;

- (void)loadMore;
- (void)refresh;

- (id)itemAtIndexPath:(NSIndexPath*)indexPath;
- (NSInteger)numberOfItems;

@end
