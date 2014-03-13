//
//  CVDataSource.m
//  ColV
//
//  Created by Igor Bogatchuk on 3/7/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "CVDataSource.h"

@interface CVDataSource()
{
    NSMutableArray *_images;
}

@property (nonatomic) NSInteger itemsCount;

@end

@implementation CVDataSource

- (id)init
{
    if (self = [super init])
    {
        self.itemsCount = 5;
        _images = [NSMutableArray new];
        for (int i = 0; i < 4; i++)
        {
            NSInteger randomNumber = arc4random() % 5 + 1;
            [_images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",randomNumber]]];
        }
    }
    return self;
}

- (void)loadMore
{
        for (int i = 0; i < 1999; i++)
        {
            NSLog(@"laoding");
        }
        
        for (int i = 0; i < 4; i++)
        {
            NSInteger randomNumber = arc4random() % 4 + 1;
            [_images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",randomNumber]]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate dataSourceDidLoadData:self];
        });

}

- (void)refresh
{
    //fake activity
    for (int i = 0; i < 1999; i++)
    {
        NSLog(@"refreshing");
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate dataSourceDidRefresh:self];
    });
}

- (id)itemAtIndexPath:(NSIndexPath*)indexPath
{
    return [_images objectAtIndex:indexPath.row];
}

- (NSInteger)numberOfItems
{
    return [_images count];
}

@end
