//
//  GameScene.m
//  Dropping Cats
//
//  Created by Lionel Chen on 1/3/24.
//

#import "GameScene.h"

@implementation GameScene {
    
    SKShapeNode *_spinnyNode;
    SKLabelNode *_label;
    
}

- (void)didMoveToView:(SKView *)view {
    // Setup your scene here

    // Get label node from scene and store it for use later
    CGFloat w = (self.size.width + self.size.height) * 0.05;
    
    // Create shape node to use during mouse interaction
    _spinnyNode = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(w, w) cornerRadius:w * 0.3];
    _spinnyNode.lineWidth = 2.5;
    
    [_spinnyNode runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:M_PI duration:1]]];
    [_spinnyNode runAction:[SKAction sequence:@[
                                                [SKAction waitForDuration:0.5],
                                                [SKAction fadeOutWithDuration:0.5],
                                                [SKAction removeFromParent],
                                                ]]];
    
    
    // Create a simple slider
    SKShapeNode *slider = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(100, 20)];
    slider.fillColor = [SKColor grayColor];
    slider.name = @"slider"; // Important for identifying the node in touch events
    slider.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 450);
    [self addChild:slider];
    
    /// Calculate container dimensions and positions
    CGFloat edgeThickness = 4.0; // Adjust the thickness of the edge as needed
    CGFloat containerWidth = 450.0;
    CGFloat containerHeight = 950.0;
    CGPoint containerBottomLeft = CGPointMake(CGRectGetMidX(self.frame) - containerWidth / 2, CGRectGetMidY(self.frame) - containerHeight / 2);
    CGPoint containerBottomRight = CGPointMake(containerBottomLeft.x + containerWidth, containerBottomLeft.y);
    CGPoint containerTopLeft = CGPointMake(containerBottomLeft.x, containerBottomLeft.y + containerHeight);

    // Left Edge
    SKShapeNode *leftEdge = [SKShapeNode shapeNodeWithRect:CGRectMake(0, 0, edgeThickness, containerHeight)];
    leftEdge.fillColor = [SKColor grayColor];
    leftEdge.position = containerBottomLeft;
    leftEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(0, containerHeight)];
    leftEdge.physicsBody.dynamic = NO;
    [self addChild:leftEdge];

    // Right Edge
    SKShapeNode *rightEdge = [SKShapeNode shapeNodeWithRect:CGRectMake(0, 0, edgeThickness, containerHeight)];
    rightEdge.fillColor = [SKColor grayColor];
    rightEdge.position = CGPointMake(containerBottomRight.x - edgeThickness, containerBottomRight.y);
    rightEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(0, containerHeight)];
    rightEdge.physicsBody.dynamic = NO;
    [self addChild:rightEdge];

    // Bottom Edge
    SKShapeNode *bottomEdge = [SKShapeNode shapeNodeWithRect:CGRectMake(0, 0, containerWidth, edgeThickness)];
    bottomEdge.fillColor = [SKColor grayColor];
    bottomEdge.position = containerBottomLeft;
    bottomEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(containerWidth, 0)];
    bottomEdge.physicsBody.dynamic = NO;
    [self addChild:bottomEdge];


}



- (void)spawnBall {
    SKShapeNode *ball = [SKShapeNode shapeNodeWithCircleOfRadius:15];
    ball.fillColor = [SKColor yellowColor];
    ball.strokeColor = [SKColor blackColor];
    ball.lineWidth = 1.5;
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.frame.size.width / 2];
    ball.physicsBody.dynamic = YES;
    ball.physicsBody.affectedByGravity = YES;
    ball.physicsBody.allowsRotation = YES;
    ball.physicsBody.friction = 0.1; // Adjust as needed
    ball.physicsBody.restitution = 0.5; // Adjust as needed
    ball.physicsBody.linearDamping = 0.5; // Adjust as needed
    ball.physicsBody.angularDamping = 0.5; // Adjust as needed
    ball.physicsBody.collisionBitMask = 0x1;



    // Random position within the container bounds
    int minX = CGRectGetMinX(self.frame) + 150 + ball.frame.size.width / 2;
    int maxX = CGRectGetMaxX(self.frame) - 150 - ball.frame.size.width / 2;
    int randomX = arc4random_uniform(maxX - minX) + minX;
    ball.position = CGPointMake(randomX, CGRectGetMaxY(self.frame) - 50);

    [self addChild:ball];
}

- (void)spawnBallAtSliderPosition {
    SKNode *slider = [self childNodeWithName:@"slider"];
    if (!slider) return;

    // Create the ball
    SKShapeNode *ball = [SKShapeNode shapeNodeWithCircleOfRadius:15];
    ball.fillColor = [SKColor yellowColor];
    ball.strokeColor = [SKColor blackColor];
    ball.lineWidth = 1.5;

    // Set up the physics body for the ball
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.frame.size.width / 2];
    ball.physicsBody.dynamic = YES;
    ball.physicsBody.affectedByGravity = YES;
    ball.physicsBody.allowsRotation = YES;
    ball.physicsBody.collisionBitMask = 0x1; // Enable collision with container

    // Place the ball right above the slider
    ball.position = CGPointMake(slider.position.x, CGRectGetMaxY(self.frame) - 50);

    [self addChild:ball];
}



- (void)touchDownAtPoint:(CGPoint)pos {
    SKShapeNode *n = [_spinnyNode copy];
    n.position = pos;
    n.strokeColor = [SKColor greenColor];
    [self addChild:n];
}


- (void)touchMovedToPoint:(CGPoint)pos {
    SKNode *slider = [self childNodeWithName:@"slider"];
    if (slider) {
        slider.position = CGPointMake(pos.x, slider.position.y);
    }
}

- (void)touchUpAtPoint:(CGPoint)pos {
    SKShapeNode *n = [_spinnyNode copy];
    n.position = pos;
    n.strokeColor = [SKColor redColor];
    [self addChild:n];
    [self spawnBallAtSliderPosition]; // Spawn ball when touch is released
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {
        CGPoint pos = [t locationInNode:self];

        SKNode *slider = [self childNodeWithName:@"slider"];
        if (slider) {
            slider.position = CGPointMake(pos.x, slider.position.y);
        }

    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {
        CGPoint pos = [t locationInNode:self];
        [self touchMovedToPoint:pos];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {
        [self touchUpAtPoint:[t locationInNode:self]]; // This will spawn the ball
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {[self touchUpAtPoint:[t locationInNode:self]];}
}


-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
}

@end
