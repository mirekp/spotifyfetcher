//
//  SpotifyFetcher.m
//  spotifyfetcher
//
//  Created by Mirek Petricek on 21/04/2016.
//  Copyright © 2016 Mirek Petricek. All rights reserved.
//

#import "SpotifyFetcher.h"
#import "SpotifyAlbumEntry.h"

@implementation SpotifyFetcher

- (void) fetch
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:@"https://api.spotify.com/v1/artists/36QJpDe2go2KgaRleHCDTp/albums?limit=50"];
    NSAssert(url, @"Something is wrong with the supplied URL");

    // since this is called on main thread, use asynchronous API in order not to block main thread while
    // the data is fetched
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                
        // extract the data from JSON data object
        if (!error && data)
        {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

            // check if there wasn't error and we were able to parse the response to JSON
            if (!error || [json isKindOfClass:[NSDictionary class]])
            {
                NSMutableArray<SpotifyAlbumEntry*>* albumEntriesMutable = [[[NSMutableArray alloc] init] autorelease];
            
                NSArray<NSDictionary*>* items = [json objectForKey:@"items"];
            
                if ([items isKindOfClass:[NSArray class]])
                {
                    for (NSDictionary* item in items)
                    {
                        // name is the actual name of the album
                        NSString* name = [item objectForKey:@"name"];

                        // href contains a link to album details (we need that for album cover and album year)
                        NSURL* url = [NSURL URLWithString:[item objectForKey:@"href"]];
                    
                        if ([name isKindOfClass:[NSString class]] && [url isKindOfClass:[NSURL class]])
                        {
                            SpotifyAlbumEntry* albumEntry = [[SpotifyAlbumEntry alloc] init];
                            albumEntry.name = name;
                            [albumEntry fetchAlbumDataFrom:url];
                            [albumEntriesMutable addObject:albumEntry];
                        
                            // release the  entry as the NSArray is now retaining it
                            [albumEntry release];
                        }
                    }
                }

                // only return success if we have at least one entry
                if ([albumEntriesMutable count])
                {
                    // make a immutable copy of the array with entries.
                    self.albumEntries = [albumEntriesMutable copy];
                
                    // dispatch the delegate method (to make sure it arrives on main thread rather than background thread
                    // this completion handler is running on
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_delegate didFetchData];
                    });
                    return;
                }
            }
        }
        
        // Something went wrong (network issue, response parsing). Notify the delegate.
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate didFailToFetchData];
        });
    }];
    
    [dataTask resume];
}

- (void) dealloc
{
    [super dealloc];
    self.albumEntries = nil;
}

@end
