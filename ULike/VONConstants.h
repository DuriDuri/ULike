//
//  VONConstants.h
//  ULike
//
//  Created by Duri Abdurahman Duri on 7/9/14.
//  Copyright (c) 2014 Duri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VONConstants : NSObject

#pragma mark -User Detail Profile

extern NSString *const kVONUserTagLineKey;


extern NSString *const kVONUserProfileKey;
extern NSString *const kVONUserProfileNameKey;
extern NSString *const kVONUserProfileFirstNameKey;
extern NSString *const kVONUserProfileLocation;
extern NSString *const kVONUserProfileGender;
extern NSString *const kVONUserProfileBirthday;
extern NSString *const kVONUserProfileInterestedIn;
extern NSString *const kVONUserProfilePictureURL;
extern NSString *const kVONUserProfileRelationshipStatusKey;
extern NSString *const kVONUserProfileAgeKey;

#pragma mark - Photo
extern NSString *const kVONPhotoClassKey;
extern NSString *const kVONPhotoUserKey;
extern NSString *const kVONPhotoPictureKey;



#pragma mark -Activity Class
extern NSString *const kVONActivityClassKey;
extern NSString *const kVONActivityTypeKey;
extern NSString *const kVONActivityFromUserKey;
extern NSString *const kVONActivityToUserKey;
extern NSString *const kVONActivityPhotoKey;
extern NSString *const kVONActivityTypeLikeKey;
extern NSString *const kVONActivityTypeDislikeKey;


#pragma mark - Settings

extern NSString *const kVONMenEnabledKey;
extern NSString *const kVONWomenEnabledKey;
extern NSString *const kVONSingleEnabledKey;
extern NSString *const kVONAgeMaxKey;

@end
