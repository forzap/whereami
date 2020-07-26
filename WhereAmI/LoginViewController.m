//
//  LoginViewController.m
//  WhereAmI
//
//  Created by Forza on 25/07/2020.
//  Copyright © 2020 Forza. All rights reserved.
//

#import "LoginViewController.h"
#import "ViewMapController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

#pragma mark View Methods

-(void)viewDidLoad {
    [super viewDidLoad];
    
    // Set self as delegate
    txtUsername.delegate = self;
    txtPassword.delegate = self;
    
    // To hide keyboard when tap on other area in view
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

-(void)viewWillAppear:(BOOL)animated {
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [[FIRAuth auth] removeAuthStateDidChangeListener:FIRHandle];
}

-(void)dismissKeyboard
{
    [txtUsername resignFirstResponder];
    [txtPassword resignFirstResponder];
}

- (IBAction) btnLoginClick:(id)sender {
    [[FIRAuth auth] signInWithEmail:txtUsername.text
                           password:txtPassword.text
                         completion:^(FIRAuthDataResult * _Nullable authResult,
                                      NSError * _Nullable error) {
        if (!error) {
            [self performSegueWithIdentifier:@"loginViewToMapView" sender:sender];
        } else {
            UIAlertController * alert = [UIAlertController
            alertControllerWithTitle:@"Login Failed"
                             message:error.localizedDescription
                      preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                }];
            [alert addAction:okAction];
            [[[LoginViewController keyWindow] rootViewController] presentViewController:alert animated:YES completion:^{
            }];
        }
    }];
}

- (IBAction) btnSignUpClick:(id)sender {
    UIAlertController * alert = [UIAlertController
    alertControllerWithTitle:@"Sign Up"
                     message:@""
              preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Username (email)";
        textField.secureTextEntry = NO;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Password (min 6 char)";
        textField.secureTextEntry = YES;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Sign Up" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[FIRAuth auth] createUserWithEmail:[[alert textFields][0] text]
                                   password:[[alert textFields][1] text]
                                 completion:^(FIRAuthDataResult * _Nullable authResult,
                                              NSError * _Nullable error) {
            NSString *msgString = @"Sign up successful";
            if (error) {
                msgString = error.localizedDescription;
            }
            
            UIAlertController * alert = [UIAlertController
            alertControllerWithTitle:@"Sign Up"
                             message:msgString
                      preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                }];
            [alert addAction:okAction];
            [[[LoginViewController keyWindow] rootViewController] presentViewController:alert animated:YES completion:^{
            }];
        }];
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [[[LoginViewController keyWindow] rootViewController] presentViewController:alert animated:YES completion:^{
    }];
}


#pragma mark TextField Delegates
    
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [txtUsername resignFirstResponder];
    [txtPassword resignFirstResponder];
    
    return YES;
}

#pragma mark Others

+(UIWindow*)keyWindow {
    UIWindow *windowRoot = nil;
    NSArray *windows = [[UIApplication sharedApplication]windows];
    for (UIWindow *window in windows) {
        if (window.isKeyWindow) {
            windowRoot = window;
            break;
        }
    }
    return windowRoot;
}
    
@end
