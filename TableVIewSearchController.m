//
//  TableVIewSearchController.m
//  UITableViewSearch
//
//  Created by EnzoF on 25.09.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import "TableVIewSearchController.h"
#import "Student.h"
#import "StudentCell.h"

@interface TableVIewSearchController()<UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic) NSArray *arrayStudents;
@property (strong,nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation TableVIewSearchController

-(void)viewDidLoad{
    
    NSInteger numberOfStudents = 200;
    
    NSMutableArray<Student*> *tempMArrayStudents = [[NSMutableArray alloc]init];
    for(NSInteger i = 0; i < numberOfStudents;i++)
    {
        Student *currentStudent = [[Student alloc]initRandomStudentWithDateOfBirthOfFromAge:18 toAge:23];
        [tempMArrayStudents addObject:currentStudent];
    }
    self.arrayStudents = [[NSArray alloc]initWithArray:tempMArrayStudents];
}

#pragma mark - lazy Initialization

-(NSDateFormatter*)dateFormatter{
   if(!_dateFormatter)
   {
       NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
       [dateFormatter setDateFormat:@"dd MMMM YYYY"];
       _dateFormatter = dateFormatter;
   }
    return _dateFormatter;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60.f;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.arrayStudents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifierStudentCell = @"StudentCell";
    
    StudentCell *studentCell = [tableView dequeueReusableCellWithIdentifier:identifierStudentCell];

        Student *currentStudent = [self.arrayStudents objectAtIndex:indexPath.row];
        studentCell.firstName.text = currentStudent.firstName;
        studentCell.lasttName.text = currentStudent.lastName;
        studentCell.dayOfBirth.text = [self.dateFormatter stringFromDate:currentStudent.dayOfBirth];
        return studentCell;
}


@end
