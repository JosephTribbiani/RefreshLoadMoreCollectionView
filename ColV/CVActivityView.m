//
//  CVActivityView.m
//  ColV
//
//  Created by Igor Bogatchuk on 3/12/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "CVActivityView.h"

#define ANIMATION_DURATION 0.2
#define ACTIVITY_VIEW_WIDTH 60
#define INDICATOR_SIDE_WIDTH 30

@interface CVActivityView()

@property (nonatomic, strong) UIImageView* arrowImageView;
@property (nonatomic, strong) UIActivityIndicatorView* activityIndicator;

@end

@implementation CVActivityView

- (id)initWithFrame:(CGRect)frame image:(UIImage*)image
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_activityIndicator setFrame:CGRectMake(frame.size.width/2 - INDICATOR_SIDE_WIDTH/2, frame.size.height/2 - INDICATOR_SIDE_WIDTH/2, INDICATOR_SIDE_WIDTH, INDICATOR_SIDE_WIDTH)];
        [self addSubview:_activityIndicator];
        
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width/2 - INDICATOR_SIDE_WIDTH/2, frame.size.height/2 - INDICATOR_SIDE_WIDTH/2, INDICATOR_SIDE_WIDTH, INDICATOR_SIDE_WIDTH)];
        [_arrowImageView setImage:image];
        [self addSubview:_arrowImageView];
        
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

#pragma mark - CVActivityViewProtocol


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)activityViewWillStartIndicatingActivity:(NSNotification*)notification
{
    if ([notification.userInfo objectForKey:kCVActivityViewKey] == self)
    {
        [self.arrowImageView setHidden:YES];
        [self.activityIndicator startAnimating];
    }
}

- (void)activityViewWillStopIndicatingActivity:(NSNotification*)notification
{
    if ([notification.userInfo objectForKey:kCVActivityViewKey] == self)
    {
        [self.arrowImageView setHidden:NO];
        [self.activityIndicator stopAnimating];
    }
}

- (void)activityViewWillStartFalling:(NSNotification*)notification
{
    if ([notification.userInfo objectForKey:kCVActivityViewKey] == self)
    {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI * 0 / 180.0);
        }];
    }
}

- (void)activityViewWillStartRising:(NSNotification*)notification
{
    if ([notification.userInfo objectForKey:kCVActivityViewKey] == self)
    {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI * 180 / 180.0);
        }];
    }
}

@end
