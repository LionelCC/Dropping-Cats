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
    // Add more sizes as needed
};

@interface GameScene : SKScene <SKPhysicsContactDelegate>

@end
