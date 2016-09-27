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
#import "Section.h"

typedef enum : NSUInteger {
    ViewControllerFilterDate,
    ViewControllerFilterFirstName,
    ViewControllerFilterLastName,
} ViewControllerDescriptorMode;

@interface TableVIewSearchController()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property (strong,nonatomic) NSArray *arrayStudents;
@property (strong,nonatomic) NSDateFormatter *dateFormatter;
@property (strong,nonatomic) NSArray *arraySection;
@property (strong,nonatomic) NSOperationQueue *opQueue;
@property (strong,nonatomic)UISegmentedControl *segmentedControl;


@end

@implementation TableVIewSearchController
-(void)loadView{
    [super loadView];
    self.segmentedControl = [[UISegmentedControl alloc]initWithItems:@[@"Дата",@"Фамилия",@"Имя"]];
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.segmentedControl addTarget:self action:@selector(actionFilter:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *segmentedControlBarButton = [[UIBarButtonItem alloc]initWithCustomView:self.segmentedControl];
     UIBarButtonItem *itemFlexible = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    [self.navigationController.toolbar setBarStyle:UIBarStyleDefault];
    NSArray<UIBarButtonItem*> *barButtonsitem = [[NSArray alloc]initWithObjects:itemFlexible,segmentedControlBarButton,itemFlexible, nil];
    [self setToolbarItems:barButtonsitem animated:YES];
}

-(void)viewDidLoad{
    
    NSInteger numberOfStudents = 1000;
    NSInteger fromAge = 18;
    NSInteger toAge = 23;

    NSMutableArray<Student*> *tempMArrayStudents = [[NSMutableArray alloc]init];
    for(NSInteger i = 0; i < numberOfStudents;i++)
    {
        Student *currentStudent = [[Student alloc]initRandomStudentWithDateOfBirthOfFromAge:fromAge toAge:toAge];
        [tempMArrayStudents addObject:currentStudent];
    }

    __weak TableVIewSearchController *weakSelf = self;
    self.opQueue = [[NSOperationQueue alloc] init];
    NSOperation *opFirstName = [NSBlockOperation blockOperationWithBlock:^{
        
            [weakSelf sortArray:tempMArrayStudents withModeDescriptor:weakSelf.segmentedControl.selectedSegmentIndex];
    }];
    [self.opQueue addOperation:opFirstName];
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

#pragma  mark - action

-(void)actionFilter:(UISegmentedControl*)sender{
    
    NSInteger modeDescriptor = [sender selectedSegmentIndex];
    NSOperation *opSort = [NSBlockOperation blockOperationWithBlock:^{
        [self sortArray:self.arrayStudents withModeDescriptor:modeDescriptor];
    }];
    [self.opQueue addOperation:opSort];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60.f;
}


#pragma mark - UITableViewDataSource
- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSMutableArray<NSString*> *mArrayShortSectionName;
    for(Section *currentSection in self.arraySection)
    {
        if(!mArrayShortSectionName)
        {
            mArrayShortSectionName = [[NSMutableArray alloc]init];
        }
        NSInteger modeDescriptor = self.segmentedControl.selectedSegmentIndex;
        NSRange shortNameRange;
        if(modeDescriptor == ViewControllerFilterDate)
        {
            shortNameRange = NSMakeRange(0, 3);
        }
        else
        {
            shortNameRange = NSMakeRange(0, 1);
        }

        NSString *shortSectionName = [currentSection.titleOfHeader substringWithRange:shortNameRange];
        [mArrayShortSectionName addObject:shortSectionName];
    }
    return [[NSArray alloc] initWithArray:mArrayShortSectionName];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    Section *sectionMonth = [self.arraySection objectAtIndex:section];
    
    return [sectionMonth.arrayItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifierStudentCell = @"StudentCell";
    
    StudentCell *studentCell = [tableView dequeueReusableCellWithIdentifier:identifierStudentCell];
    
    Section *sectionMonth = [self.arraySection objectAtIndex:indexPath.section];
    Student *currentStudent = [sectionMonth.arrayItems objectAtIndex:indexPath.row];
    studentCell.firstName.text = currentStudent.firstName;
    studentCell.lasttName.text = currentStudent.lastName;
    studentCell.dayOfBirth.text = [self.dateFormatter stringFromDate:currentStudent.dayOfBirth];
    return studentCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.arraySection count];
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return [[self.arraySection objectAtIndex:section] titleOfHeader];
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
        
        NSInteger modeDescriptor = self.segmentedControl.selectedSegmentIndex;
        NSArray *arrayFilteredSections =  [weakSelf filterArrayFromArray:weakSelf.arrayStudents  withModeDescriptor:modeDescriptor withFilter:searchText];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.arraySection = arrayFilteredSections;
            [weakSelf.tableView reloadData];
        });
    }];
    [self.opQueue addOperation:filterOp];
}
#pragma mark - sorted

-(void)sortArray:(NSArray*)array withModeDescriptor:(ViewControllerDescriptorMode)modeDescriptor{
    
    __weak TableVIewSearchController *weakSelf = self;
        NSSortDescriptor *sortDescriptorFirstName = [[NSSortDescriptor alloc]initWithKey:@"self.firstName" ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        
        NSSortDescriptor *sortDescriptorDate = [[NSSortDescriptor alloc]initWithKey:@"self.dayOfBirth" ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"MM YYYY dd"];
            NSString *date1 = [dateFormatter stringFromDate:obj1];
            NSString *date2 = [dateFormatter stringFromDate:obj2];
            return [date1 compare:date2];
        }];
        NSSortDescriptor *sortDescriptorLastName = [[NSSortDescriptor alloc]initWithKey:@"self.lastName" ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        NSMutableArray *mArray = [[NSMutableArray alloc]initWithArray:array];
        switch (modeDescriptor) {
            case ViewControllerFilterDate:
                weakSelf.arrayStudents = [mArray sortedArrayUsingDescriptors:@[sortDescriptorDate,sortDescriptorFirstName,sortDescriptorLastName]];
                break;
            case ViewControllerFilterFirstName:
                weakSelf.arrayStudents = [mArray sortedArrayUsingDescriptors:@[sortDescriptorFirstName,sortDescriptorLastName,sortDescriptorDate]];
                break;
            case ViewControllerFilterLastName:
                weakSelf.arrayStudents = [mArray sortedArrayUsingDescriptors:@[sortDescriptorLastName,sortDescriptorDate,sortDescriptorFirstName]];
                break;
        }
        NSArray *arraySections = [weakSelf filterArrayFromArray:weakSelf.arrayStudents withModeDescriptor:modeDescriptor withFilter:nil];
        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_async(queue, ^{
            weakSelf.arraySection = arraySections;
            [weakSelf.tableView reloadData];
        });
}

#pragma mark - filter

-(NSArray*)filterArrayFromArray:(NSArray*)arrayStudents withModeDescriptor:(ViewControllerDescriptorMode)modeDescriptor withFilter:(NSString*)filterStr{
    NSDateFormatter *dateMonthFormatter = [[NSDateFormatter alloc]init];
    NSMutableArray *mArraySection = nil;
    NSMutableArray *mArrayItems = nil;
    NSString *currentTitleOfSection = nil;
    Section *section = nil;
    [dateMonthFormatter setDateFormat:@"MMMM"];
    if([self.searchBar.text length] > 0)
    {
        filterStr = self.searchBar.text;
    }
    for (Student *currentStudent in arrayStudents)
    {
        
        if([filterStr length] > 0)
        {
            BOOL containInFirstName = [currentStudent.firstName localizedCaseInsensitiveContainsString:filterStr];
            BOOL containInLastName =[currentStudent.lastName localizedCaseInsensitiveContainsString:filterStr];
            if(!(containInFirstName | containInLastName))
            {
                continue;
            }
        }
        NSString *titleOfSection;
        switch (modeDescriptor) {
            case ViewControllerFilterDate:
                titleOfSection = [dateMonthFormatter stringFromDate:currentStudent.dayOfBirth];
                break;
            case ViewControllerFilterFirstName:
                titleOfSection = [currentStudent.firstName substringWithRange:NSMakeRange(0, 1)];
                break;
            case ViewControllerFilterLastName:
                titleOfSection = [currentStudent.lastName substringWithRange:NSMakeRange(0, 1)];
                break;
                
            default:
                break;
        }
        
        if(!mArraySection)
        {
            mArraySection = [[NSMutableArray alloc]init];
        }
        if(![titleOfSection isEqualToString:currentTitleOfSection])
        {
            section = [[Section alloc]init];
            section.titleOfHeader = titleOfSection;
            [mArraySection addObject:section];
            mArrayItems = [[NSMutableArray alloc]init];
            currentTitleOfSection = titleOfSection;
        }
        [mArrayItems addObject:currentStudent];
        section.arrayItems = [[NSArray alloc]initWithArray:mArrayItems];
    }
    return[[NSArray alloc]initWithArray:mArraySection];
}
@end
