//
//  ListingViewController.m
//  WhereAmI
//
//  Created by Forza on 25/07/2020.
//  Copyright © 2020 Forza. All rights reserved.
//

#import "ListingViewController.h"
#import "ActivityViewController.h"
#import "DBConnection.h"
#import <Foundation/Foundation.h>

@interface ListingTableViewCell ()

@end

@implementation ListingTableViewCell

@end

@interface ListingViewController ()

@end

@implementation ListingViewController

#pragma mark View Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    arrListing = [DBConnection getData];
    selectedRow = -1;
}

#pragma mark Table View Delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"ListingCell";
    ListingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    NSMutableDictionary *dict = [arrListing objectAtIndex:indexPath.row];
    cell.imgVwThumb.image = [UIImage imageWithData:[dict objectForKey:@"imgData"]];
    cell.lblLocation.text = [NSString stringWithFormat:@"%.4f, %.4f", [[dict objectForKey:@"latitude"] floatValue], [[dict objectForKey:@"longitude"] floatValue]];
    cell.lblSelectedValue.text = [dict objectForKey:@"selectedText"];
    cell.lblComments.text = [dict objectForKey:@"comments"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedRow = (int)indexPath.row;
    [self performSegueWithIdentifier:@"listingViewToActivityView" sender:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrListing count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark Others

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"listingViewToActivityView"] && selectedRow >= 0)
    {
        NSMutableDictionary *dict = [arrListing objectAtIndex:selectedRow];
        
        ActivityViewController *vc = [segue destinationViewController];
        vc.isViewOnly = YES;
        vc.latitude = [[dict objectForKey:@"latitude"] floatValue];
        vc.longitude = [[dict objectForKey:@"longitude"] floatValue];
        vc.selectedValue = [dict objectForKey:@"selectedText"];
        vc.selectedIndex = [[dict objectForKey:@"selectedIndex"] intValue];
        vc.comments = [dict objectForKey:@"comments"];
        vc.image = [UIImage imageWithData:[dict objectForKey:@"imgData"]];
    }
}

@end
