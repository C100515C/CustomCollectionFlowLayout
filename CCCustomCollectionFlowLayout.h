//
//  CCCustomCollectionFlowLayout.h
//  CCCustomCollectionLayout
//
//  Created by 董杰 on 16/11/21.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCCustomCollectionFlowLayout : UICollectionViewFlowLayout

/**
 横向  间距
 */
@property (nonatomic,assign) CGFloat interItemSpacing;

/**
 纵向 间距
 */
@property (nonatomic,assign) CGFloat lineSpacing;

/**
 collection 大小
 */
@property (nonatomic,assign) CGSize collectionSize;

@property (nonatomic,assign) CGRect HeaderRect;

@end
