//
//  DynamicHeightCollectionViewLayout.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/03/17.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//
//  reference: https://github.com/52inc/SwiftyGiphy/blob/c564bead94b377aca483c402a60f0288e41f158d/Library/SwiftyGiphyGridLayout.swift
//

import UIKit

protocol DynamicHeightCollectionViewLayoutDelegate: class {
    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat
}

class DynamicHeightCollectionViewLayout: UICollectionViewLayout {
    weak var delegate: DynamicHeightCollectionViewLayoutDelegate?
    
    var padding: CGFloat = 10.0 {
        didSet {
            invalidateLayout()
        }
    }
    
    var preferredCellWidth: CGFloat = 150.0 {
        didSet {
            invalidateLayout()
        }
    }
    
    var columnWidth: CGFloat {
        let numberOfPaddingSections = numberOfColumns + 1
        
        let availableContentWidth = contentWidth - (CGFloat(numberOfPaddingSections) * padding)
        
        return floor(availableContentWidth / CGFloat(numberOfColumns))
    }
    
    var numberOfColumns: Int {
        return Int(floor(contentWidth / preferredCellWidth))
    }
    
    var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return collectionView!.bounds.width - (insets.left + insets.right)
    }
    
    fileprivate var cellAttributeCache = [UICollectionViewLayoutAttributes]()
    
    fileprivate(set) var contentHeight: CGFloat = 0.0
    
    override public func prepare() {
        
        if cellAttributeCache.isEmpty
        {
            contentHeight = padding
            
            var xOffset = [CGFloat]()
            
            for column in 0..<numberOfColumns
            {
                xOffset.append((CGFloat(column) * columnWidth) + (CGFloat(column + 1) * padding))
            }
            
            var column = 0
            var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
            
            for index in 0..<numberOfColumns
            {
                yOffset[index] = contentHeight
            }
            
            for item in 0..<collectionView!.numberOfItems(inSection: 0)
            {
                let indexPath = IndexPath(item: item, section: 0)
                
                guard let cellHeight = delegate?.collectionView(collectionView: collectionView!, heightForPhotoAtIndexPath: indexPath, withWidth: columnWidth) else {
                    continue
                }
                
                let height = padding + cellHeight
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: cellHeight)
                
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                cellAttributeCache.append(attributes)
                
                contentHeight = max(contentHeight, frame.maxY)
                yOffset[column] = yOffset[column] + height
                
                var columnWithLeastHeight = 0
                
                for currentColumn in 0..<numberOfColumns
                {
                    if yOffset[currentColumn] < yOffset[columnWithLeastHeight]
                    {
                        columnWithLeastHeight = currentColumn
                    }
                }
                
                column = columnWithLeastHeight
            }
        }
    }
    
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cellAttributeCache[indexPath.row]
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        return cellAttributeCache.filter({ $0.frame.intersects(rect) })
    }
    
    override public var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override public func invalidateLayout() {
        super.invalidateLayout()
        
        contentHeight = 0.0
        cellAttributeCache = [UICollectionViewLayoutAttributes]()
    }
    
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
