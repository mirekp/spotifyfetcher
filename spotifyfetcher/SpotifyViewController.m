//
//  ViewController.m
//  spotifyfetcher
//
//  Created by Mirek Petricek on 21/04/2016.
//  Copyright © 2016 Mirek Petricek. All rights reserved.
//

#import "SpotifyViewController.h"
#import "SpotifyAlbumEntry.h"

@implementation SpotifyViewController

#pragma mark Constructtors & viewcontroller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Allocate model object
    SpotifyFetcher* fetcher = [[SpotifyFetcher alloc] init];
    self.fetcher = fetcher;
    self.fetcher.delegate = self;
    [fetcher release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // fetch album data from the service
    [self.fetcher fetch];
}

- (void)dealloc
{
    self.fetcher.delegate = nil;
    self.fetcher = nil;
    [super dealloc];
}

#pragma mark SpotifyFetcherDelegate

- (void)didFetchData
{
    // sems that we have valid data - update UI
    self.tableView.hidden = NO;
    [self.activityIndicator stopAnimating];
    self.activityIndicatorLabel.hidden = YES;
    [self.tableView reloadData];
}

- (void)didFailToFetchData
{
    // something went wrong - ideally, we should retry or provide more info, but simply fail for now.
    [self.activityIndicator stopAnimating];
    self.activityIndicatorLabel.text = @"Unable to load data...";
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fetcher.albumEntries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // is there a cell to recycle?
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SpotifyCell"];
    
    if (!cell)
    {
        // autoretain the cell to keep it in memory for a while. The caller will take care of the retaining it.
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:@"SpotifyCell"] autorelease];
    }
 
    // this should be always OK, but never mind it won't hurt to check we don't go outside the array.
    NSAssert(indexPath.row < [self.fetcher.albumEntries count], @"Unexpected cell required");
    SpotifyAlbumEntry* entry = [self.fetcher.albumEntries objectAtIndex:indexPath.row];
    
    // put the data from the entry
    cell.textLabel.text = entry.name;
    cell.detailTextLabel.text = entry.year;
    cell.imageView.image = entry.image;
    
    return cell;
}

@end
