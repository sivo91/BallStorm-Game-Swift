import SpriteKit

final class HUDNode: SKNode {

    private let background = SKShapeNode()
    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let livesLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")

    private(set) var score: Int = 0
    private(set) var lives: Int = 5

    override init() {
        super.init()

        // Background panel
        background.fillColor = SKColor.black.withAlphaComponent(0.35)
        background.strokeColor = .clear
        background.zPosition = -1
        addChild(background)

        // Score
        scoreLabel.fontSize = 26
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.text = "Score: 0"
        scoreLabel.fontColor = .white
        addChild(scoreLabel)

        // Lives
        livesLabel.fontSize = 26
        livesLabel.horizontalAlignmentMode = .right
        livesLabel.verticalAlignmentMode = .center
        livesLabel.text = "Lives: 5"
        livesLabel.fontColor = .white
        addChild(livesLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layout(in scene: SKScene) {
        
        let safeTop = scene.view?.safeAreaInsets.top ?? 0

        
        let extraOffset: CGFloat = 50
        let topPadding: CGFloat = 16

        let yPos = scene.size.height - safeTop - topPadding - extraOffset

       
        scoreLabel.position = CGPoint(x: 24, y: yPos)
        livesLabel.position = CGPoint(x: scene.size.width - 24, y: yPos)

        
        let panelHeight: CGFloat = 52
        background.path = CGPath(
            rect: CGRect(
                x: 0,
                y: yPos - panelHeight / 2,
                width: scene.size.width,
                height: panelHeight
            ),
            transform: nil
        )
    }

    func addScore(_ value: Int) {
        score += value
        scoreLabel.text = "Score: \(score)"

       
        let pulse = SKAction.sequence([
            .scale(to: 1.15, duration: 0.08),
            .scale(to: 1.0, duration: 0.08)
        ])
        scoreLabel.run(pulse)
    }

    func setLives(_ value: Int) {
        lives = value
        livesLabel.text = "Lives: \(lives)"

        
        livesLabel.fontColor = (lives <= 1) ? .systemRed : .white

       
        let flash = SKAction.sequence([
            .fadeAlpha(to: 0.25, duration: 0.08),
            .fadeAlpha(to: 1.0, duration: 0.08)
        ])
        livesLabel.run(flash)
    }

    func reset(lives: Int = 5) {
        score = 0
        self.lives = lives
        scoreLabel.text = "Score: 0"
        livesLabel.text = "Lives: \(lives)"
        livesLabel.fontColor = .white
    }
}
