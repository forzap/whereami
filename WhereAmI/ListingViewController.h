//
//  ListingViewController.h
//  WhereAmI
//
//  Created by Forza on 25/07/2020.
//  Copyright © 2020 Forza. All rights reserved.
//

#ifndef ListingViewController_h
#define ListingViewController_h

#import <UIKit/UIKit.h>

@interface ListingTableViewCell : UITableViewCell {

}

@property (nonatomic, weak) IBOutlet UIImageView *imgVwThumb;
@property (nonatomic, weak) IBOutlet UILabel *lblLocation;
@property (nonatomic, weak) IBOutlet UILabel *lblSelectedValue;
@property (nonatomic, weak) IBOutlet UILabel *lblComments;


@end

@interface ListingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    __weak IBOutlet UITableView *tblListing;
    
    NSMutableArray *arrListing;
    int selectedRow;
}

@end

#endif /* ListingViewController_h */
