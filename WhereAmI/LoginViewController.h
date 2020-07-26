//
//  LoginViewController.h
//  WhereAmI
//
//  Created by Forza on 25/07/2020.
//  Copyright © 2020 Forza. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;

@interface LoginViewController : UIViewController <UITextFieldDelegate> {
    __weak IBOutlet UITextField *txtUsername;
    __weak IBOutlet UITextField *txtPassword;
    
    FIRAuthStateDidChangeListenerHandle FIRHandle;
}

- (IBAction)btnLoginClick:(id)sender;
- (IBAction)btnSignUpClick:(id)sender;

@end

