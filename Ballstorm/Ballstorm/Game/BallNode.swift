import SpriteKit

final class BallNode: SKShapeNode {

    let radius: CGFloat

    init(radius: CGFloat) {
        self.radius = radius
        super.init()

        // kruh
        let rect = CGRect(
            x: -radius,
            y: -radius,
            width: radius * 2,
            height: radius * 2
        )
        self.path = CGPath(ellipseIn: rect, transform: nil)

        
        fillColor = .randomBallColor()
        strokeColor = .clear
        name = "ball"

        let body = SKPhysicsBody(circleOfRadius: radius)
        body.affectedByGravity = false
        body.isDynamic = true
        body.linearDamping = 0
        body.angularDamping = 0
        body.categoryBitMask = PhysicsCategory.ball
        body.collisionBitMask = PhysicsCategory.none
        body.contactTestBitMask = PhysicsCategory.bullet | PhysicsCategory.player

        self.physicsBody = body
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



extension SKColor {

    static func randomBallColor() -> SKColor {
        return SKColor(
            hue: CGFloat.random(in: 0...1),
            saturation: 0.85,
            brightness: 0.95,
            alpha: 1.0
        )
    }
}
