import SpriteKit

final class GameScene: SKScene, SKPhysicsContactDelegate {

    private var player: PlayerNode?
    private let hud = HUDNode()

    private var isDraggingPlayer = false

    private var lastSpawnTime: TimeInterval = 0
    private var spawnInterval: TimeInterval = 1.2

    private var gameStartTime: TimeInterval = 0
    private var difficultyLevel: Int = 0

    private var livesLeft: Int = 5
    private var isGameOver: Bool = false

    private var gameOverLabel: SKLabelNode?

    // MARK: - AUTO FIRE (NEW)
    private var autoFireEnabled = false
    private let autoFireActionKey = "autoFireAction"

    // MARK: - Side UI Button (NEW)
    private var autoButton: SKShapeNode!
    private var autoButtonLabel: SKLabelNode!

    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        backgroundColor = .black

        setupPlayer()
        setupHUD()

        // UI btn
        setupAutoFireButton()

        livesLeft = 5
        hud.setLives(livesLeft)

        gameStartTime = 0
        difficultyLevel = 0

        // vypni auto fire
        stopAutoFire()
        autoFireEnabled = false
        updateAutoButtonUI()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        hud.layout(in: self)

        guard let player else { return }
        player.position = CGPoint(x: size.width / 2, y: max(90, size.height * 0.12))

        // NEW: reposition button on resize
        layoutAutoFireButton()
    }

    private func setupPlayer() {
        let p = PlayerNode(size: CGSize(width: 60, height: 60))
        p.position = CGPoint(x: size.width / 2, y: max(90, size.height * 0.12))
        addChild(p)
        self.player = p
    }

    private func setupHUD() {
        addChild(hud)
        hud.layout(in: self)
    }

    // MARK: - Spawn

    private func spawnBall() {
        guard !isGameOver else { return }

        let radius = CGFloat.random(in: 16...38)
        let ball = BallNode(radius: radius)

        let x = CGFloat.random(in: radius...(size.width - radius))
        ball.position = CGPoint(x: x, y: size.height + radius + 10)
        addChild(ball)

        // rýchlosť sa mierne zvyšuje s obtiažnosťou
        let baseSpeed: CGFloat = 220 + CGFloat(difficultyLevel * 15)
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: -baseSpeed)

        ball.run(.sequence([
            .wait(forDuration: 6.0),
            .removeFromParent()
        ]), withKey: "life")
    }

    // MARK: - Shooting

    private func shoot() {
        guard !isGameOver else { return }
        guard let player else { return }

        let bullet = BulletNode(radius: 5)
        bullet.position = player.position
        addChild(bullet)

        bullet.physicsBody?.velocity = CGVector(dx: 0, dy: 520)
        bullet.run(.sequence([
            .wait(forDuration: 1.6),
            .removeFromParent()
        ]))
    }

    // MARK: - AUTO FIRE (NEW)
    private func toggleAutoFire() {
        autoFireEnabled.toggle()
        if autoFireEnabled {
            startAutoFire()
        } else {
            stopAutoFire()
        }
        updateAutoButtonUI()
    }

    private func startAutoFire() {
        removeAction(forKey: autoFireActionKey)

        // strielaj každých 0.18s
        let fire = SKAction.run { [weak self] in
            self?.shoot()
        }
        let wait = SKAction.wait(forDuration: 0.18)
        let loop = SKAction.repeatForever(.sequence([fire, wait]))

        run(loop, withKey: autoFireActionKey)
    }

    private func stopAutoFire() {
        removeAction(forKey: autoFireActionKey)
    }

    // MARK: - Side UI (NEW)
    private func setupAutoFireButton() {
        let btnSize = CGSize(width: 130, height: 44)

        autoButton = SKShapeNode(rectOf: btnSize, cornerRadius: 12)
        autoButton.name = "btn_auto"
        autoButton.zPosition = 2000
        autoButton.lineWidth = 2
        autoButton.strokeColor = .white.withAlphaComponent(0.35)

        autoButtonLabel = SKLabelNode(text: "AUTO: OFF")
        autoButtonLabel.name = "btn_auto"
        autoButtonLabel.fontName = "AvenirNext-Bold"
        autoButtonLabel.fontSize = 16
        autoButtonLabel.verticalAlignmentMode = .center
        autoButtonLabel.horizontalAlignmentMode = .center
        autoButtonLabel.zPosition = 2001

        autoButton.addChild(autoButtonLabel)
        addChild(autoButton)

        layoutAutoFireButton()
        updateAutoButtonUI()
    }

    private func layoutAutoFireButton() {
        guard autoButton != nil else { return }

        // pravá strana, približne v strede výšky
        let padding: CGFloat = 16
        let x = size.width - (autoButton.frame.width / 2) - padding
        let y = size.height * 0.55
        autoButton.position = CGPoint(x: x, y: y)
    }

    private func updateAutoButtonUI() {
        guard autoButton != nil else { return }

        if autoFireEnabled {
            autoButtonLabel.text = "AUTO: ON"
            autoButton.fillColor = .systemGreen.withAlphaComponent(0.45)
            autoButtonLabel.fontColor = .white
        } else {
            autoButtonLabel.text = "AUTO: OFF"
            autoButton.fillColor = .black.withAlphaComponent(0.35)
            autoButtonLabel.fontColor = .white
        }
    }

    // MARK: - Update Loop

    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }

        if gameStartTime == 0 {
            gameStartTime = currentTime
        }

        let elapsed = currentTime - gameStartTime

        //  Každých 20 sekúnd zvýš obtiažnosť
        let newLevel = Int(elapsed / 20.0)

        if newLevel > difficultyLevel {
            difficultyLevel = newLevel

            
            spawnInterval = max(0.3, 1.2 - Double(difficultyLevel) * 0.15)
        }

        let dt = currentTime - lastSpawnTime
        if dt >= spawnInterval {
            lastSpawnTime = currentTime
            spawnBall()
        }
    }

    // MARK: - Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        let location = t.location(in: self)

        if isGameOver {
            restartGame()
            return
        }

        
        let tappedNodes = nodes(at: location)
        if tappedNodes.contains(where: { $0.name == "btn_auto" }) {
            toggleAutoFire()
            return
        }

        guard let player else { return }

        if player.contains(location) {
            isDraggingPlayer = true
        } else {
            // manuálne strieľanie
            shoot()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver,
              isDraggingPlayer,
              let t = touches.first,
              let player else { return }

        let location = t.location(in: self)

        let halfW = player.frame.width / 2
        let x = min(max(location.x, halfW), size.width - halfW)
        player.position.x = x
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDraggingPlayer = false
    }

    // MARK: - Collision

    func didBegin(_ contact: SKPhysicsContact) {
        guard !isGameOver else { return }

        let a = contact.bodyA
        let b = contact.bodyB
        let (first, second) = a.categoryBitMask < b.categoryBitMask ? (a, b) : (b, a)

        if first.categoryBitMask == PhysicsCategory.ball,
           second.categoryBitMask == PhysicsCategory.bullet {
            handleBallHit(ballBody: first, bulletBody: second)
        }

        if first.categoryBitMask == PhysicsCategory.player,
           second.categoryBitMask == PhysicsCategory.ball {
            handlePlayerHit(ballBody: second)
        }
    }

    private func handleBallHit(ballBody: SKPhysicsBody, bulletBody: SKPhysicsBody) {
        guard let ballNode = ballBody.node else { return }

        ballNode.removeAllActions()
        ballNode.removeFromParent()
        bulletBody.node?.removeFromParent()

        if let ball = ballNode as? BallNode {
            let points = max(1, Int(50 - ball.radius))
            hud.addScore(points)
        }
    }

    private func handlePlayerHit(ballBody: SKPhysicsBody) {
        ballBody.node?.removeFromParent()

        livesLeft -= 1
        hud.setLives(livesLeft)

        if livesLeft <= 0 {
            endGame()
        }
    }

    // MARK: - Game Over

    private func endGame() {
        isGameOver = true

       
        stopAutoFire()
        autoFireEnabled = false
        updateAutoButtonUI()

        let over = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        over.text = "GAME OVER"
        over.fontSize = 44
        over.position = CGPoint(x: size.width / 2, y: size.height * 0.6)
        over.zPosition = 1000
        addChild(over)
        gameOverLabel = over
    }

    private func restartGame() {
        guard let view = self.view else { return }

       
        stopAutoFire()

        let newScene = GameScene()
        newScene.scaleMode = .resizeFill
        view.presentScene(newScene, transition: .fade(withDuration: 0.3))
    }
}
