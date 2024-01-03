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
    
    // Create a boundary container
        CGRect containerRect = CGRectMake(0, -100, 450, 950);  // Origin at (0, 0)
        SKShapeNode *container = [SKShapeNode shapeNodeWithRect:containerRect cornerRadius:10];
        container.strokeColor = [SKColor whiteColor];
        container.lineWidth = 4.0;
        container.position = CGPointMake(CGRectGetMidX(self.frame) - containerRect.size.width / 2, CGRectGetMidY(self.frame) - containerRect.size.height / 2);
    
    
        // Add physics body to the container
        container.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:containerRect.size];
        container.physicsBody.dynamic = NO;
    
    
        [self addChild:container];
    
    // Create a simple slider
        SKShapeNode *slider = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(100, 20)];
        slider.fillColor = [SKColor grayColor];
        slider.name = @"slider"; // Important for identifying the node in touch events
    // Adjust the Y position so the slider is above the container
        slider.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 450);
        [self addChild:slider];
    
        // Create a single container node with physics body
        SKNode *containerNode = [SKNode node];
        containerNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));

        SKPhysicsBody *containerBody = [SKPhysicsBody bodyWithRectangleOfSize:containerRect.size];
        containerBody.dynamic = NO;
        containerNode.physicsBody = containerBody;

        // Set category and collision bit mask for desired interactions
        containerBody.categoryBitMask = 0x1; // Assign relevant category
        containerBody.collisionBitMask = 0x0; // Allow collisions with specific categories

        [self addChild:containerNode];

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

    SKShapeNode *ball = [SKShapeNode shapeNodeWithCircleOfRadius:15];
    ball.fillColor = [SKColor yellowColor];
    ball.strokeColor = [SKColor blackColor];
    ball.lineWidth = 1.5;
    ball.position = CGPointMake(slider.position.x, slider.position.y - 50); // Adjust as needed

    // Add physics body for collision
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:15];
    ball.physicsBody.dynamic = YES;
    ball.physicsBody.affectedByGravity = YES;
    ball.physicsBody.allowsRotation = YES;

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

        [self spawnBallAtSliderPosition]; // Spawn a ball at the new slider position
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {
        CGPoint pos = [t locationInNode:self];
        [self touchMovedToPoint:pos];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {[self touchUpAtPoint:[t locationInNode:self]];}
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {[self touchUpAtPoint:[t locationInNode:self]];}
}


-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
}

@end
