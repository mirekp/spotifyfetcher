//
//  ViewController.h
//  spotifyfetcher
//
//  Created by Mirek Petricek on 21/04/2016.
//  Copyright © 2016 Mirek Petricek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpotifyFetcher.h"

@interface SpotifyViewController : UIViewController <SpotifyFetcherDelegate, UITableViewDataSource>

@property (nonatomic, retain) SpotifyFetcher* fetcher;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UILabel *activityIndicatorLabel;

@end

