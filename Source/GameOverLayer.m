//
//  GameOverLayer.m
//  CrazyMath
//
//  Created by Tô Ngọc Linh on 4/8/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GameOverLayer.h"
#import "PlayScene.h"

@interface GameOverLayer()
@end

@implementation GameOverLayer

- (void)tapRetryButton
{
    CCLOG(@"Button Retry Tapped");
    [[OALSimpleAudio sharedInstance] playEffect:@"sfx_wing.caf"];
    CCScene *playScene = [CCBReader loadAsScene:@"playScene"];
    [[CCDirector sharedDirector] replaceScene:playScene];
}

- (void)setScore:(NSInteger)score andHighscore:(NSInteger)highscore displayBest:(BOOL)isBestScore
{
    [_lbBest setVisible:isBestScore];
        
    [_lbHighscore setString:[NSString stringWithFormat:@"%ld", (long)highscore]];
    [_lbScore setString:[NSString stringWithFormat:@"%ld", (long)score]];
}

@end
