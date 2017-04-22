//
//  HTY360PlayerVC.h
//  HTY360Player
//
//  Created by  on 11/8/15.
//  Copyright © 2015 Hanton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface HTY360PlayerVC : UIViewController

@property (strong, nonatomic) NSURL *videoURL;
@property NSString *currentMood;
@property NSString *currentType;
@property NSMutableDictionary *currentVideoInfo;

//播放模式：探索模式 vs 暫時瀏覽模式
@property BOOL onlyForBrowse;

@property (weak, nonatomic) IBOutlet UIImageView *maskFrameView;
@property (weak, nonatomic) IBOutlet UIImageView *updateView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSURL*)url;
- (CVPixelBufferRef)retrievePixelBufferToDraw;
- (void)toggleControls;
-(void) play;

- (IBAction)tappedExitBtn:(id)sender;
- (IBAction)tappedModeBtn:(id)sender;
- (IBAction)tappedCameraBtn:(id)sender;
- (IBAction)tappedPauseBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *robotFrame;
@property (weak, nonatomic) IBOutlet UILabel *HintLabel;
@property (weak, nonatomic) IBOutlet UILabel *YesLabel;
@property (weak, nonatomic) IBOutlet UILabel *SlashLabel;
@property (weak, nonatomic) IBOutlet UILabel *NoLabel;


@end
