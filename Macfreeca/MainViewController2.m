//
//  MainViewController2.m
//  Macfreeca
//
//  Created by Minho Lee on 13. 7. 4..
//  Copyright (c) 2013년 Minho Lee. All rights reserved.
//

#import "MainViewController2.h"
#define LOGMODE 1
static void *AVSPPlayerItemStatusContext = &AVSPPlayerItemStatusContext;
static void *AVSPPlayerRateContext = &AVSPPlayerRateContext;
static void *AVSPPlayerLayerReadyForDisplay = &AVSPPlayerLayerReadyForDisplay;
static void *AVSPPlayerLayerReadyToPlay = &AVSPPlayerLayerReadyToPlay;
static void *AVSPPlayerLayerLikelyToKeepUp = &AVSPPlayerLayerLikelyToKeepUp;
static void *AVSPTimeRanges = &AVSPTimeRanges;

@interface MainViewController2 ()

- (void)setUpPlaybackOfAsset:(AVAsset *)asset withKeys:(NSArray *)keys;
- (void)stopLoadingAnimationAndHandleError:(NSError *)error;

@end

@implementation MainViewController2


@synthesize player;
@synthesize playerLayer;
//@synthesize playerItem;

@synthesize m_movieView, m_lbStatus, m_webView, m_lbStatus2, m_sliderVolumn, twoFingersTouches;
@synthesize movieReader;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"AppleEnableSwipeNavigateWithScrolls"];
    
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskSwipe handler:^(NSEvent *event) {
        if ([event deltaX] == 1.0) { //LEFT SWIPE
//            NSLog(@"left");
        } else if ([event deltaX] == -1.0) { //RIGHT SWIPE
//            NSLog(@"righ");
        }
        return event;
    }];
    
    
    m_strUrl = @"http://istream.m.afreeca.com/stream/route/";
    return self;
}

- (void)awakeFromNib {
    isFull = NO;
    _playing = 0;
    [m_lbStatus setStringValue:@"Hello"];
    player = [[AVQueuePlayer alloc] init];
    NSString *test = @"http://m.afreeca.com/main.php";
    
    [m_webView setMainFrameURL:test];
    [m_webView setUIDelegate:self];
    [m_webView setFrameLoadDelegate:self];
    
    [m_movieView setWantsLayer:YES];
    
    // Create an AVPlayerLayer and add it to the player view if there is video, but hide it until it's ready for display
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    [playerLayer setFrame:[[m_movieView layer] bounds]];
    [playerLayer setAutoresizingMask:kCALayerWidthSizable | kCALayerHeightSizable];
    [playerLayer setHidden:NO];
    
    [[m_movieView layer] addSublayer:playerLayer];
    [self setPlayerLayer:playerLayer];
    [playerLayer setPlayer:player];
    
//    [self addObserver:self forKeyPath:@"playerLayer.readyForDisplay" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:AVSPPlayerLayerReadyForDisplay];
//    [self addObserver:self forKeyPath:@"playerLayer.readyToPlay" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:AVSPPlayerLayerReadyToPlay];
    
}
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    //allow for state updates, UI changes
    if (LOGMODE) {
        NSLog(@"reach end");
    }
    [player seekToTime:kCMTimeZero];
    [player play];
    if (LOGMODE) {
        NSLog(@"%@", [(AVURLAsset*)player.currentItem.asset URL]);
        NSLog(@"%@", [[player currentItem] description]);
    }
}
- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
    [m_lbStatus setStringValue:@"로딩"];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    [m_lbStatus setStringValue:@"완료"];
}

- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame
{
//    NSLog(@"javascript");
}

- (void)webView:(WebView *)sender didCommitLoadForFrame:(WebFrame *)frame
{
//    NSLog(@"java2");
}
- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
    fileUrl = [NSURL URLWithString:[m_strUrl stringByAppendingString:m_strAdd]];
    // afreeca url
//    NSLog(@"%@", fileUrl);
 
    
	// Create an asset with our URL, asychronously load its tracks, its duration, and whether it's playable or protected.
	// When that loading is complete, configure a player to play the asset.
    [self loadAVPlayerWithURL:fileUrl];
}
- (void)loadAVPlayerWithURL:(NSURL*)url {
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileUrl options:nil];
    //    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileUrl options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey]];
	NSArray *assetKeysToLoadAndTest = [NSArray arrayWithObjects:@"playable", @"tracks", nil];
    
	[asset loadValuesAsynchronouslyForKeys:assetKeysToLoadAndTest completionHandler:^(void) {
		// The asset invokes its completion handler on an arbitrary queue when loading is complete.
		// Because we want to access our AVPlayer in our ensuing set-up, we must dispatch our handler to the main queue.
		dispatch_async(dispatch_get_main_queue(), ^(void) {
            //            AVAssetTrack * videoTrack = nil;
            NSArray * tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
            //            NSLog(@"tracks : %d", (int)[tracks count]);
            if ([tracks count] >= 1)
            {
                // 트랙이 있을때 다음과 같이 사용
                //                videoTrack = [tracks objectAtIndex:0];
                //
                //                NSError * error = nil;
                //
                //                // _movieReader is a member variable
                //                movieReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
                ////                if (error)
                ////                    NSLog(error.localizedDescription);
                //
                //                NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
                //                NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
                //                NSDictionary* videoSettings =
                //                [NSDictionary dictionaryWithObject:value forKey:key];
                //
                //                [movieReader addOutput:[AVAssetReaderTrackOutput
                //                                         assetReaderTrackOutputWithTrack:videoTrack
                //                                         outputSettings:videoSettings]];
                //                [movieReader startReading];
            }
			[self setUpPlaybackOfAsset:asset withKeys:assetKeysToLoadAndTest];
		});
		
	}];
}
- (void)movieStatusStringPostedNotification:(NSNotification*)notification {
    NSLog(@"notification: %@", notification);
}
- (void)webView:(WebView *)sender mouseDidMoveOverElement:(NSDictionary *)elementInformation modifierFlags:(NSUInteger)modifierFlags
{
    //    NSLog(@"%@", [elementInformation objectForKey:@"WebElementLinkURL"]);
    NSString *i_addString = [[elementInformation objectForKey:@"WebElementLinkURL"] absoluteString];
    //    NSLog(@"%@", i_addString);
    if ([i_addString hasPrefix:@"javascript:afPlay("]) {
        i_addString = [i_addString stringByReplacingOccurrencesOfString:@"javascript:afPlay(" withString:@""];
        i_addString = [[i_addString componentsSeparatedByString:@","] objectAtIndex:0];
        i_addString = [i_addString stringByReplacingOccurrencesOfString:@")" withString:@""];
        i_addString = [i_addString stringByAppendingString:@".m3u8?fr=w"];
        //        ?fr=w 뒤에 붙는 조건문, 그냥 없어도 됨
        m_strAdd = [[NSString alloc] initWithString:i_addString];
    }
}

#pragma mark -

// 옵션 다 필요없고 스트리밍 들어오면 바로 플레이
- (void)setUpPlaybackOfAsset:(AVAsset *)asset withKeys:(NSArray *)keys
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemFailedToPlayToEndTimeErrorKey object:[player currentItem]];
    
    if (LOGMODE) {
        [self addObserver:self forKeyPath:@"player.rate" options:NSKeyValueObservingOptionNew context:AVSPPlayerRateContext];
        [self addObserver:self forKeyPath:@"player.currentItem.loadedTimeRanges" options:NSKeyValueObservingOptionNew context:AVSPTimeRanges];
        [self addObserver:self forKeyPath:@"player.currentItem.playbackLikelyToKeepUp" options:0 context:AVSPPlayerLayerLikelyToKeepUp];
        [self addObserver:self forKeyPath:@"player.currentItem.playbackBufferEmpty" options:0 context:nil];
        [self addObserver:self forKeyPath:@"player.currentItem.playbackBufferFull" options:0 context:nil];
    }
	[self addObserver:self forKeyPath:@"player.currentItem.status" options:NSKeyValueObservingOptionNew context:AVSPPlayerItemStatusContext];
	if (![asset isPlayable] || [asset hasProtectedContent])
	{
        if (LOGMODE) {
            NSLog(@"unplayable asset");
        }
		[self stopLoadingAnimationAndHandleError:nil];
		return;
	}
	
	// We can play this asset.
	// Set up an AVPlayerLayer according to whether the asset contains video.
//	if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0)
//	{
//    [self stopLoadingAnimationAndHandleError:nil];
//
//	}
//	else
//	{
//        NSLog(@"no layer");
//		// This asset has no video tracks. Show the "No Video" label.
//		[self stopLoadingAnimationAndHandleError:nil];
////		[[self noVideoLabel] setHidden:NO];
//	}
    
	// Create a new AVPlayerItem and make it our player's current item.
	AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];

    [player replaceCurrentItemWithPlayerItem:playerItem];
	
    [m_lbStatus2 setStringValue:@"play"];
    isStreaming = YES;

    [self addObserver:self forKeyPath:@"playerLayer.readyForDisplay" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:AVSPPlayerLayerReadyForDisplay];
    [self addObserver:self forKeyPath:@"playerLayer.readyToPlay" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:AVSPPlayerLayerReadyToPlay];
}

- (void)stopLoadingAnimationAndHandleError:(NSError *)error
{
    if (LOGMODE) {
        NSLog(@"error");
    }
//	if (error)
//	{
//		[self presentError:error
//			modalForWindow:[[NSApplication sharedApplication] mainWindow]
//				  delegate:nil
//		didPresentSelector:NULL
//			   contextInfo:nil];
//	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // timeranges가 버퍼링에 따라 늘어남
    if (AVSPTimeRanges == context) {
        NSArray *timeRanges = (NSArray *)[change objectForKey:NSKeyValueChangeNewKey];
        if (timeRanges && [timeRanges count]) {
            CMTimeRange timerange = [[timeRanges objectAtIndex:0] CMTimeRangeValue];
            if (LOGMODE) {
                NSLog(@" . . . %.5f -> %.5f", CMTimeGetSeconds(timerange.start), CMTimeGetSeconds(CMTimeAdd(timerange.start, timerange.duration)));
            }
            if (CMTIME_COMPARE_INLINE(timerange.duration, >, CMTimeMakeWithSeconds(10, timerange.duration.timescale))) {
                if (!_playing) {
                    [player play];
                    _playing = 1;
                }
            }
            if (CMTIME_COMPARE_INLINE(timerange.duration, >, CMTimeMakeWithSeconds(15, timerange.duration.timescale))) {
                if (_playing == 1) {
                    [player pause];
                    _playing = 2;
                }
            }
            if (CMTIME_COMPARE_INLINE(timerange.duration, >=, CMTimeMakeWithSeconds(20, timerange.duration.timescale))) {
                if (_playing == 2) {
                    [player play];
                    _playing = 3;
                }
            }
        }
    } else {
        if (LOGMODE) {
            NSLog(@"keypath: %@, status: %lu, tracks: %lu, chage: %@", keyPath, player.currentItem.status, (unsigned long)[[player.currentItem tracks] count] , change);
        }
    }
    if ([player.currentItem tracks] == nil) {
        if (LOGMODE) {
            NSLog(@"track null");
        }
        [player insertItem:[AVPlayerItem playerItemWithURL:fileUrl] afterItem:nil];
//        if (isStreaming) {
//          //두번째 스트리밍일때
//            NSLog(@"is streaming");
//        }
    }
    if (LOGMODE) {
        if ([keyPath isEqual: @"player.currentItem.playbackBufferEmpty"])
        {
            NSLog(@"buffer empty");
            //        [player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:fileUrl]];
            //        [player advanceToNextItem];
            //        [player insertItem:[AVPlayerItem playerItemWithURL:fileUrl] afterItem:player.currentItem];
        } else if (context == AVSPPlayerLayerLikelyToKeepUp) {
            NSLog(@"likely to keep up");
        }
    }
    
	if (context == AVSPPlayerItemStatusContext)
	{
        if (LOGMODE) {
            NSLog(@"in status");
        }
        if ([change objectForKey:NSKeyValueChangeNewKey] != [NSNull null]) {
            AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            switch (status)
            {
                case AVPlayerItemStatusUnknown:
                    if (LOGMODE) {
                        NSLog(@"unknown");
                    }
                    [m_lbStatus2 setStringValue:@"알수없음"];
                    break;
                case AVPlayerItemStatusReadyToPlay:
                    [m_lbStatus2 setStringValue:@"버퍼링...기다려주세요"];
                    if (LOGMODE) {
                        NSLog(@"ready to play");
                    }
                    isStreaming = YES;
                    [player play];
                    break;
                case AVPlayerItemStatusFailed:
                    [m_lbStatus2 setStringValue:@"실패혹은방종"];
                    // 버퍼끝날때도 잠간 뜨는문제가있음
                    if (LOGMODE) {
                        NSLog(@"failed:%@", [[[[self player] currentItem] error] description]);
                    }
                    [self close];
                    break;
            }
        } else {
            if (LOGMODE) {
                NSLog(@"%@", change);
            }
//            NSLog(@"%@", [(AVURLAsset*)player.currentItem.asset URL]);
//            [self close];
//            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:fileUrl];
//            [[self player] replaceCurrentItemWithPlayerItem:playerItem];
            
        }
	}
	else if (context == AVSPPlayerRateContext)
	{
		float rate = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
		if (rate != 1.f)
		{
            if (LOGMODE) {
                NSLog(@"paused");
            }
            // 버퍼링 끝나면 알아서 플레이됨
		}
		else
		{
            if (LOGMODE) {
                NSLog(@"playing");
            }
		}
	}
	else if (context == AVSPPlayerLayerReadyForDisplay)
	{
        if (LOGMODE) {
            NSLog(@"case3");
        }
		if ([[change objectForKey:NSKeyValueChangeNewKey] boolValue] == YES)
		{
			// The AVPlayerLayer is ready for display. Hide the loading spinner and show it.
//			[self stopLoadingAnimationAndHandleError:nil];
			[[self playerLayer] setHidden:NO];
		}
//        [player play];
//        [player insertItem:[AVPlayerItem playerItemWithURL:fileUrl] afterItem:player.currentItem];
	}
	else
	{
//        [player play];
	}
}

- (void)close
{
    NSLog(@"close");
	[player pause];
    [self removeAllObservers];
    [m_lbStatus2 setStringValue:@"실패 혹은 방종"];
}
- (void)removeAllObservers {
//	[[self player] removeTimeObserver:[self timeObserverToken]];
    if (LOGMODE) {
        [self removeObserver:self forKeyPath:@"player.rate"];
        [self removeObserver:self forKeyPath:@"player.currentItem.playbackBufferEmpty"];
        [self removeObserver:self forKeyPath:@"player.currentItem.playbackLikelyToKeepUp"];
    }
	[self removeObserver:self forKeyPath:@"player.currentItem.status"];
    [player release];
//	[self setTimeObserverToken:nil];
//    [self removeObserver:self forKeyPath:@"playerLayer.readyForDisplpay"];
//    [self removeObserver:self forKeyPath:@"playerLayer.readyToPlay"];
//	if ([self playerLayer])
//		[self removeObserver:self forKeyPath:@"playerLayer.readyForDisplay"];
//	[super close];
    
}
+ (NSSet *)keyPathsForValuesAffectingDuration
{
	return [NSSet setWithObjects:@"player.currentItem", @"player.currentItem.status", nil];
}

//- (double)duration
//{
//	AVPlayerItem *playerItem = [[self player] currentItem];
//	
//	if ([playerItem status] == AVPlayerItemStatusReadyToPlay)
//		return CMTimeGetSeconds([[playerItem asset] duration]);
//	else
//		return 0.f;
//}

- (double)currentTime
{
	return CMTimeGetSeconds([[self player] currentTime]);
}

- (void)setCurrentTime:(double)time
{
	[[self player] seekToTime:CMTimeMakeWithSeconds(time, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

+ (NSSet *)keyPathsForValuesAffectingVolume
{
	return [NSSet setWithObject:@"player.volume"];
}


- (IBAction)setVolume:(id)sender {
    NSSlider *slider = sender;
	[player setVolume:([slider doubleValue]/100.0)];
}

- (IBAction)toggleFull:(id)sender {

    if (isFull) {
        [m_webView setFrame:NSRectFromCGRect(CGRectMake(m_webView.frame.origin.x, m_webView.frame.origin.y, 355, m_webView.frame.size.height))];
        [m_movieView setFrame:NSMakeRect(363, 0, self.view.frame.size.width - 363, self.view.frame.size.height-34)];
    } else {
        [m_webView setFrame:NSRectFromCGRect(CGRectMake(m_webView.frame.origin.x, m_webView.frame.origin.y, 0, m_webView.frame.size.height))];
        [m_movieView setFrame:NSMakeRect(0, 0, self.view.frame.size.width, self.view.frame.size.height-34)];
    }
    isFull = !isFull;
}

- (IBAction)playPauseToggle:(id)sender
{
    // 재생/정지버튼 안만듬
	if ([[self player] rate] != 1.f)
	{
		if ([self currentTime] == [self duration])
			[self setCurrentTime:0.f];
		[[self player] play];
	}
	else
	{
		[[self player] pause];
	}
}

- (IBAction)goHome:(id)sender {
//    [self close];
    [m_webView setMainFrameURL:@"http://m.afreeca.com/main.php"];
}

@end
