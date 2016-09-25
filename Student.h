//
//  Student.h
//  UITableViewSearch
//
//  Created by EnzoF on 25.09.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Student : NSObject

@property (strong,nonatomic) NSString *firstName;
@property (strong,nonatomic) NSString *lastName;
@property (strong,nonatomic) NSDate *dayOfBirth;


-(instancetype)initRandomStudentWithDateOfBirthOfFromAge:(NSInteger)fromAge toAge:(NSInteger)toAge;

@end
