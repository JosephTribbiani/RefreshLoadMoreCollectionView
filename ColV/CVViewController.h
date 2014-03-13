//
//  CVViewController.h
//  ColV
//
//  Created by Igor Bogatchuk on 3/5/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CVRefreshReloadCollectionView;

@interface CVViewController : UIViewController
@property (weak, nonatomic) IBOutlet CVRefreshReloadCollectionView *collectionView;

@end
