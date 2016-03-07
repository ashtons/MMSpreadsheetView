// Copyright (c) 2013 Mutual Mobile (http://mutualmobile.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MMGridLayout.h"
#import "MMSpreadsheetView.h"

@interface MMGridLayout ()

@property (nonatomic, assign) NSInteger gridRowCount;
@property (nonatomic, assign) NSInteger gridColumnCount;
@property (nonatomic, assign) BOOL isInitialized;

@end

@implementation MMGridLayout

- (id)init {
    self = [super init];
    if (self) {
        _cellSpacing = 1.0f;
        _itemSize = CGSizeMake(120.0f, 120.0f);
    }
    return self;
}

- (void)setItemSize:(CGSize)itemSize {
    _itemSize = CGSizeMake(itemSize.width + self.cellSpacing, itemSize.height + self.cellSpacing);
    [self invalidateLayout];
}

- (void)setCellSpacing:(CGFloat)cellSpacing {
    _cellSpacing = cellSpacing;
    [self invalidateLayout];
}

- (void)prepareLayout {
    [super prepareLayout];
    self.gridRowCount = [self.collectionView numberOfSections];
    self.gridColumnCount = [self.collectionView numberOfItemsInSection:0];
    
    if (!self.isInitialized) {
        id<UICollectionViewDelegateFlowLayout> delegate = (id)self.collectionView.delegate;
        CGSize size = [delegate collectionView:self.collectionView
                                        layout:self
                        sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        self.itemSize = size;
        self.isInitialized = YES;
    }
}

- (CGSize)collectionViewContentSize {
    if (!self.isInitialized) {
        [self prepareLayout];
    }
    NSInteger totalWidth = 0;
    for(NSNumber *width in self.cellWidths) {
        totalWidth = totalWidth + [width integerValue];
    }
    CGSize size = CGSizeMake(totalWidth, self.gridRowCount * self.itemSize.height);
    return size;
}
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributes = [NSMutableArray array];
    NSUInteger startRow = floorf(rect.origin.y / self.itemSize.height); //Row heights constant
    NSUInteger endRow = MIN(self.gridRowCount - 1, ceilf(CGRectGetMaxY(rect) / self.itemSize.height));
    NSUInteger startCol = 0;
    NSUInteger endCol = 0;
    NSInteger leftEdge = 0;
    for(NSNumber *cellWidth in self.cellWidths) {
        leftEdge += [cellWidth integerValue];
        if (leftEdge >= rect.origin.x) {
            break;
        }
        startCol += 1;
    }
    for(NSNumber *cellWidth in self.cellWidths) {
        leftEdge += [cellWidth integerValue];
        if (leftEdge > (rect.origin.x + rect.size.width)) {
            break;
        }
        endCol += 1;
    }
    if ((int)self.gridColumnCount-1 >= (int)self.cellWidths.count) {
        NSLog(@"here");
    }
    endCol = self.gridColumnCount - 1;
    for (NSUInteger row = startRow; row <= endRow; row++) {
        for (NSUInteger col = startCol; col <=  endCol; col++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:col inSection:row];
            UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            [attributes addObject:layoutAttributes];
        }
    }
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    NSInteger width = 0;
    if (indexPath.item < (int)self.cellWidths.count) {
        width = [[self.cellWidths objectAtIndex:indexPath.item] integerValue];
    }
    NSInteger leftEdge = 0;
    for(NSInteger i=0;i < indexPath.item;i++) {
        leftEdge += [[self.cellWidths objectAtIndex:i] integerValue];
    }
    attributes.frame = CGRectMake(leftEdge, indexPath.section * self.itemSize.height, width-self.cellSpacing, self.itemSize.height-self.cellSpacing);
    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(__unused CGRect)newBounds {
    return NO;
}

@end
