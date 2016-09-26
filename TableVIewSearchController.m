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

@interface TableVIewSearchController()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property (strong,nonatomic) NSArray *arrayStudents;
@property (strong,nonatomic) NSDateFormatter *dateFormatter;
@property (strong,nonatomic) NSArray *arraySectionMonth;
@property (strong,nonatomic) NSArray *arrayFilteredSectionMonth;
@property (strong,nonatomic) NSOperationQueue *opQueue;
@end

@implementation TableVIewSearchController

-(void)viewDidLoad{
    
    NSInteger numberOfStudents = 30000;
    NSInteger fromAge = 18;
    NSInteger toAge = 23;

    NSMutableArray<Student*> *tempMArrayStudents = [[NSMutableArray alloc]init];
    for(NSInteger i = 0; i < numberOfStudents;i++)
    {
        Student *currentStudent = [[Student alloc]initRandomStudentWithDateOfBirthOfFromAge:fromAge toAge:toAge];
        [tempMArrayStudents addObject:currentStudent];
    }
    
    __weak TableVIewSearchController *weakSelf = self;
    NSOperation *sortOperation = [NSBlockOperation blockOperationWithBlock:^{
        
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
        weakSelf.arrayStudents = [tempMArrayStudents sortedArrayUsingDescriptors:@[sortDescriptorMonth]];
        NSArray *arrayMonthSections = [weakSelf sortArrayFromArray:self.arrayStudents];
        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_async(queue, ^{
            weakSelf.arraySectionMonth = arrayMonthSections;
            [weakSelf.tableView reloadData];
        });
    }];
    self.opQueue = [[NSOperationQueue alloc] init];
    [self.opQueue addOperation:sortOperation];
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


#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:YES animated:YES];
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    [self.opQueue cancelAllOperations];
    __weak TableVIewSearchController *weakSelf = self;
    NSOperation *filterOp = [NSBlockOperation blockOperationWithBlock:^{
        NSArray *arrayFilteredSections =  [weakSelf sortArrayFromArray:weakSelf.arrayStudents withFilter:searchText];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.arraySectionMonth = arrayFilteredSections;
            [weakSelf.tableView reloadData];
        });
    }];
    [self.opQueue addOperation:filterOp];
}
#pragma mark - metods

-(NSArray*)sortArrayFromArray:(NSArray*)arrayStudents{
    NSDateFormatter *dateMonthFormatter = [[NSDateFormatter alloc]init];
    NSMutableArray *mArraySectionMonth = nil;
    NSMutableArray *mArrayItems = nil;
    NSString *currentMonth = nil;
    SectionMonth *sectionMonth = nil;
    [dateMonthFormatter setDateFormat:@"MMMM"];
    
    for (Student *currentStudent in arrayStudents)
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
    return[[NSArray alloc]initWithArray:mArraySectionMonth];
}

-(NSArray*)sortArrayFromArray:(NSArray*)arrayStudents withFilter:(NSString*)filterStr{
    NSMutableArray<Student*> *mArrayStudents = [[NSMutableArray alloc]init];
    if([filterStr length] > 0)
    {
        for (Student *currentStudent in arrayStudents)
        {
            BOOL containInFirstName = [currentStudent.firstName localizedCaseInsensitiveContainsString:filterStr];
            BOOL containInLastName =[currentStudent.lastName localizedCaseInsensitiveContainsString:filterStr];
            if(containInFirstName | containInLastName)
            {
                [mArrayStudents addObject:currentStudent];
            }
        }
    }
    else{
        mArrayStudents = [[NSMutableArray alloc]initWithArray:self.arrayStudents];
    }
    NSArray *arrayFiltredStudents = [[NSArray alloc]initWithArray:mArrayStudents];
    return [self sortArrayFromArray:arrayFiltredStudents];
}


@end
