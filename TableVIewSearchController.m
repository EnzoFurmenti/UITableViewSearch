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
#import "SectionMonth.h"

@interface TableVIewSearchController()<UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic) NSArray *arrayStudents;
@property (strong,nonatomic) NSDateFormatter *dateFormatter;
@property (strong,nonatomic) NSArray *arraySectionMonth;

@end

@implementation TableVIewSearchController

-(void)viewDidLoad{
    
    NSInteger numberOfStudents = 20;
    
    NSMutableArray<Student*> *tempMArrayStudents = [[NSMutableArray alloc]init];
    for(NSInteger i = 0; i < numberOfStudents;i++)
    {
        Student *currentStudent = [[Student alloc]initRandomStudentWithDateOfBirthOfFromAge:18 toAge:23];
        [tempMArrayStudents addObject:currentStudent];
    }
    
    NSSortDescriptor *sortDescriptorStudent = [[NSSortDescriptor alloc]initWithKey:@"self" ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        Student *student1 = (Student*)obj1;
        Student *student2 = (Student*)obj2;
        if([student1.firstName compare:student2.firstName] == NSOrderedSame)
        {
            return [student1.lastName compare:student2.lastName];
        }
        return [student1.firstName compare:student2.firstName];
        
    }];
    
    NSSortDescriptor *sortDescriptorMonth = [[NSSortDescriptor alloc]initWithKey:@"self" ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        Student *student1 = (Student*)obj1;
        Student *student2 = (Student*)obj2;
        NSDateFormatter *dateMonthFormatter = [[NSDateFormatter alloc]init];
        [dateMonthFormatter setDateFormat:@"MM"];
        NSString *monthStudent1 = [dateMonthFormatter stringFromDate:student1.dayOfBirth];
        NSString *monthStudent2 = [dateMonthFormatter stringFromDate:student2.dayOfBirth];
        return [monthStudent1 compare:monthStudent2];
    }];
    
    [tempMArrayStudents sortUsingDescriptors:@[sortDescriptorStudent]];
    self.arrayStudents = [tempMArrayStudents sortedArrayUsingDescriptors:@[sortDescriptorMonth]];
    
    
    
    NSDateFormatter *dateMonthFormatter = [[NSDateFormatter alloc]init];
    NSMutableArray *mArraySectionMonth = nil;
    NSMutableArray *mArrayItems = nil;
    NSString *currentMonth = nil;
    SectionMonth *sectionMonth = nil;
    [dateMonthFormatter setDateFormat:@"MMMM"];
    
    for (Student *currentStudent in self.arrayStudents)
    {
        NSString *month = [dateMonthFormatter stringFromDate:currentStudent.dayOfBirth];
        
        if(!mArraySectionMonth)
        {
            mArraySectionMonth = [[NSMutableArray alloc]init];
        }

        if(![month isEqualToString:currentMonth])
        {
            sectionMonth = [[SectionMonth alloc]init];
            sectionMonth.titleOfHeader = month;
            [mArraySectionMonth addObject:sectionMonth];
            mArrayItems = [[NSMutableArray alloc]init];
            currentMonth = month;
        }
        [mArrayItems addObject:currentStudent];
        sectionMonth.arrayItems = [[NSArray alloc]initWithArray:mArrayItems];
    }
    
    self.arraySectionMonth = [[NSArray alloc]initWithArray:mArraySectionMonth];
    
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

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSMutableArray<NSString*> *mArrayShortMountsName;
    for(SectionMonth *currentSection in self.arraySectionMonth)
    {
        if(!mArrayShortMountsName)
        {
            mArrayShortMountsName = [[NSMutableArray alloc]
                                     init];        }
        NSRange thirdSymbolRange = NSMakeRange(0, 3);
        NSString *shortNameMonth = [currentSection.titleOfHeader substringWithRange:thirdSymbolRange];
        [mArrayShortMountsName addObject:shortNameMonth];
    }
    return [[NSArray alloc] initWithArray:mArrayShortMountsName];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    SectionMonth *sectionMonth = [self.arraySectionMonth objectAtIndex:section];
    
    return [sectionMonth.arrayItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifierStudentCell = @"StudentCell";
    
    StudentCell *studentCell = [tableView dequeueReusableCellWithIdentifier:identifierStudentCell];
    
    SectionMonth *sectionMonth = [self.arraySectionMonth objectAtIndex:indexPath.section];
    Student *currentStudent = [sectionMonth.arrayItems objectAtIndex:indexPath.row];
    studentCell.firstName.text = currentStudent.firstName;
    studentCell.lasttName.text = currentStudent.lastName;
    studentCell.dayOfBirth.text = [self.dateFormatter stringFromDate:currentStudent.dayOfBirth];
    return studentCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.arraySectionMonth count];
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return [[self.arraySectionMonth objectAtIndex:section] titleOfHeader];
}


@end
