//
//  AppDelegate.m
//  Running-Beats
//
//  Created by Emma Qian on 7/27/18.
//  Copyright © 2018 EmmaQian. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"

@interface AppDelegate ()
@property (nonatomic, strong) SPTAuth *auth;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) UIViewController *authViewController;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *refreshToken;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.auth = [SPTAuth defaultInstance];
    self.player = [SPTAudioStreamingController sharedInstance];
    // The client ID you got from the developer site
    self.auth.clientID = @"ed387d52c22e4cdcb26f847612f55616";
    // The redirect URL as you entered it at the developer site
    self.auth.redirectURL = [NSURL URLWithString:@"spotify-ios://callback"];
    // Setting the `sessionUserDefaultsKey` enables SPTAuth to automatically store the session object for future use.
    self.auth.sessionUserDefaultsKey = @"current session";
    // Set the scopes you need the user to authorize. `SPTAuthStreamingScope` is required for playing audio.
    self.auth.requestedScopes = @[SPTAuthStreamingScope, SPTAuthUserReadPrivateScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistReadPrivateScope, SPTAuthUserReadEmailScope, SPTAuthUserLibraryReadScope];
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
    
    return YES;
}

- (void)startAuthenticationFlow
{
    // Check if we could use the access token we already have
    /*if ([self.auth.session isValid]) {
        // Use it to log in
        [self.player loginWithAccessToken:self.auth.session.accessToken];
    } else {
        // Get the URL to the Spotify authorization portal
        NSURL *authURL = [self.auth spotifyWebAuthenticationURL];
        // Present in a SafariViewController
        self.authViewController = [[SFSafariViewController alloc] initWithURL:authURL];
        [self.window.rootViewController presentViewController:self.authViewController animated:YES completion:nil];
    //}
    
    self.accessToken = self.auth.session.accessToken;
    self.refreshToken = self.auth.session.encryptedRefreshToken;
    
    NSLog(@"%@", self.auth.session.encryptedRefreshToken);
    NSLog(@"%@", self.auth.session.expirationDate);
    */
    [self authentication:^{   //After method1 completion, method2 will be called
        [self setAuthentication];
    }];
}

-(void)authentication:(void (^ __nullable)(void))completion {
    NSLog(@"method1 started");
    NSURL *authURL = [self.auth spotifyWebAuthenticationURL];
    // Present in a SafariViewController
    self.authViewController = [[SFSafariViewController alloc] initWithURL:authURL];
    [self.window.rootViewController presentViewController:self.authViewController animated:YES completion:nil];
    NSLog(@"method1 ended");
    completion();
}

-(void)setAuthentication{
    NSLog(@"method2 called");
    /*self.accessToken = self.auth.session.accessToken;
    self.refreshToken = self.auth.session.encryptedRefreshToken;
    
    NSLog(@"%@", self.auth.session.encryptedRefreshToken);
    NSLog(@"Time::::: %@", self.auth.session.expirationDate);*/
}

// Handle auth callback
- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options
{
    
    // If the incoming url is what we expect we handle it
    if ([self.auth canHandleURL:url]) {
        // Close the authentication window
        [self.authViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        self.authViewController = nil;
        // Parse the incoming url to a session object
        [self.auth handleAuthCallbackWithTriggeredAuthURL:url callback:^(NSError *error, SPTSession *session) {
            if (session) {
                // login to the player
                [self.player loginWithAccessToken:self.auth.session.accessToken];
                
                self.accessToken = self.auth.session.accessToken;
                self.refreshToken = self.auth.session.encryptedRefreshToken;
                
                NSLog(@"Access token: %@", self.accessToken);
                
                NSLog(@"%@", self.auth.session.encryptedRefreshToken);
                NSLog(@"Time::::: %@", self.auth.session.expirationDate);
                NSURL *URL = [NSURL URLWithString:@"https://fc623982.ngrok.io/init"];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
                
                NSString *requestInput = [NSString stringWithFormat: @"access_token=%@", self.accessToken];

                NSData *requestData = [requestInput dataUsingEncoding:NSUTF8StringEncoding];
                [request setHTTPBody: requestData];
                
                NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
                NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
                
                [request setHTTPMethod:@"POST"];
                
                NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    
                    // NSDictionary *dataJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                    NSLog(@"Initial request");
                    NSLog(@"%@", data);
                    
                }];
                [dataTask resume];
            }
        }];
        return YES;
    }
    return NO;
}

- (void)audioStreamingDidLogin:(SPTAudioStreamingController *)audioStreaming {
    NSLog(@"Went into audiostreaming");
    NSTimer *t = [NSTimer scheduledTimerWithTimeInterval: 15
                                                  target: self
                                                selector:@selector(onTick:)
                                                userInfo: nil repeats:YES];
}

-(void)onTick:(NSTimer *)timer {
    NSURL *URL = [NSURL URLWithString:@"https://fc623982.ngrok.io/random-track"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
        }
        
        else {
            NSLog(@"Finished request");
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
            NSString *track = json[@"id"];
            NSLog(@"%@", track);
            NSString *music = [NSString stringWithFormat:@"spotify:track:%@",track];
            NSString *title = json[@"name"];
            NSString *artist = json[@"artist"];
            dispatch_async(dispatch_get_main_queue(), ^{
                ((LoginViewController *)self.window.rootViewController).titleLabel.text = title;
                ((LoginViewController *)self.window.rootViewController).artistLabel.text = artist;
            });
            
            NSLog(@"%@", json);
             [self.player playSpotifyURI:music startingWithIndex:0 startingWithPosition:0 callback:^(NSError *error) {
             if (error != nil) {
                 NSLog(@"*** failed to play: %@", error);
                 return;
             }
             }];
            
        }
    }];
    [dataTask resume];
}


@end
