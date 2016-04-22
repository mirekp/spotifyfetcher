//
//  SpotifyFetcher.h
//  spotifyfetcher
//
//  Created by Mirek Petricek on 21/04/2016.
//  Copyright © 2016 Mirek Petricek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class SpotifyAlbumEntry;

// this protocol is adopted by whatever uses this fetcher
@protocol SpotifyFetcherDelegate
- (void) didFetchData;
- (void) didFailToFetchData;
@end

@interface SpotifyFetcher : NSObject

@property (nonatomic, assign) UIViewController<SpotifyFetcherDelegate>* delegate;
@property (nonatomic, retain) NSArray<SpotifyAlbumEntry*>* albumEntries;

// this function does the initial fetch once UI is ready
- (void) fetch;

@end
