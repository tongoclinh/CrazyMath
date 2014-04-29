//
//  PlayScene.m
//  CrazyMath
//
//  Created by Tô Ngọc Linh on 4/7/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "PlayScene.h"
#import "GameOverLayer.h"
#import <AudioToolbox/AudioToolbox.h>

@interface PlayScene() {
    CCLabelTTF *_lbEquation;
    CCLabelTTF *_lbNextEquation;
    CCLabelTTF *_lbResult;
    CCLabelTTF *_lbNextResult;
    CCLabelTTF *_lbScore;
    NSInteger _score;
    NSInteger _highscore;
    
    CCButton *_btRight;
    CCButton *_btWrong;
    
    CCNodeColor *_background;
    
    CCNodeColor *_barProgress;
    CCSprite *_backgroundImage;
    
    GameOverLayer *_gameOverLayer;
    
    BOOL _didStart;
    BOOL _isEquationCorrect;
    BOOL _isNextEquationCorrect;
    BOOL _isGameOver;
    
    NSArray *_backgroundColor;
}

@end

@implementation PlayScene

- (void)didLoadFromCCB
{
    CCLOG(@"play scene loaded");
//    NSNumber *_objhighscore = [[NSUserDefaults standardUserDefaults] objectForKey:@"score"];
//    if (!_objhighscore)
//        _highscore = 0;
//    else
//        _highscore = [_objhighscore integerValue];
    
    _backgroundColor = [NSArray arrayWithObjects:
                        [CCColor colorWithCcColor3b:ccc3(54, 166, 222)],
                        [CCColor colorWithCcColor3b:ccc3(242, 76, 39)],
                        [CCColor colorWithCcColor3b:ccc3(64, 64, 64)],
                        [CCColor colorWithCcColor3b:ccc3(242, 239, 220)],
                        [CCColor colorWithCcColor3b:ccc3(46, 204, 113)],
                        
                        nil];
    
    _highscore = [[NSUserDefaults standardUserDefaults] integerForKey:@"score"];
    CCLOG(@"Highscore %ld", (long)_highscore);
    self.userInteractionEnabled = YES;
    _gameOverLayer = (GameOverLayer *)[CCBReader load:@"gameOver"];
    [self generateNextEquation];
    _didStart = NO;
    _isGameOver = NO;
}

- (void)update:(CCTime)delta
{
    if (!_didStart)
        return;
    if (_isGameOver)
        return;
    CCLOG(@"Update game");
    if ([_barProgress scaleX] == 0) {
        [self gameOver];
    }
}

#pragma mark - Game Logic

- (NSInteger)modifierWrongResult:(NSInteger)result
{
    NSInteger modifier = arc4random_uniform(3) + 1;
    modifier = MIN(modifier, result);
    if (modifier == 0) {
        _isEquationCorrect = YES;
    }
    BOOL positive = arc4random_uniform(2) == 1;
    if (positive)
        result += modifier;
    else
        result -= modifier;
    return result;
}

- (void)generateNextEquation
{
    //result
    _isEquationCorrect = (arc4random_uniform(2) == 1);
    
    if (!_didStart) {
        NSInteger firstNumber, secondNumber, result;
        if (_score <= 20 || _score > 20) {
            firstNumber = arc4random_uniform(10);
            secondNumber = arc4random_uniform(10);
            
            if (_isEquationCorrect) {
                result = firstNumber + secondNumber;
            } else {
                result = firstNumber + secondNumber;
                result = [self modifierWrongResult:result];
            }
            
            [_lbEquation setString:[NSString stringWithFormat:@"%ld + %ld", (long)firstNumber, (long)secondNumber]];
            [_lbResult setString:[NSString stringWithFormat:@"= %ld", (long)result]];
        }
        return;
    }
    
    //equation
    NSInteger firstNumber, secondNumber, result;
    if (_score <= 20 || _score > 20) {
        firstNumber = arc4random_uniform(10);
        secondNumber = arc4random_uniform(10);
        
        if (_isEquationCorrect) {
            result = firstNumber + secondNumber;
        } else {
            result = firstNumber + secondNumber;
            result = [self modifierWrongResult:result];
        }
        
        [_lbNextEquation setString:[NSString stringWithFormat:@"%ld + %ld", (long)firstNumber, (long)secondNumber]];
        [_lbNextResult setString:[NSString stringWithFormat:@"= %ld", (long)result]];
    }
}

- (void)updateScore
{
    _score ++;
    [_lbScore setString:[NSString stringWithFormat:@"%ld", (long)_score]];
}

#pragma mark - Game UI

- (CCColor *)getRandomBackgroundColor
{
    int index = abs(arc4random_uniform([_backgroundColor count]));
    return (CCColor *)[_backgroundColor objectAtIndex:index];
}

- (void)transitToNextEquation
{
    [self updateScore];
    [self generateNextEquation];
        
    [[OALSimpleAudio sharedInstance] playEffect:@"sfx_swooshing.caf"];

    
    CGSize winSize = [[CCDirector sharedDirector] viewSize];
    
    //block button
    
    CCActionCallBlock *blockButton = [CCActionCallBlock actionWithBlock:^{
        [_btRight setState:CCControlStateDisabled];
        [_btRight setUserInteractionEnabled:NO];
        [_btWrong setState:CCControlStateDisabled];
        [_btWrong setUserInteractionEnabled:NO];
    }];
    
    CCActionCallBlock *unblockButton = [CCActionCallBlock actionWithBlock:^{
        [_btRight setState:CCControlStateNormal];
        [_btRight setUserInteractionEnabled:YES];
        [_btWrong setState:CCControlStateNormal];
        [_btWrong setUserInteractionEnabled:YES];
    }];
    
    //update equation
    CGPoint currentPosition = _lbEquation.position;
    CGPoint nextPosition = _lbNextEquation.position;
    CCActionMoveTo *moveOut = [CCActionMoveTo actionWithDuration:0.2 position:ccp(-_lbEquation.boundingBox.size.width/winSize.width, currentPosition.y)];
    CCActionMoveTo *moveIn  = [CCActionMoveTo actionWithDuration:0.2 position:currentPosition];
    
    CCActionCallBlock *swapLabel = [CCActionCallBlock actionWithBlock:^{
        _lbEquation.position = nextPosition;
        CCLabelTTF *temp = _lbEquation;
        _lbEquation = _lbNextEquation;
        _lbNextEquation = temp;
    }];
    
    [_lbEquation runAction:[CCActionSequence actions:blockButton, [CCActionEaseSineOut actionWithAction:moveOut], nil]];
    [_lbNextEquation runAction:[CCActionSequence actions:[CCActionEaseSineOut actionWithAction:moveIn], swapLabel, nil]];
    
    
    [_barProgress setScale:1];
    CCActionScaleTo *countdown = [CCActionScaleTo actionWithDuration:1.2 scaleX:0 scaleY:1];
    
    //update result
    currentPosition = _lbResult.position;
    nextPosition = _lbNextResult.position;
    moveOut = [CCActionMoveTo actionWithDuration:0.2 position:ccp(1 + _lbResult.boundingBox.size.width / winSize.width, currentPosition.y)];
    moveIn  = [CCActionMoveTo actionWithDuration:0.2 position:currentPosition];
    
    swapLabel = [CCActionCallBlock actionWithBlock:^{
        _lbResult.position = nextPosition;
        CCLabelTTF *temp = _lbResult;
        _lbResult = _lbNextResult;
        _lbNextResult = temp;
    }];
    
    [_lbResult runAction:[CCActionSequence actions:[CCActionEaseSineOut actionWithAction:moveOut], nil]];
    [_lbNextResult runAction:[CCActionSequence actions:[CCActionEaseSineOut actionWithAction:moveIn], swapLabel, unblockButton, nil]];
    
    //update background
    CCColor *nextColor = [self getRandomBackgroundColor];
    CCActionTintTo *changeTintColor = [CCActionTintTo actionWithDuration:0.2 color:nextColor];
    
    [_background runAction:[CCActionSequence actions:changeTintColor, nil]];

    
    //update progress bar
    
    [_barProgress runAction:countdown];
}

- (void)gameOver
{
    if (_isGameOver)
        return;
    _isGameOver = YES;
    CCLOG(@"Game Over");
    
    [[OALSimpleAudio sharedInstance] playEffect:@"sfx_hit.caf"];
    
    //update highscore
    BOOL isBestScore = (_score > _highscore);
    _highscore = MAX(_highscore, _score);
    [[NSUserDefaults standardUserDefaults] setInteger:_highscore forKey:@"score"];
    
    //animate background
    CCActionRotateBy *rotate = [CCActionRotateBy actionWithDuration:0.2 angle:-10];
    CCActionRotateBy *rotateBack = [CCActionRotateBy actionWithDuration:0.2 angle:10];
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    [_backgroundImage runAction:[CCActionSequence actions:[CCActionEaseBounceIn actionWithAction:rotate], [CCActionEaseBounceOut actionWithAction:rotateBack], nil]];
    
    
    //[_gameOverLayer->_lbScore setString:[NSString stringWithFormat:@"%d", _score]];
    //[_gameOverLayer->_lbHighscore setString:[NSString stringWithFormat:@"%d", _highscore]];
    [_gameOverLayer setScore:_score andHighscore:_highscore displayBest:isBestScore];
    [_barProgress stopAllActions];
    [self addChild:_gameOverLayer];
    [self setUserInteractionEnabled:NO];
    [_lbEquation setVisible:NO];
    [_lbNextEquation setVisible:NO];
    [_lbNextResult setVisible:NO];
    [_lbResult setVisible:NO];
    [_btWrong setVisible:NO];
    [_btRight setVisible:NO];
    [_btRight setState:CCControlStateDisabled];
    [_btWrong setState:CCControlStateDisabled];
}

#pragma mark - Button Action

- (void)tapRightButton
{
    CCLOG(@"Right Button Tapped");
    if (!_didStart)
        _didStart = YES;
    
    //[self transitToNextEquation];
    if (_isEquationCorrect) {
        [self transitToNextEquation];
    } else {
        [self gameOver];
    }
}

- (void)tapWrongButton
{
    CCLOG(@"Wrong Button Tapped");
    
    if (!_didStart)
        _didStart = YES;
    
    if (!_isEquationCorrect) {
        [self transitToNextEquation];
    } else {
        [self gameOver];
    }
}

@end
