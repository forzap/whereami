//
//  ActivityViewController.h
//  WhereAmI
//
//  Created by Forza on 25/07/2020.
//  Copyright © 2020 Forza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate> {
    __weak IBOutlet UILabel *lblLocation;
    __weak IBOutlet UILabel *lblSelectedValue;
    __weak IBOutlet UITextField *txtComments;
    __weak IBOutlet UIPickerView *pickerSelection;
    __weak IBOutlet UIView *vwForm;
    __weak IBOutlet UIButton *btnCaptureImage;
    __weak IBOutlet UIImageView *imgVwCaptureImage;
    __weak IBOutlet UIButton *btnSubmit;
    __weak IBOutlet UIButton *btnCancel;
    __weak IBOutlet UIProgressView *vwLine;
    
    NSArray *arrPickerData;
}

- (void)selectionLabelTapped:(id)sender;
- (IBAction)btnCaptureImageClick:(id)sender;
- (IBAction)btnSubmitClick:(id)sender;
- (IBAction)btnCancelClick:(id)sender;

@property (nonatomic, readwrite) BOOL isViewOnly;
@property (nonatomic, readwrite) double latitude;
@property (nonatomic, readwrite) double longitude;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *selectedValue;
@property (nonatomic, readwrite) int selectedIndex;
@property (nonatomic, retain) NSString *comments;
@property (nonatomic, retain) UIImage *image;

@end /* ActivityViewController_h */
