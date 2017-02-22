//
//  ViewController.m
//  BlockAllTwitter
//
//  Created by iMokhles on 21/02/2017.
//  Copyright © 2017 iMokhles. All rights reserved.
//

#import "ViewController.h"
#import "STTwitter.h"
#import <Accounts/Accounts.h>

#define kTwitterUserName @"iMokhles"

@interface ViewController () <STTwitterAPIOSProtocol>

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, retain) NSArray *osxAccounts;
@property (nonatomic, retain) STTwitterAPI *twitter;
@end
@implementation ViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    _accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [_accountStore requestAccessToAccountsWithType:twitterAccountType
                                           options:nil
                                        completion:^(BOOL granted, NSError *error) {
                                            
                                            // bug in OS X 10.11
                                            // even if the user grants access,
                                            // granted will be NO and error will be
                                            // Error Domain=com.apple.accounts
                                            // Code=1
                                            // UserInfo={NSLocalizedDescription=Setting TCC failed.}
                                            
                                            NSLog(@"-- granded: %d, error: %@", granted, error);
                                            
                                            if(granted == NO) {
                                                NSLog(@"-- %@", error);
                                                return;
                                            }
                                            
                                            self.osxAccounts = [_accountStore accountsWithAccountType:twitterAccountType];
                                        }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // Do any additional setup after loading the view.
}

- (IBAction)logIn:(id)sender {
    
    ACAccount *account = [self.osxAccounts lastObject];
    
    if(account == nil) {
        //        self.osxStatus = @"No account, cannot login.";
        return;
    }
    
    self.twitter = [STTwitterAPI twitterAPIOSWithAccount:account delegate:self];
    
    
    [_twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        
        
    } errorBlock:^(NSError *error) {
        
        
        
    }];
    
}
- (IBAction)blockAllTapped:(id)sender {
    
    [_twitter getFollowersIDsForScreenName:kTwitterUserName successBlock:^(NSArray *followers) {
        for (int i = 0; i < followers.count; i++) {
            NSLog(@"******* %i", i);
            NSString *userID = [followers objectAtIndex:i];
            [_twitter postBlocksCreateWithScreenName:nil orUserID:userID includeEntities:0 skipStatus:0 successBlock:^(NSDictionary *user) {
                
                
                //                    NSLog(@"***** %@", user);
            } errorBlock:^(NSError *error) {
                NSLog(@"***** %@", [error localizedDescription]);
            }];
        }
    } errorBlock:^(NSError *error) {
        NSLog(@"***** %@", [error localizedDescription]);
    }];
    
}
- (IBAction)unblockAllTapped:(id)sender {
    [_twitter getBlocksIDsWithCursor:0 successBlock:^(NSArray *ids, NSString *previousCursor, NSString *nextCursor) {
        
        NSLog(@"******* %lu", (unsigned long)ids.count);
        for (int i = 0; i < ids.count; i++) {
            NSLog(@"******* %i", i);
            NSString *userID = [ids objectAtIndex:i];
            
            [_twitter postBlocksDestroyWithScreenName:nil orUserID:userID includeEntities:0 skipStatus:0 successBlock:^(NSDictionary *user) {
                
                //                    NSLog(@"***** %@", user);
            } errorBlock:^(NSError *error) {
                //
                NSLog(@"***** %@", [error localizedDescription]);
                
            }];
        }
        
        //            NSLog(@"****** %lu", (unsigned long)ids.count);
    } errorBlock:^(NSError *error) {
        NSLog(@"***** %@", [error localizedDescription]);
    }];
}

- (void)twitterAPI:(STTwitterAPI *)twitterAPI accountWasInvalidated:(ACAccount *)invalidatedAccount {
    NSLog(@"-- invalidatedAccount: %@ | %@", invalidatedAccount, invalidatedAccount.username);

}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
