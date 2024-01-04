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
    self.physicsWorld.contactDelegate = self;
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask = 2; // Assuming category 2 for edges
    static const uint32_t PhysicsCategoryBall = 0x1 << 0;
    static const uint32_t PhysicsCategoryEdge = 0x1 << 1;

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
    
    // Inside didMoveToView: method where you create edges
    leftEdge.physicsBody.categoryBitMask = PhysicsCategoryEdge;
    rightEdge.physicsBody.categoryBitMask = PhysicsCategoryEdge;
    bottomEdge.physicsBody.categoryBitMask = PhysicsCategoryEdge;
    bottomEdge.physicsBody.collisionBitMask = PhysicsCategoryBall; // Allow collisions with balls




}


- (void)spawnBallAtSliderPositionWithSize:(BallSize)size {
    SKNode *slider = [self childNodeWithName:@"slider"];
    if (!slider) return;

    CGFloat radius = [self radiusForBallSize:size];
    SKShapeNode *ball = [SKShapeNode shapeNodeWithCircleOfRadius:radius];
    ball.fillColor = [SKColor yellowColor];
    ball.strokeColor = [SKColor blackColor];
    ball.lineWidth = 1.5;
    ball.name = [NSString stringWithFormat:@"ball_%lu", (unsigned long)size];

    // Set up the physics body for the ball
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
    ball.physicsBody.categoryBitMask |= BallSizeMergeable; // Assuming mergeability depends on size
    ball.physicsBody.collisionBitMask = PhysicsCategoryBall | PhysicsCategoryEdge;
    ball.physicsBody.contactTestBitMask = PhysicsCategoryBall | PhysicsCategoryEdge;
    ball.physicsBody.dynamic = YES;
    ball.physicsBody.affectedByGravity = YES;
    ball.physicsBody.allowsRotation = YES;
    ball.physicsBody.friction = 0.1; // Adjust as needed
    ball.physicsBody.restitution = 0.5; // Adjust as needed
    ball.physicsBody.linearDamping = 0.5; // Adjust as needed
    ball.physicsBody.angularDamping = 0.5; // Adjust as needed
    ball.physicsBody.collisionBitMask = 2; // Enable collision with container
    // Inside spawnBallAtSliderPositionWithSize: and other ball-creating methods


    // Position the ball above the slider
    ball.position = CGPointMake(slider.position.x, slider.position.y + radius + 50); // Adjust Y position as needed
    
    

    [self addChild:ball];
}

- (SKColor *)colorForBallSize:(BallSize)size {
    switch (size) {
        case BallSize1: return [SKColor yellowColor]; // Smallest ball is yellow
        case BallSize2: return [SKColor greenColor];
        case BallSize3: return [SKColor blueColor];
        case BallSize4: return [SKColor redColor];
        case BallSize5: return [SKColor purpleColor];
        // Add more cases as needed
        default: return [SKColor whiteColor]; // Default color
    }
}



- (void)spawnBallAtPosition:(CGPoint)position withSize:(BallSize)size {
    CGFloat radius = [self radiusForBallSize:size];
    SKShapeNode *ball = [SKShapeNode shapeNodeWithCircleOfRadius:radius];
    
    ball.fillColor = [self colorForBallSize:size]; // Use the method to determine color
    ball.strokeColor = [SKColor blackColor];
    ball.lineWidth = 1.5;
    ball.name = [NSString stringWithFormat:@"ball_%lu", (unsigned long)size];

    // Set up the physics body for the ball
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
    ball.physicsBody.dynamic = YES;
    ball.physicsBody.affectedByGravity = YES;
    ball.physicsBody.allowsRotation = YES;
    ball.physicsBody.friction = 0.1;
    ball.physicsBody.restitution = 0.5;
    ball.physicsBody.linearDamping = 0.5;
    ball.physicsBody.angularDamping = 0.5;
    ball.physicsBody.categoryBitMask = 1 << size;
    ball.physicsBody.contactTestBitMask = 0xFFFFFFFF;

    ball.position = position;

    [self addChild:ball];
}


- (void)didBeginContact:(SKPhysicsContact *)contact {
    SKNode *nodeA = contact.bodyA.node;
    SKNode *nodeB = contact.bodyB.node;

    // Enhanced Debug: Log the nodes involved in the collision and their category bit masks
    NSLog(@"Collision detected between nodes: %@ and %@", nodeA.name, nodeB.name);
    NSLog(@"Node A category bit mask: %u, Node B category bit mask: %u", nodeA.physicsBody.categoryBitMask, nodeB.physicsBody.categoryBitMask);

    // Check if both nodes are balls
    BOOL isNodeABall = (nodeA.physicsBody.categoryBitMask & PhysicsCategoryBall) != 0;
    BOOL isNodeBBall = (nodeB.physicsBody.categoryBitMask & PhysicsCategoryBall) != 0;

    NSLog(@"Node A is ball: %@, Node B is ball: %@", isNodeABall ? @"YES" : @"NO", isNodeBBall ? @"YES" : @"NO");

    if (isNodeABall && isNodeBBall && (nodeA.physicsBody.categoryBitMask & BallSizeMergeable) && (nodeB.physicsBody.categoryBitMask & BallSizeMergeable)) {
        BallSize sizeA = [self sizeFromName:nodeA.name];
        BallSize sizeB = [self sizeFromName:nodeB.name];

        // Debug: Log the sizes of the balls
        NSLog(@"Sizes of colliding balls: sizeA = %lu, sizeB = %lu", (unsigned long)sizeA, (unsigned long)sizeB);

        // Check for matching sizes and colors (assuming you're using a custom "color" property)
        
        if (sizeA == sizeB && sizeA < BallSize5) {
            CGPoint newPosition = CGPointMake((nodeA.position.x + nodeB.position.x) / 2,
                                              (nodeA.position.y + nodeB.position.y) / 2);

            // Debug: Log the position where the new ball will be spawned
            NSLog(@"Merging balls. New ball will be spawned at position: %@", NSStringFromCGPoint(newPosition));

            [nodeA removeFromParent];
            [nodeB removeFromParent];
            [self spawnBallAtPosition:newPosition withSize:sizeA + 1];

            // Debug: Log the size of the new ball
            NSLog(@"New ball spawned with size: %lu", (unsigned long)sizeA + 1);
        } else {
            // Debug: Log when balls do not merge
            NSLog(@"Balls did not merge. Either sizes are different, colors don't match, or maximum size reached.");
        }
    } else {
        // Debug: Log if the collision is not between two balls
        NSLog(@"Collision not between two balls. Nodes involved: %@ and %@", nodeA.name, nodeB.name);
    }
}






- (CGFloat)radiusForBallSize:(BallSize)size {
    switch (size) {
        case BallSize1: return 15.0;
        case BallSize2: return 25.0;
        case BallSize3: return 40.0;
        case BallSize4: return 55.0;
        case BallSize5: return 70.0;
            
        case BallSizeMergeable: return 0.0; // Or any appropriate value for mergeable balls

        // Add more sizes as needed
    }
}
- (BallSize)sizeFromName:(NSString *)name {
    NSUInteger sizeIndex = [[[name componentsSeparatedByString:@"_"] lastObject] integerValue];
    switch (sizeIndex) {
        case 1: return BallSize1;
        case 2: return BallSize2;
        case 3: return BallSize3;
        case 4: return BallSize4;
        case 5: return BallSize5;
        default: return BallSize1; // Default case
    }
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
        [self spawnBallAtSliderPositionWithSize:BallSize1]; // Spawn ball when touch is released
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {[self touchUpAtPoint:[t locationInNode:self]];}
}


-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
}

@end
