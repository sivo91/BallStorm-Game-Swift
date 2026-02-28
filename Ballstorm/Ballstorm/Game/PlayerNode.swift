import SpriteKit

final class PlayerNode: SKShapeNode {

    convenience init(size: CGSize) {
        self.init()

        name = "player"

       
        let path = CGMutablePath()

        let halfWidth = size.width / 2
        let halfHeight = size.height / 2

        path.move(to: CGPoint(x: 0, y: halfHeight))
        path.addLine(to: CGPoint(x: -halfWidth, y: -halfHeight))
        path.addLine(to: CGPoint(x: halfWidth, y: -halfHeight))
        path.closeSubpath()

        self.path = path

        fillColor = .cyan
        strokeColor = .white
        lineWidth = 2

     
        let body = SKPhysicsBody(polygonFrom: path)
        body.isDynamic = false
        body.affectedByGravity = false
        body.categoryBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.none
        body.contactTestBitMask = PhysicsCategory.ball

        self.physicsBody = body
    }
}
