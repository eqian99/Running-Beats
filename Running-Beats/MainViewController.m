//
//  MainViewController.m
//  Running-Beats
//
//  Created by Emma Qian on 7/28/18.
//  Copyright © 2018 EmmaQian. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()
@property (nonatomic, strong) SPTAuth *auth;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) UIViewController *authViewController;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.auth = [SPTAuth defaultInstance];
    self.player = [SPTAudioStreamingController sharedInstance];
    // The client ID you got from the developer site
    self.auth.clientID = @"ed387d52c22e4cdcb26f847612f55616";
    // The redirect URL as you entered it at the developer site
    self.auth.redirectURL = [NSURL URLWithString:@"spotify-ios://callback"];
    // Setting the `sessionUserDefaultsKey` enables SPTAuth to automatically store the session object for future use.
    self.auth.sessionUserDefaultsKey = @"current session";
    // Set the scopes you need the user to authorize. `SPTAuthStreamingScope` is required for playing audio.
    self.auth.requestedScopes = @[SPTAuthStreamingScope];
    
    // Become the streaming controller delegate
    self.player.delegate = self;
    
    // Start up the streaming controller.
    NSError *audioStreamingInitError;
    if (![self.player startWithClientId:self.auth.clientID error:&audioStreamingInitError]) {
        NSLog(@"There was a problem starting the Spotify SDK: %@", audioStreamingInitError.description);
    }
    
    // Start authenticating when the app is finished launching
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startAuthenticationFlow];
    });
}

- (void)startAuthenticationFlow
{
    // Check if we could use the access token we already have
    if ([self.auth.session isValid]) {
        // Use it to log in
        [self.player loginWithAccessToken:self.auth.session.accessToken];
    } else {
        // Get the URL to the Spotify authorization portal
        NSURL *authURL = [self.auth spotifyWebAuthenticationURL];
        // Present in a SafariViewController
        self.authViewController = [[SFSafariViewController alloc] initWithURL:authURL];
        [self.window.rootViewController presentViewController:self.authViewController animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
