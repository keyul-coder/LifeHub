//
//  WaterProgressView.swift
//  LifeHub
//
//  Created by Smit Patel on 07/06/25.
//

import UIKit

class WaterProgressView: UIView {
    private let shapeLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()

    override func layoutSubviews() {
        super.layoutSubviews()
        setupCircle()
    }

    private func setupCircle() {
        backgroundLayer.removeFromSuperlayer()
        shapeLayer.removeFromSuperlayer()

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = bounds.width / 2 - 10
        let startAngle = -CGFloat.pi / 2
        let endAngle = 1.5 * CGFloat.pi
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

        backgroundLayer.path = path.cgPath
        backgroundLayer.strokeColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineWidth = 10
        backgroundLayer.lineCap = .round
        layer.addSublayer(backgroundLayer)

        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.systemBlue.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.lineCap = .round
        shapeLayer.strokeEnd = 0
        layer.addSublayer(shapeLayer)
    }

    func setProgress(_ value: CGFloat) {
        shapeLayer.strokeEnd = value
    }
}
