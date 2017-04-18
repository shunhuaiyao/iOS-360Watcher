//
//  HomepageVC.h
//  360Project
//
//  Created by Rachel Yeh on 2016/12/12.
//  Copyright © 2016年 Hanton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioServices.h>


@interface HomepageVC : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *alreaySentView;

@property (weak, nonatomic) IBOutlet UIButton *earthBtn;
@property (weak, nonatomic) IBOutlet UIImageView *earthView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
@property (weak, nonatomic) IBOutlet UIImageView *ExploreEffect;
@property (weak, nonatomic) IBOutlet UIImageView *MemoryEffect;
@property (weak, nonatomic) IBOutlet UIImageView *MessageEffect;
@property (weak, nonatomic) IBOutlet UILabel *HintLabel;

//各桌面物件按鈕被點選
- (IBAction)tappedMusicbox:(id)sender;
- (IBAction)tappedTelescope:(id)sender;
- (IBAction)tappedIntercom:(id)sender;
- (IBAction)tappedEarth:(id)sender;
- (IBAction)tappedExploreEffect:(id)sender;
- (IBAction)tappedMessageEffect:(id)sender;
- (IBAction)tappedMemoryEffect:(id)sender;
- (IBAction)ExitExploreEffect:(id)sender;
- (IBAction)ExitMessageEffect:(id)sender;
- (IBAction)ExitMemoryEffect:(id)sender;

@end
