//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene

- (void)play
{
    [[OALSimpleAudio sharedInstance] playEffect:@"sfx_wing.caf"];
    CCScene *playScene =[CCBReader loadAsScene:@"playScene"];
    [[CCDirector sharedDirector] replaceScene:playScene withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:0.5]];
}

@end
