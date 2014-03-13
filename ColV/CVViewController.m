//
//  CVViewController.m
//  ColV
//
//  Created by Igor Bogatchuk on 3/5/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "CVViewController.h"
#import "CVCollectionViewCell.h"
#import "CVDataSource.h"
#import "CVRefreshReloadCollectionView.h"

#import "CVActivityView.h"

#define REFRESH_THRESHOLD 60

#define ACTIVITY_VIEW_WIDTH 60
#define INDICATOR_SIDE_WIDTH 30

@interface CVViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>
{
    CVDataSource* _dataSource;
}

@property (nonatomic, strong, readonly) CVDataSource* dataSource;

@end

@implementation CVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupLayout];
    [self setupRefreshingCollectionView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupLayout
{   
    UICollectionViewFlowLayout* layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(129, 188);
	layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
	layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
	[self.collectionView setCollectionViewLayout:layout animated:YES];
}

- (void)setupRefreshingCollectionView
{
    [self.collectionView setRefreshBlock:^{
        for (int i = 0; i < 1999; i++)
        {
            NSLog(@"refreshing");
        }
    } withCompletionHandler:^{
        NSLog(@"refreshed");
    }];
    
    [self.collectionView setLoadMoreBlock:^{
        [self.dataSource loadMore];
    } withCompletionHandler:^{
        NSLog(@"loaded more");
    }];
    
    CVActivityView* rightActivityView = [[CVActivityView alloc] initWithFrame:CGRectMake(0, 0, 60, self.collectionView.frame.size.height)
                                                                        image:[UIImage imageNamed:@"flipped_arrow.png"]];
    self.collectionView.rightActivityView = rightActivityView;
    
    CVActivityView* leftActivityView = [[CVActivityView alloc] initWithFrame:CGRectMake(0, 0, 60, self.collectionView.frame.size.height)
                                                                       image:[UIImage imageNamed:@"arrow.png"]];
    self.collectionView.leftActivityView = leftActivityView;
}

- (CVDataSource*)dataSource
{
    if (_dataSource == nil)
    {
        _dataSource = [CVDataSource new];
    }
    return _dataSource;
}

#pragma mark - CollectionViewDataSource

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CVCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    [cell.photoImageView setImage:[self.dataSource itemAtIndexPath:indexPath]];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataSource numberOfItems];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

@end
