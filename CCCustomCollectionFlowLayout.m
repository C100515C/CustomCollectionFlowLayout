//
//  CCCustomCollectionFlowLayout.m
//  CCCustomCollectionLayout
//
//  Created by 董杰 on 16/11/21.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "CCCustomCollectionFlowLayout.h"

@interface CCCustomCollectionFlowLayout ()

/**
 存储 布局的 att
 */
@property (nonatomic,strong) NSMutableArray *layoutInfoArr;

/**
 collection 滑动区域大小
 */
@property (nonatomic,assign) CGSize contentSize;

/**
 记录 前一个frame  用来布局 当前cell 的frame
 */
@property (nonatomic,assign) CGRect tmpRect;

/**
 记录 自动换行 次数
 */
@property (nonatomic,assign) NSInteger lineNum;

@end

@implementation CCCustomCollectionFlowLayout

/**
 布局 布局配置数据  布局前的准备会调用这个方法
 */
- (void)prepareLayout{
    [super prepareLayout];
    /*添加  header  footer  需要调 此方法
      UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathWithIndex:0]];
     //*/
    
    NSMutableArray *layoutInfoArr = [NSMutableArray array];
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    [layoutInfoArr addObject:@[attributes]];
    
    NSInteger maxNumberOfItems = 0;
    //获取布局信息
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    for (NSInteger section = 0; section < numberOfSections; section++){
        NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
        NSMutableArray *subArr = [NSMutableArray arrayWithCapacity:numberOfItems];
        
        for (NSInteger item = 0; item < numberOfItems; item++){
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            
            [subArr addObject:attributes];
        }
        if(maxNumberOfItems < numberOfItems){
            maxNumberOfItems = numberOfItems;
        }
        //添加到二维数组
        [layoutInfoArr addObject:[subArr copy]];
    }
    
    //存储布局信息
    self.layoutInfoArr = [layoutInfoArr copy];
#if 0
    //保存内容尺寸
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        //水平
        self.contentSize = CGSizeMake(maxNumberOfItems*(self.itemSize.width+self.interItemSpacing)+self.interItemSpacing, numberOfSections*(self.itemSize.height+self.lineSpacing)+self.lineSpacing);

    }else{
        //竖直
        self.contentSize = CGSizeMake(numberOfSections*(self.itemSize.width+self.lineSpacing)+self.lineSpacing,maxNumberOfItems*(self.itemSize.height+self.interItemSpacing)+self.interItemSpacing);

    }
#else
    
    //保存内容尺寸
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        //水平
        NSArray *tmpArr = [layoutInfoArr lastObject];
        UICollectionViewLayoutAttributes *att = [tmpArr lastObject];
        self.contentSize = CGSizeMake(att.frame.origin.x+att.size.width+self.interItemSpacing, self.collectionSize.height);
        
    }else{
        //竖直
        NSArray *tmpArr = [layoutInfoArr lastObject];
        UICollectionViewLayoutAttributes *att = [tmpArr lastObject];
        self.contentSize = CGSizeMake(self.collectionSize.width,att.frame.origin.y+att.size.height+self.lineSpacing);
        
    }
    
#endif
    
}

/**
 创建 布局 对象

 @param indexPath indexPath description

 @return 布局  对象
 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
#if 0
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        //水平
        attributes.frame = CGRectMake((self.itemSize.width+self.interitemSpacing)*indexPath.row+self.interitemSpacing, (self.itemSize.height+self.lineSpacing)*indexPath.section+self.lineSpacing, self.itemSize.width, self.itemSize.height);

    }else{
        //竖直
        attributes.frame = CGRectMake((self.itemSize.width+self.interitemSpacing)*indexPath.section+self.interitemSpacing, (self.itemSize.height+self.lineSpacing)*indexPath.row+self.lineSpacing, self.itemSize.width, self.itemSize.height);

    }
#else
    attributes.size = self.itemSize;
    CGSize tmpSize = self.itemSize;
    if (indexPath.row%3!=0) {
        attributes.size = CGSizeMake(tmpSize.width, (tmpSize.height-self.lineSpacing)/2.0);
    }
    attributes.frame = [self layoutCellWith:attributes andIndex:indexPath];
    
#endif

    self.tmpRect = attributes.frame;
    
    return attributes;
}

- (CGSize)collectionViewContentSize{
    return self.contentSize;
}
///*
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray *layoutAttributesArr = [NSMutableArray array];
    [self.layoutInfoArr enumerateObjectsUsingBlock:^(NSArray *array, NSUInteger i, BOOL * _Nonnull stop) {
        [array enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(CGRectIntersectsRect(obj.frame, rect)) {
               [layoutAttributesArr addObject:obj];
            }
        }];
    }];
    return layoutAttributesArr;
    //return self.layoutInfoArr;
}
 //*/

/**
 计算 自动换行

 @param attributes attributes description
 @param indexPath  indexPath description

 @return 计算后的cell frame
 */
-(CGRect)layoutCellWith:(UICollectionViewLayoutAttributes*)attributes andIndex:(NSIndexPath*)indexPath{
    
    CGRect resultFrame =attributes.frame;
    CGSize cellSize = attributes.size;
    
    CGFloat tmpX = self.tmpRect.origin.x;
    CGFloat tmpY = self.tmpRect.origin.y;
    CGFloat tmpW = self.tmpRect.size.width;
    CGFloat tmpH = self.tmpRect.size.height;

    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        //水平
        CGRect tmp;
        CGFloat limit = tmpY+tmpH+self.lineSpacing+cellSize.height;
        if (limit>self.collectionSize.height) {
            tmp = CGRectMake(tmpX+self.interItemSpacing+cellSize.width,self.lineSpacing,cellSize.width,cellSize.height);
            self.lineNum ++;
        }else{
            tmp = CGRectMake(tmpX,tmpY+tmpH+self.lineSpacing,cellSize.width,cellSize.height);

        }
        resultFrame = tmp;
        
        
    }else{
        
        CGRect tmp;
        
        if (indexPath.row%3==0) {
            tmpX = self.interItemSpacing;
            tmpY = self.HeaderRect.size.height + self.lineSpacing + (cellSize.height+self.lineSpacing)*indexPath.row/3;
            
        }else{
            
            tmpX = 2*self.interItemSpacing + cellSize.width;
            tmpY = self.HeaderRect.size.height+self.lineSpacing + (cellSize.height+self.lineSpacing)*((indexPath.row/3)*2+(indexPath.row%3-1));
        }
        
        /*
        CGFloat limit = tmpX+self.interItemSpacing+tmpW+cellSize.width;
        
        if (limit>self.collectionSize.width) {
            
            tmp = CGRectMake(self.interItemSpacing,tmpY+tmpH+self.lineSpacing,cellSize.width,cellSize.height);
            self.lineNum ++;
            
        }else{
            tmp = CGRectMake(tmpX+self.interItemSpacing+tmpW,tmpY,cellSize.width,cellSize.height);

        }*/
        
        tmp.origin = CGPointMake(tmpX, tmpY);
        tmp.size = cellSize;
        resultFrame = tmp;
    }
    

    
    return resultFrame;
}

//组上下 头 view
-(UICollectionViewLayoutAttributes*)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    
    //attrs.size = CGSizeMake(ScreenWidth, 350);
    attrs.frame = self.HeaderRect;//CGRectMake(0, 0, ScreenWidth, 350);
    
    return attrs;
}

@end
