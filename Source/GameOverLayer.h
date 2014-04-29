//
//  GameOverLayer.h
//  CrazyMath
//
//  Created by Tô Ngọc Linh on 4/8/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface GameOverLayer : CCNode {
    CCLabelTTF *_lbHighscore;
    CCLabelTTF *_lbScore;
    CCLabelTTF *_lbBest;
}

- (void)setScore:(NSInteger)score andHighscore:(NSInteger)highscore displayBest:(BOOL)isBestScore;

@end
