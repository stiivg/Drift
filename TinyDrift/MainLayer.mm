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

CCMenuItemLabel *raceMenuItem;
CCMenuItemLabel *statsMenuItem;
CCMenuItemLabel *optionsMenuItem;

//Trim all leading and trailing spaces
#define allTrim( object ) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ]


- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    //Terminate editing
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField*)textField {
    if (textField==name) {
        [name endEditing:YES];
        NSString *endString = allTrim(textField.text);

        if ([endString length]==0) {
            endString = origString;
        }
        [nameMenuItem setString:endString];
        
        [[GameManager sharedGameManager] setUserName:endString];
    }
}

- (void)specifyStartLevel
{
    origString = [nameMenuItem label].string;
    //Start with a space so first char backspace will call the edit name action
    [name setText:@" " ];
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
    [name addTarget:self action:@selector(editNameAction:) forControlEvents:UIControlEventEditingChanged];
    //    [name release];   // don't forget to release memory
    
    nameEditing = false;

}

- (void)nameAction:(id)sender {
    if (nameEditing) {
        nameEditing = false;
        [name resignFirstResponder];
    } else {
        nameEditing = true;
        [self specifyStartLevel];  
    }
    
}

//Limit the name entered to MAX_LENGTH
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    return newLength <= MAX_LENGTH;
}


//Called on every edit action like press key
- (void)editNameAction:(id)sender {
    //TrRim leading and trailing spaces
    [nameMenuItem setString: allTrim(name.text)];
}


- (id)initWithMain:(CCScene *)mainScene {
    if ((self = [super init])) {
        _mainScene = mainScene;
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        // Create play button
        CCLabelBMFont *raceLabel = [CCLabelTTF labelWithString:@"Race" fontName:@"Quasart" fontSize:40];
        raceMenuItem = [CCMenuItemLabel itemWithLabel:raceLabel target:self selector:@selector(raceAction:)];
        raceMenuItem.position = ccp(winSize.width/2, 80);
        CCMenu *raceMenu = [CCMenu menuWithItems:raceMenuItem, nil];
        raceMenu.position = CGPointZero;
        [self addChild:raceMenu];
        
        // Create stats button
        CCLabelBMFont *statsLabel = [CCLabelTTF labelWithString:@"Scores" fontName:@"Quasart" fontSize:20];
        statsLabel.color = ccBLACK;
        statsMenuItem = [CCMenuItemLabel itemWithLabel:statsLabel target:self selector:@selector(statsAction:)];
        statsMenuItem.position = ccp(winSize.width/2+80, winSize.height / 3);
        CCMenu *statsMenu = [CCMenu menuWithItems:statsMenuItem, nil];
        statsMenu.position = CGPointZero;
        [self addChild:statsMenu];
        
        // Create options button
        CCLabelBMFont *optionsLabel = [CCLabelTTF labelWithString:@"Options" fontName:@"Quasart" fontSize:20];
        optionsLabel.color = ccBLACK;
        optionsMenuItem = [CCMenuItemLabel itemWithLabel:optionsLabel target:self selector:@selector(optionsAction:)];
        optionsMenuItem.position = ccp(winSize.width/2-80, winSize.height / 3);
        CCMenu *optionsMenu = [CCMenu menuWithItems:optionsMenuItem, nil];
        optionsMenu.position = CGPointZero;
        [self addChild:optionsMenu];
        
        [self initName];
        
    }
    return self;
}

- (void)raceAction:(id)sender {
    
    [[GameManager sharedGameManager] runSceneWithID:kGameScene];
    
}

- (void)statsAction:(id)sender {
    [(MainScene *)_mainScene showStatistics];
}

- (void)optionsAction:(id)sender {
    [(MainScene *)_mainScene showOptions];

}


@end
