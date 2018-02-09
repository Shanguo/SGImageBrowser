//
//  ViewController.m
//  SGImageBrowser
//
//  Created by 刘山国 on 2018/2/6.
//  Copyright © 2018年 山国. All rights reserved.
//

#import "ViewController.h"
#import "SGImageBrowser.h"
#import "CollectionViewCell.h"
#import <UIImageView+WebCache.h>

static NSString * const kBaseImgUrl = @"http://ogostzcyh.bkt.clouddn.com/";

typedef NS_ENUM(NSUInteger, ImageUrlType) {
    URL_Small,
    URL_Middle,
    URL_Origin
};


@interface ViewController () <UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic,copy  ) NSArray *imgNames;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imgNames = @[@"WechatIMG353.jpeg",@"WechatIMG354.png",@"WechatIMG355.jpeg",@"WechatIMG356.jpeg",@"WechatIMG357.jpeg",@"WechatIMG359.jpeg",@"WechatIMG361.jpeg"];
    [self.collectionView registerNib:[UINib nibWithNibName:kCollectionViewCellID bundle:nil] forCellWithReuseIdentifier:kCollectionViewCellID];
}

- (IBAction)tap:(id)sender {
    [SGImageBrowser show:self.imageView];
}
- (IBAction)showSomePhotos:(id)sender {
    __weak typeof(self) weakSelf = self;
    [SGImageBrowser show:0 totalCount:self.imgNames.count placeHolderImageOrName:nil dataSource:^(NSInteger index, SGImageBrowserDataSourceBlock  _Nonnull dataSourceBlock) {
        NSURL *middleUrl = [weakSelf imageUrlWithType:URL_Middle atIndex:index];
        NSURL *originUrl = [weakSelf imageUrlWithType:URL_Origin atIndex:index];
        dataSourceBlock(nil,nil,middleUrl,originUrl,nil);
    }];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 3;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellID forIndexPath:indexPath];
    [cell.imageView sd_setImageWithURL:[self imageUrlWithType:URL_Small atIndex:indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    [SGImageBrowser show:indexPath.row totalCount:self.imgNames.count placeHolderImageOrName:nil dataSource:^(NSInteger index, SGImageBrowserDataSourceBlock  _Nonnull dataSourceBlock) {
        CollectionViewCell *cell = (CollectionViewCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        NSURL *middleUrl = [weakSelf imageUrlWithType:URL_Middle atIndex:index];
        NSURL *originUrl = [weakSelf imageUrlWithType:URL_Origin atIndex:index];
        dataSourceBlock(cell.imageView,nil,middleUrl,originUrl,@"1024KB");
    }];
}

- (NSURL *)imageUrlWithType:(ImageUrlType)type atIndex:(NSInteger)index{
    NSString *typeStr = nil;
    switch (type) {
        case URL_Small:
            typeStr = @"small";
            break;
        case URL_Middle:
            typeStr = @"middle";
            break;
        case URL_Origin:
            typeStr = @"origin";
            break;
        default:
            break;
    }
    NSString *imageUrl = [NSString stringWithFormat:@"%@%@-%@",kBaseImgUrl,self.imgNames[index],typeStr];
    return [NSURL URLWithString:imageUrl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
