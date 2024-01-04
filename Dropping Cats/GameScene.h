//
//  GameScene.h
//  Dropping Cats
//
//  Created by Lionel Chen on 1/3/24.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSUInteger, BallSize) {
    BallSize1,
    BallSize2,
    BallSize3,
    BallSize4,
    BallSize5,
    
    BallSizeMergeable = 0x40000000  // Custom flag for mergeability

    // Add more sizes as needed
};

typedef NS_ENUM(uint32_t, PhysicsCategory) {
    PhysicsCategoryBall = 1 << 0,      // 0001
    PhysicsCategoryEdge = 1 << 1,      // 0010
    // Add more categories as needed
};


@interface GameScene : SKScene <SKPhysicsContactDelegate>

@end
