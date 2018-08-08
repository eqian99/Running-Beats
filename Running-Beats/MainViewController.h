//
//  MainViewController.h
//  Running-Beats
//
//  Created by Emma Qian on 7/28/18.
//  Copyright © 2018 EmmaQian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SafariServices/SafariServices.h>

@interface MainViewController : UIViewController <SPTAudioStreamingDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
