//
//  CVRefreshReloadCollectionView.m
//  ColV
//
//  Created by Igor Bogatchuk on 3/11/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////
#import "CVRefreshReloadCollectionView.h"

////////////////////////////////////////////////////////////////////////////////////
#define REFRESH_THRESHOLD 60
#define ANIMATION_DURATION 0.2
#define ACTIVITY_VIEW_WIDTH 60
#define INDICATOR_SIDE_WIDTH 30

////////////////////////////////////////////////////////////////////////////////////
NSString* const CVActivityViewWillStartIndicatingActivityNotification = @"CVActivityViewWillStartIndicatingActivityNotification";
NSString* const CVActivityViewWillStopIndicatingActivityNotification = @"CVActivityViewWillStopIndicatingActivityNotification";
NSString* const CVACtivityViewWillStartRisingNotification = @"CVACtivityViewWillStartRisingNotification";
NSString* const CVActivityViewWillStartFallingNotification = @"CVActivityViewWillStartFallingNotification";

NSString* const kCVActivityViewKey = @"kCVActivityViewKey";

////////////////////////////////////////////////////////////////////////////////////
@interface CVRefreshReloadActivityView : UIView
@end

////////////////////////////////////////////////////////////////////////////////////
typedef void (^CVCollectionViewDataSourceRefreshBlock)(void);
typedef void (^CVCollectionViewDataSourceRefreshCompletionHandler)(void);
typedef void (^CVCollectionViewDataSourceLoadMoreBlock)(void);
typedef void (^CVCollectionViewDataSourceLoadMoreCompletionhandler)(void);

////////////////////////////////////////////////////////////////////////////////////
@interface CVRefreshReloadCollectionView()
{
    UIView* _leftActivityView;
    UIView* _rightActivityView;
}

@property (nonatomic, copy) CVCollectionViewDataSourceRefreshBlock refreshBlock;
@property (nonatomic, copy) CVCollectionViewDataSourceRefreshCompletionHandler refreshCompletionHandler;
@property (nonatomic, copy) CVCollectionViewDataSourceLoadMoreBlock loadMoreBlock;
@property (nonatomic, copy) CVCollectionViewDataSourceLoadMoreCompletionhandler loadMoreCompletionHandler;

@property BOOL isCollectionViewBusy;

@property (nonatomic, strong) UIPanGestureRecognizer* panRecognizer;

@end

////////////////////////////////////////////////////////////////////////////////////
@implementation CVRefreshReloadCollectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialSetup];
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [self initialSetup];
}

- (void)initialSetup
{
    self.adjustContentOffset = 20;
    self.panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureDidRecognized:)];
    self.panRecognizer.maximumNumberOfTouches = 1;
    self.panRecognizer.minimumNumberOfTouches = 1;
    [self addGestureRecognizer:self.panRecognizer];
}

#pragma mark -

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (otherGestureRecognizer == self.panRecognizer)
    {
        return YES;
    }
    return NO;
}

#pragma mark -

- (void)setRefreshBlock:(void (^)(void))refreshBlock withCompletionHandler:(void (^)(void))completionHandler
{
    self.refreshBlock = refreshBlock;
    self.refreshCompletionHandler = completionHandler;
}

- (void)setLoadMoreBlock:(void(^)(void))loadMoreBlock withCompletionHandler:(void(^)(void))completionHandler
{
    self.loadMoreBlock = loadMoreBlock;
    self.loadMoreCompletionHandler = completionHandler;
}

#pragma mark -

- (UIView*)leftActivityView
{
    if (_leftActivityView == nil)
    {
        _leftActivityView = [[CVRefreshReloadActivityView alloc] initWithFrame:CGRectMake(-ACTIVITY_VIEW_WIDTH, 0, ACTIVITY_VIEW_WIDTH, self.frame.size.height)];
        [self addSubview:_leftActivityView];
    }
    return _leftActivityView;

}

- (void)setLeftActivityView:(UIView *)leftActivityView
{
    if (leftActivityView != _leftActivityView)
    {
        [_leftActivityView removeFromSuperview];
        
        CGRect frame = leftActivityView.frame;
        frame.origin.x = - frame.size.width;
        frame.origin.y = 0;
        [leftActivityView setFrame:frame];
        
        _leftActivityView = leftActivityView;
        [self addSubview:_leftActivityView];
    }
}

- (UIView*)rightActivityView
{
    if (_rightActivityView == nil)
    {
       _rightActivityView = [[CVRefreshReloadActivityView alloc] initWithFrame:CGRectMake(self.contentSize.width, 0, ACTIVITY_VIEW_WIDTH, self.frame.size.height)];
        [self addSubview:_rightActivityView];
    }
    else if (_rightActivityView.frame.origin.x == 0)
    {
        CGRect frame = _rightActivityView.frame;
        frame.origin.x = self.contentSize.width;
        frame.origin.y = 0;
        [_rightActivityView setFrame:frame];
        [self addSubview:_rightActivityView];
    }
    return _rightActivityView;
}

- (void)setRightActivityView:(UIView *)rightActivityView
{
    if (rightActivityView != _rightActivityView)
    {
        [_rightActivityView removeFromSuperview];
        
        CGRect frame = rightActivityView.frame;
        frame.origin.x = self.contentSize.width;
        frame.origin.y = 0;
        [rightActivityView setFrame:frame];
        
        if (_rightActivityView.frame.origin.x != 0)
        {
            [self addSubview:_rightActivityView];
        }
        _rightActivityView = rightActivityView;
    }
}

#pragma mark - PanGestureRecognizer

- (void)panGestureDidRecognized:(UIGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        [self handleScrolling];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self handlePanGesture];
    }
}

- (void)handleScrolling
{
    if (self.contentOffset.x >= self.contentSize.width - self.frame.size.width && self.contentOffset.x < self.contentSize.width - self.frame.size.width + REFRESH_THRESHOLD)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CVACtivityViewWillStartRisingNotification
                                                            object:self
                                                          userInfo:@{kCVActivityViewKey : self.rightActivityView}];
    }
    else if (self.contentOffset.x > self.contentSize.width - self.frame.size.width + REFRESH_THRESHOLD)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CVActivityViewWillStartFallingNotification
                                                            object:self
                                                          userInfo:@{kCVActivityViewKey : self.rightActivityView}];
    }
    
    if (self.contentOffset.x <= 0 && self.contentOffset.x > - REFRESH_THRESHOLD)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CVACtivityViewWillStartRisingNotification
                                                            object:self
                                                          userInfo:@{kCVActivityViewKey : self.leftActivityView}];
    }
    else if (self.contentOffset.x < - REFRESH_THRESHOLD)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CVActivityViewWillStartFallingNotification
                                                            object:self
                                                          userInfo:@{kCVActivityViewKey : self.leftActivityView}];
    }
}

- (void)handlePanGesture
{
    // left activity view - refresh
    if (self.contentOffset.x < - REFRESH_THRESHOLD && self.isCollectionViewBusy == NO)
    {
        self.isCollectionViewBusy = YES;
        [UIView animateWithDuration:0.1
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             UIEdgeInsets inset = self.contentInset;
                             inset.left += self.leftActivityView.bounds.size.width;
                             [self setContentInset:inset];
                         }
                         completion:^(BOOL finished) {
                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [[NSNotificationCenter defaultCenter] postNotificationName:CVActivityViewWillStartIndicatingActivityNotification
                                                                                         object:self
                                                                                       userInfo:@{kCVActivityViewKey : self.leftActivityView}];
                                 });
                                 if (self.refreshBlock)
                                 {
                                     dispatch_sync(dispatch_queue_create("com.refresh.collectionview", 0), ^{
                                         self.refreshBlock();
                                     });
                                 }
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [UIView animateWithDuration:0.1
                                                           delay:0
                                                         options:UIViewAnimationOptionAllowUserInteraction
                                                      animations:^{
                                                          UIEdgeInsets inset = self.contentInset;
                                                          inset.left -= self.leftActivityView.bounds.size.width;
                                                          [self setContentInset:inset];
                                                      } completion:^(BOOL finished) {
                                                          if (self.refreshCompletionHandler)
                                                          {
                                                              self.refreshCompletionHandler();
                                                          }
                                                           [[NSNotificationCenter defaultCenter] postNotificationName:CVActivityViewWillStopIndicatingActivityNotification
                                                                                                               object:self
                                                                                                             userInfo:@{kCVActivityViewKey : self.leftActivityView}];
                                                          self.isCollectionViewBusy = NO;
                                                      }];
                                 });
                             });
                         }];
    }
    // rigth activity view - load more
    else if (self.contentOffset.x >= self.contentSize.width - self.frame.size.width + REFRESH_THRESHOLD && self.isCollectionViewBusy == NO)
    {
        self.isCollectionViewBusy = YES;
        [UIView animateWithDuration:0.1
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             UIEdgeInsets inset = self.contentInset;
                             inset.right += self.rightActivityView.bounds.size.width;
                             [self setContentInset:inset];
                         }
                         completion:^(BOOL finished) {
                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [[NSNotificationCenter defaultCenter] postNotificationName:CVActivityViewWillStartIndicatingActivityNotification
                                                                                        object:self
                                                                                      userInfo:@{kCVActivityViewKey : self.rightActivityView}];
                                 });
                                 
                                 if (self.loadMoreBlock)
                                 {
                                     dispatch_sync(dispatch_queue_create("com.loadmore.collectionview", 0), ^{
                                         self.loadMoreBlock();
                                     });
                                 }
                                 
                                 dispatch_sync(dispatch_get_main_queue(), ^{
                                     [self reloadData];
                                 });
                                 
                                 dispatch_sync(dispatch_get_main_queue(), ^{
                                     [UIView animateWithDuration:0.1
                                                           delay:0
                                                         options:UIViewAnimationOptionAllowUserInteraction
                                                      animations:^{
                                                          UIEdgeInsets inset = self.contentInset;
                                                          inset.right -= self.rightActivityView.bounds.size.width;
                                                          [self setContentInset:inset];
                                                      } completion:^(BOOL finished) {
                                                          CGPoint offset = self.contentOffset;
                                                          offset.x = offset.x - self.rightActivityView.frame.size.width + self.adjustContentOffset;
                                                          [self setContentOffset:offset animated:YES];
                                                          
                                                          if (self.loadMoreCompletionHandler)
                                                          {
                                                              self.loadMoreCompletionHandler();
                                                          }
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:CVActivityViewWillStopIndicatingActivityNotification
                                                                                                              object:self
                                                                                                            userInfo:@{kCVActivityViewKey : self.rightActivityView}];
                                                          CGRect frame = self.rightActivityView.frame;
                                                          frame.origin.x = self.contentSize.width;
                                                          [self.rightActivityView setFrame:frame];
                                                          
                                                          self.isCollectionViewBusy = NO;
                                                      }];
                                 });
                             });
                         }];
    }
}

@end

#pragma mark -

////////////////////////////////////////////////////////////////////////////////////
@interface CVRefreshReloadActivityView()

@property (nonatomic, strong) UIActivityIndicatorView* activityIndicator;

@end

@implementation CVRefreshReloadActivityView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_activityIndicator setFrame:CGRectMake(frame.size.width/2 - INDICATOR_SIDE_WIDTH/2, frame.size.height/2 - INDICATOR_SIDE_WIDTH/2, INDICATOR_SIDE_WIDTH, INDICATOR_SIDE_WIDTH)];
        [self addSubview:_activityIndicator];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(activityViewWillStartFalling:)
                                                     name:CVActivityViewWillStartFallingNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(activityViewWillStartRising:)
                                                     name:CVACtivityViewWillStartRisingNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(activityViewWillStartIndicatingActivity:)
                                                     name:CVActivityViewWillStartIndicatingActivityNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activityViewWillStopIndicatingActivity:)
                                                     name:CVActivityViewWillStopIndicatingActivityNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)activityViewWillStartIndicatingActivity:(NSNotification*)notification
{
    if ([notification.userInfo objectForKey:kCVActivityViewKey] == self)
    {
        [self.activityIndicator startAnimating];
    }
}

- (void)activityViewWillStopIndicatingActivity:(NSNotification*)notification
{
    if ([notification.userInfo objectForKey:kCVActivityViewKey] == self)
    {
        [self.activityIndicator stopAnimating];
    }
}

- (void)activityViewWillStartFalling:(NSNotification*)notification
{
}

- (void)activityViewWillStartRising:(NSNotification*)notification
{
}

@end
