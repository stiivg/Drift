//
//  MainLayer.mm
//  TinyDrift
//
//  Created by Steven Gallagher on 1/20/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//



#import "MainLayer.h"
#import "GameManager.h"
#import "MainScene.h"

@implementation MainLayer

CCMenuItem *playMenuItem;
CCMenuItem *statsMenuItem;
CCMenuItem *optionsMenuItem;

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    //Terminate editing
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField*)textField {
    if (textField==name) {
        [name endEditing:YES];
        [[GameManager sharedGameManager] setUserName:textField.text];
    }
}

- (void)specifyStartLevel
{
    [name setText:[nameMenuItem label].string ];
    [name becomeFirstResponder];    
}


-(void)initName {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    // Create Name button        
    NSString *userName = [[GameManager sharedGameManager] userName];
    CCLabelBMFont *nameLabel = [CCLabelTTF labelWithString:userName fontName:@"Quasart" fontSize:32];
    nameMenuItem = [CCMenuItemLabel itemWithLabel:nameLabel target:self selector:@selector(nameAction:)];
    nameMenuItem.position = ccp(winSize.width/2, winSize.height - 60);
    CCMenu *nameMenu = [CCMenu menuWithItems:nameMenuItem, nil];
    nameMenu.position = CGPointZero;
    [self addChild:nameMenu];
    
    //Create offscreen edit field to edit the name label
    name = [[ UITextField alloc ] initWithFrame: CGRectZero ];
    [[[CCDirector sharedDirector] openGLView] addSubview:name];
    [name setDelegate:self];
    [name addTarget:self action:@selector(editNameAction:) forControlEvents:UIControlEventAllEditingEvents];
    //    [name release];   // don't forget to release memory
    

}

- (void)nameAction:(id)sender {
    [self specifyStartLevel];  
    
}

//Limit the name entered to MAX_LENGTH
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    return newLength <= MAX_LENGTH;
}

- (void)editNameAction:(id)sender {
    [nameMenuItem setString: name.text];
}


- (id)initWithMain:(CCScene *)mainScene {
    if ((self = [super init])) {
        _mainScene = mainScene;
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        // Create play button
        playMenuItem = [CCMenuItemImage 
                         itemFromNormalImage:@"play.png" selectedImage:@"play_selected.png" 
                         target:self selector:@selector(playAction:)];
        playMenuItem.position = ccp(winSize.width / 2, winSize.height / 3);
        CCMenu *playMenu = [CCMenu menuWithItems:playMenuItem, nil];
        playMenu.position = CGPointZero;
        [self addChild:playMenu];
        
        // Create stats button
        statsMenuItem = [CCMenuItemImage 
                        itemFromNormalImage:@"stats.png" selectedImage:@"stats_selected.png" 
                        target:self selector:@selector(statsAction:)];
        statsMenuItem.position = ccp(winSize.width / 2, winSize.height / 2);
        CCMenu *statsMenu = [CCMenu menuWithItems:statsMenuItem, nil];
        statsMenu.position = CGPointZero;
        [self addChild:statsMenu];
        
        // Create options button
        optionsMenuItem = [CCMenuItemImage 
                          itemFromNormalImage:@"options.png" selectedImage:@"options_selected.png" 
                          target:self selector:@selector(optionsAction:)];
        optionsMenuItem.position = ccp(winSize.width / 2, winSize.height * 2 / 3);
        CCMenu *optionsMenu = [CCMenu menuWithItems:optionsMenuItem, nil];
        optionsMenu.position = CGPointZero;
        [self addChild:optionsMenu];
        
        [self initName];
        
    }
    return self;
}

- (void)playAction:(id)sender {
    
    [[GameManager sharedGameManager] runSceneWithID:kGameScene];
    
}

- (void)statsAction:(id)sender {
}

- (void)optionsAction:(id)sender {
    [(MainScene *)_mainScene showOptions];

}


@end
