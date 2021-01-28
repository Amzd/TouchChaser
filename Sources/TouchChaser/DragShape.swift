//
//  DragShape.swift
//
//  Created by Casper Zandbergen on 14/11/2019.
//

import SwiftUI

@available(iOS 13.0, *)
struct DragShape: Shape {
    var points: [CGPoint]
    var maxWidth: CGFloat = 10
    
    func path(in rect: CGRect) -> Path {
        let widthMultiplier = maxWidth / CGFloat(points.count)
        var path = Path()
        var lastPoint: CGPoint!
        var lastLeft: CGPoint!
        var lastRight: CGPoint!
        for (index, point) in points.enumerated() {
            if index == 0 {
                lastPoint = point
                lastLeft = point
                lastRight = point
            } else {
                let angle = lastPoint.angle(to: point)
                let width = widthMultiplier * CGFloat(index)
                let newLeft = point.offset(byDistance: width, inDirection: angle)
                let newRight = point.offset(byDistance: width, inDirection: angle - 180)
                
                path.move(to: lastLeft)
                path.addLine(to: newLeft)
                path.addLine(to: newRight)
                path.addLine(to: lastRight)
                path.addLine(to: lastLeft)
                path.closeSubpath()
                lastLeft = newLeft
                lastRight = newRight
                lastPoint = point
                
                if index == points.count - 1 {
                    path.move(to: lastLeft)
                    path.addArc(center: point,
                                radius: width,
                                startAngle: .degrees(0),
                                endAngle: .degrees(360),
                                clockwise: false)
                    path.closeSubpath()
                }
            }
        }
        
        return path
    }
}

extension CGPoint {
    func angle(to comparisonPoint: CGPoint) -> CGFloat {
        let originX = comparisonPoint.x - self.x
        let originY = comparisonPoint.y - self.y
        let bearingRadians = atan2f(Float(originY), Float(originX))
        var bearingDegrees = CGFloat(bearingRadians).degrees
        while bearingDegrees < 0 {
            bearingDegrees += 360
        }
        return bearingDegrees
    }
    
    func offset(byDistance distance:CGFloat, inDirection degrees: CGFloat) -> CGPoint {
        let radians = (degrees - 90) * .pi / 180
        let vertical = sin(radians) * distance
        let horizontal = cos(radians) * distance
        return self.applying(CGAffineTransform(translationX:horizontal, y:vertical))
    }
}

extension CGFloat {
    var degrees: CGFloat {
        return self * CGFloat(180.0 / .pi)
    }
}
