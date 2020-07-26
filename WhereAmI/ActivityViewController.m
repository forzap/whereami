#import "ActivityViewController.h"
#import "DBConnection.h"
#import <AVFoundation/AVFoundation.h>

@interface ActivityViewController ()

@end

@implementation ActivityViewController

@synthesize isViewOnly, latitude, longitude, selectedValue, selectedIndex, comments, image;

#pragma mark View Methods

-(id)init{
    if ((self = [super init]))
    {
        self.isViewOnly = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Picker sample data
    arrPickerData = @[
        @"Item 1",
        @"Item 2",
        @"Item 3",
        @"Item 4",
        @"Item 5",
        @"Item 6"];
    
    if (!self.isViewOnly) {
        // Show user coordinates
        lblLocation.text = [NSString stringWithFormat:@"%.4f, %.4f", self.latitude, self.longitude];
        
        // Add tap gesture to Selection label
        UITapGestureRecognizer *tapSelection = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectionLabelTapped:)];
        tapSelection.numberOfTapsRequired = 1;
        [lblSelectedValue addGestureRecognizer:tapSelection];
        
        // To hide keyboard when tap on other area in view
        UITapGestureRecognizer *tapComments = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
        [self.view addGestureRecognizer:tapComments];
        txtComments.delegate = self;
        
        // Init picker
        pickerSelection.dataSource = self;
        pickerSelection.delegate = self;
        lblSelectedValue.tag = -1;
        
        // Disable Submit button, only allow submit if taken photo
        btnSubmit.enabled = NO;
    } else {
        // Show user coordinates
        lblLocation.text = [NSString stringWithFormat:@"%.4f, %.4f", self.latitude, self.longitude];
        
        // Show selected text
        lblSelectedValue.userInteractionEnabled = NO;
        lblSelectedValue.text = self.selectedIndex >= 0 ? arrPickerData[self.selectedIndex] : @"";
        lblSelectedValue.tag = self.selectedIndex;
        
        // Show comments
        txtComments.enabled = NO;
        txtComments.text = self.comments;
        
        // Show image
        btnCaptureImage.hidden = YES;
        imgVwCaptureImage.image = self.image;
        
        // Hide buttons
        btnSubmit.hidden = YES;
        btnCancel.hidden = YES;
        vwLine.hidden = YES;
    }
}

- (IBAction) btnCaptureImageClick:(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    
    // Image picker needs a delegate,
    [imagePickerController setDelegate:self];
    
    // Place image picker on the screen
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }];
}

- (IBAction) btnSubmitClick:(id)sender {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithDouble:self.latitude] forKey:@"latitude"];
    [dict setObject:[NSNumber numberWithDouble:self.longitude] forKey:@"longitude"];
    if (lblSelectedValue.tag >= 0) {
        [dict setValue:lblSelectedValue.text forKey:@"selectedText"];
    } else {
        [dict setValue:@"" forKey:@"selectedText"];
    }
    [dict setObject:[NSNumber numberWithInt:(int)lblSelectedValue.tag] forKey:@"selectedIndex"];
    [dict setValue:txtComments.text forKey:@"comments"];
    [dict setObject:UIImagePNGRepresentation(imgVwCaptureImage.image) forKey:@"imgData"];
    [DBConnection saveData:dict];
    
    [self performSegueWithIdentifier:@"activityViewToListingView" sender:sender];
}

- (IBAction) btnCancelClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dismissKeyboard
{
    [txtComments resignFirstResponder];
}

#pragma mark TextField Delegates

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [txtComments resignFirstResponder];
    
    return YES;
}

#pragma mark Image Picker Delegates

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    picker.delegate = nil;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // Save the photo into buffer
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage* img = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // Resize the photo with correct aspect ratio
    CGSize sizeVw = imgVwCaptureImage.frame.size;
    CGRect ratioRect = CGRectMake(0.0f, 0.0f, sizeVw.width, sizeVw.height);
    CGSize ratioSize = CGSizeMake(img.size.width, img.size.height);
    CGSize newSize = AVMakeRectWithAspectRatioInsideRect(ratioSize, ratioRect).size;
    UIGraphicsBeginImageContext(newSize);
    [img drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // Set button background as the taken photo
    imgVwCaptureImage.image = newImg;
    [btnCaptureImage setTitle:@"" forState:UIControlStateNormal];
    
    btnSubmit.enabled = YES;
}

#pragma mark Selection Picker Delegates

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [arrPickerData count];
}

 - (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
     return arrPickerData[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    pickerSelection.hidden = YES;
    vwForm.hidden = NO;
    
    lblSelectedValue.text = arrPickerData[row];
    lblSelectedValue.tag = row;
}

#pragma mark Others

- (void)selectionLabelTapped:(id)sender {
    pickerSelection.hidden = NO;
    vwForm.hidden = YES;
}

    
@end
