//
//  CollectionViewCell.h
//  SGImageBrowser
//
//  Created by 刘山国 on 2018/2/7.
//  Copyright © 2018年 山国. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kCollectionViewCellID = @"CollectionViewCell";

@interface CollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
