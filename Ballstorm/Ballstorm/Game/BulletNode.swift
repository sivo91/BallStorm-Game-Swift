import SpriteKit

final class BulletNode: SKShapeNode {

    convenience init(radius: CGFloat = 5) {
        
        self.init(circleOfRadius: radius)
        fillColor = .yellow
        strokeColor = .clear
        name = "bullet"
        

        let body = SKPhysicsBody(circleOfRadius: radius)
        body.affectedByGravity = false
        body.isDynamic = true
        body.usesPreciseCollisionDetection = true
        body.linearDamping = 0
        body.angularDamping = 0
        body.categoryBitMask = PhysicsCategory.bullet
        body.collisionBitMask = PhysicsCategory.none
        body.contactTestBitMask = PhysicsCategory.ball
        self.physicsBody = body
    }
}
