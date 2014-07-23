//
//  VONHomeViewController.m
//  ULike
//
//  Created by Duri Abdurahman Duri on 7/10/14.
//  Copyright (c) 2014 Duri. All rights reserved.
//

#import "VONHomeViewController.h"
#import "VONTestUser.h"
#import "VONProfileViewController.h"
#import "VONMatchViewController.h"

@interface VONHomeViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *chatBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButtonItem;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLineLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;


@property (strong, nonatomic) PFObject *photo;
@property (strong, nonatomic) NSMutableArray *activities;
@property (strong, nonatomic) NSArray *photos;

@property (nonatomic) int currentPhotoIndex;
@property (nonatomic) BOOL isLikedByCurrentUser;
@property (nonatomic) BOOL isDislikedByCurrentUser;


@end

@implementation VONHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[VONTestUser saveTestUserToParse];
    
    
    self.likeButton.enabled = NO;
    self.dislikeButton.enabled = NO;
    self.infoButton.enabled = NO;
    
    self.currentPhotoIndex = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:kVONPhotoClassKey];
    
    //leave until later
    [query whereKey:kVONPhotoUserKey notEqualTo:[PFUser currentUser]];
    [query includeKey:kVONPhotoUserKey];
    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.photos = objects;
            [self queryForCurrentPhotoIndex];
        } else {
            NSLog(@"%@", error);
        }
    }];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)chatBarButtonPressed:(UIBarButtonItem *)sender {
}


- (IBAction)settignsBarButtonPressed:(UIBarButtonItem *)sender {
}


- (IBAction)likeButtonPressed:(UIButton *)sender {
    [self checkLike];
}


- (IBAction)dislikeButtonPressed:(UIButton *)sender {
    [self checkDislike];
}


- (IBAction)infoButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"homeToProfileSegue" sender:nil];
}


//loginToHomeSegue

 #pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     if ([segue.identifier isEqualToString:@"homeToProfileSegue"]) {
         
         VONProfileViewController *nextProfileViewVC = segue.destinationViewController;
         nextProfileViewVC.photo = self.photo;
     }
     else if ([segue.identifier isEqualToString:@"homeToMatchSegue"]){
         VONMatchViewController *matchVC = segue.destinationViewController;
         matchVC.matchedUserImage = self.photoImageView.image;
         //matchVC.delegate = self;
     }
 }

#pragma mark - Helper

-(void)queryForCurrentPhotoIndex
{
    if ([self.photos count] > 0) {
        self.photo = self.photos[self.currentPhotoIndex];
        PFFile *file = self.photo[kVONPhotoPictureKey];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if(!error){
                UIImage *image = [UIImage imageWithData:data];
                self.photoImageView.image = image;
                [self updateView];
            }
            else NSLog(@"%@", error);
        }];
        
        PFQuery *queryForLike = [PFQuery queryWithClassName:kVONActivityClassKey];
        [queryForLike whereKey:kVONActivityTypeKey equalTo:kVONActivityTypeLikeKey];
        [queryForLike whereKey:kVONActivityPhotoKey equalTo:self.photo];
        [queryForLike whereKey:kVONActivityFromUserKey equalTo:[PFUser currentUser]];
        
        
        PFQuery *queryForDislike = [PFQuery queryWithClassName:kVONActivityClassKey];
        [queryForDislike whereKey:kVONActivityTypeKey equalTo:kVONActivityTypeDislikeKey];
        [queryForDislike whereKey:kVONActivityPhotoKey equalTo:self.photo];
        [queryForDislike whereKey:kVONActivityFromUserKey equalTo:[PFUser currentUser]];
        
        PFQuery *likedAndDislikedQuery = [PFQuery orQueryWithSubqueries:@[queryForLike, queryForDislike]];
        
        [likedAndDislikedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.activities = [objects mutableCopy];
                
                if ([self.activities count] == 0) {
                    self.isDislikedByCurrentUser = NO;
                    self.isLikedByCurrentUser = NO;
                }
                else {
                    PFObject *activity = self.activities[0];
                    
                    if ([activity[kVONActivityTypeKey] isEqualToString:kVONActivityTypeLikeKey]) {
                        self.isLikedByCurrentUser = YES;
                        self.isDislikedByCurrentUser = NO;
                    }
                    else if ([activity[kVONActivityTypeKey] isEqualToString:kVONActivityTypeDislikeKey]){
                        self.isDislikedByCurrentUser = YES;
                        self.isLikedByCurrentUser = NO;
                    }
                    else{
                        //some other activity
                    }
                }
                self.likeButton.enabled = YES;
                self.dislikeButton.enabled = YES;
                self.infoButton.enabled = YES;
            }
        }];
    }
}

-(void)updateView
{
    NSLog(@"%@", self.photo[kVONPhotoUserKey]);
    self.firstNameLabel.text = self.photo[kVONPhotoUserKey][kVONUserProfileKey][kVONUserProfileFirstNameKey];
    self.ageLabel.text= [NSString stringWithFormat:@"%@", self.photo[kVONPhotoUserKey][kVONUserProfileKey][kVONUserProfileAgeKey]];
    self.tagLineLabel.text = self.photo[kVONPhotoUserKey][kVONUserProfileKey][kVONUserTagLineKey];
}


-(void)setupNextPhoto
{
    if (self.currentPhotoIndex +1 < self.photos.count) {
        self.currentPhotoIndex ++;
        [self queryForCurrentPhotoIndex];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No More Users" message:@"Check back later to find more users" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)saveLike
{
    PFObject *likeActivity = [PFObject objectWithClassName:kVONActivityClassKey];
    [likeActivity setObject:kVONActivityTypeLikeKey forKey:kVONActivityTypeKey];
    [likeActivity setObject:[PFUser currentUser] forKey:kVONActivityFromUserKey];
    [likeActivity setObject:[self.photo objectForKey:kVONPhotoUserKey] forKey:kVONActivityToUserKey];
    [likeActivity setObject:self.photo forKey:kVONActivityPhotoKey];
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = YES;
        self.isDislikedByCurrentUser = NO;
        [self.activities addObject:likeActivity];
        [self checkForPhotoUserLikes];
        [self setupNextPhoto];
    }];
}


-(void)saveDislike
{
    PFObject *dislikeActivity = [PFObject objectWithClassName:kVONActivityClassKey];
    [dislikeActivity setObject:kVONActivityTypeDislikeKey forKey:kVONActivityTypeKey];
    [dislikeActivity setObject:[PFUser currentUser] forKey:kVONActivityFromUserKey];
    [dislikeActivity setObject:[self.photo objectForKey:kVONPhotoUserKey] forKey:kVONActivityToUserKey];
    [dislikeActivity setObject:self.photo forKey:kVONActivityPhotoKey];
    [dislikeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = NO;
        self.isDislikedByCurrentUser = YES;
        [self.activities addObject:dislikeActivity];
        [self setupNextPhoto];
    }];
}


-(void)checkLike
{
    if(self.isLikedByCurrentUser){
        [self setupNextPhoto];
        return;
    }
    else if (self.isDislikedByCurrentUser){
        for (PFObject *activity in self.activities) {
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveLike];
    }
    else{
        [self saveLike];
    }
}

- (void)checkDislike
{
    if (self.isDislikedByCurrentUser){
        [self setupNextPhoto];
        return;
    }
    else if (self.isLikedByCurrentUser){
        for (PFObject *activity in self.activities) {
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveDislike];
    }
    else [self saveDislike];
}


-(void)checkForPhotoUserLikes
{
    PFQuery *query = [PFQuery queryWithClassName:kVONActivityClassKey];
    [query whereKey:kVONActivityFromUserKey equalTo:self.photo[kVONPhotoUserKey]];
    [query whereKey:kVONActivityToUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kVONActivityTypeKey equalTo:kVONActivityTypeLikeKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0){
            //create our chatroom here
            [self createChatRoom];
        }
    }];
}

-(void) createChatRoom
{
    PFQuery *queryForChatRoom = [PFQuery queryWithClassName:@"ChatRoom"];
    [queryForChatRoom whereKey:@"user1" equalTo:[PFUser currentUser]];
    [queryForChatRoom whereKey:@"user2" equalTo:self.photo[kVONPhotoUserKey]];
    
    PFQuery *queryForChatRoomInverse = [PFQuery queryWithClassName:@"ChatRoom"];
    [queryForChatRoomInverse whereKey:@"user1" equalTo:self.photo[kVONPhotoUserKey]];
    [queryForChatRoomInverse whereKey:@"user2" equalTo:[PFUser currentUser]];
    
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[queryForChatRoom, queryForChatRoomInverse]];
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] == 0) {
            PFObject *chatRoom = [PFObject objectWithClassName:@"ChatRoom"];
            [chatRoom setObject:[PFUser currentUser] forKey:@"user1"];
            [chatRoom setObject:self.photo[kVONPhotoUserKey] forKey:@"user2"];
            [chatRoom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self performSegueWithIdentifier:@"homeToMatchSegue" sender:nil];
            }];
        }
    }];
}

@end
