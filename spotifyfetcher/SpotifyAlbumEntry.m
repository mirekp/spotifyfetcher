//
//  SpotifyAlbumEntry.m
//  spotifyfetcher
//
//  Created by Mirek Petricek on 21/04/2016.
//  Copyright © 2016 Mirek Petricek. All rights reserved.
//

#import "SpotifyAlbumEntry.h"

// shared NSDateFormater singleton
NSDateFormatter *dateFormatter;

@implementation SpotifyAlbumEntry

- (instancetype) init
{
    if (self = [super init])
    {
        // we are using this shared formatter to parse album release year
        // since NSDateFormatter is expensive to allocate, use a shared copy
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dateFormatter = [[NSDateFormatter alloc] init];
        });
    }
    return self;
}

- (void) fetchAlbumDataFrom:(NSURL*)url
{
    // since this is called on a background thread, we can use blocking network I/O
    NSData* data = [NSData dataWithContentsOfURL:url];
    if (data)
    {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        // Set date persing format based on "release_date_precision" key
        NSString* releaseDatePrecision = [json objectForKey:@"release_date_precision"];
        
        if ([releaseDatePrecision isEqualToString:@"year"])
        {
            [dateFormatter setDateFormat:@"yyyy"];
        }
        else if ([releaseDatePrecision isEqualToString:@"month"])
        {
            [dateFormatter setDateFormat:@"yyyy-MM"];
        }
        else
        {
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        }
        
        NSDate *releaseDate = [dateFormatter dateFromString:[json objectForKey:@"release_date"]];

        // NSCalendar doesn't like nil values, so let's do sanity check here in case the previous
        // call failed to produce valid NSDate object
        if (releaseDate)
        {
            // extract year of release from NSDate
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear
                                                                           fromDate:releaseDate];
            if (components.year)
            {
                self.year = [NSString stringWithFormat:@"%@", @(components.year)];
            }
        }
        
        NSArray<NSDictionary*>* images = [json objectForKey:@"images"];
        if ([images isKindOfClass:[NSArray class]])
        {
            // the last entry should be the one with lowest resolution. It should be sufficient as a thumbnail.
            NSDictionary* smallestImage = [images lastObject];
            NSURL* imageURL = [NSURL URLWithString:[smallestImage objectForKey:@"url"]];
            self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
        }
    }
    else
    {
        // if we can't get data for whatever reason, it is probably OK to do nothing.
        // Better implementation could fallback to some placeholder text?
    }
}

- (void) dealloc
{
    // release any retained properties (if we are retaining some)
    self.name = nil;
    self.year = nil;
    self.image = nil;
    
    [super dealloc];
}

@end
