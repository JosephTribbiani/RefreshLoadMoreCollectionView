//
//  CVRefreshReloadCollectionView.h
//  ColV
//
//  Created by Igor Bogatchuk on 3/11/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////
#import <UIKit/UIKit.h>

//! Collection view with pull-to-refresh, pull-to-load-more features.
@interface CVRefreshReloadCollectionView : UICollectionView

@property (nonatomic, strong) UIView* leftActivityView;
@property (nonatomic, strong) UIView* rightActivityView;

//! The difference bettween content before and after loading more.
@property CGFloat adjustContentOffset;

- (void)setRefreshBlock:(void(^)(void))refreshBlock withCompletionHandler:(void(^)(void))completionHandler;
- (void)setLoadMoreBlock:(void(^)(void))loadMoreBlock withCompletionHandler:(void(^)(void))completionHandler;

@end

////////////////////////////////////////////////////////////////////////////////////
//! The following notifications describe the activity view current state.
extern NSString* const CVActivityViewWillStartIndicatingActivityNotification;
extern NSString* const CVActivityViewWillStopIndicatingActivityNotification;
extern NSString* const CVACtivityViewWillStartRisingNotification;
extern NSString* const CVActivityViewWillStartFallingNotification;

//! The key, to get the activity view from notification user info.
extern NSString* const kCVActivityViewKey;

