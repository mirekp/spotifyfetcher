//
//  SpotifyAlbumEntry.h
//  spotifyfetcher
//
//  Created by Mirek Petricek on 21/04/2016.
//  Copyright © 2016 Mirek Petricek. All rights reserved.
//

@import UIKit;

@interface SpotifyAlbumEntry : NSObject

@property (retain) UIImage* image;
@property (copy) NSString* name;
@property (copy) NSString* year;

// retrieves album data from URL
- (void) fetchAlbumDataFrom:(NSURL*)url;

@end
