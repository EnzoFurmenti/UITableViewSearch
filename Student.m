//
//  Student.m
//  UITableViewSearch
//
//  Created by EnzoF on 25.09.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import "Student.h"


static NSString *firstNames[] = {
    @"Милена",
    @"Инна",
    @"Богдан",
    @"Анатолий",
    @"Тимофей",
    @"Родион",
    @"Альбина",
    @"Семён",
    @"Глеб",
    @"Вячеслав",
    @"Алла",
    @"Василиса",
    @"Анжелика",
    @"Марат",
    @"Владислав",
    @"Ярослав",
    @"Маргарита",
    @"Матвей",
    @"Тимур",
    @"Виталий",
    @"Степан"
};
static int firstNameCount = 21;

static NSString *lastNames[] = {
    @"Шуткевич",
    @"Робинович",
    @"Тореро",
    @"Айбу",
    @"Хосе",
    @"Каншау",
    @"Франсуа",
    @"Тойбухаа",
    @"Качаа",
    @"Зиа",
    @"Хожулаа",
    @"Дурново",
    @"Дубяго",
    @"Черных",
    @"Сухих",
    @"Чутких",
    @"Белаго",
    @"Хитрово",
    @"Бегун",
    @"Мельник",
    @"Шевченко"
};
static int lastNameCount = 21;



@implementation Student

-(instancetype)initRandomStudentWithDateOfBirthOfFromAge:(NSInteger)fromAge toAge:(NSInteger)toAge{
    self = [super init];
    if(self)
    {
        self.firstName = firstNames[arc4random() % firstNameCount];
        self.lastName = lastNames[arc4random() % lastNameCount];
        self.dayOfBirth = [self dateOfBirthFromAge:fromAge toAge:toAge];
    }
    return self;
}








#pragma mark - metods

- (NSDate*)dateOfBirthFromAge:(NSInteger)fromAge toAge:(NSInteger)toAge{
    NSDate *currentdDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *allCurrentDateComponents = [calendar components:  NSCalendarUnitEra   |
                                                  NSCalendarUnitYear  |
                                                  NSCalendarUnitMonth |
                                                  NSCalendarUnitDay   |
                                                  NSCalendarUnitHour  |
                                                  NSCalendarUnitMinute|
                                                  NSCalendarUnitSecond|
                                                  NSCalendarUnitNanosecond
                                                             fromDate:currentdDate];
    NSInteger era = [allCurrentDateComponents era];
    
    NSInteger fromYear = [allCurrentDateComponents year] - toAge;
    NSInteger toYear = [allCurrentDateComponents year] - fromAge;
    
    NSInteger month = [allCurrentDateComponents month];
    NSInteger day = [allCurrentDateComponents day];
    NSInteger hour = [allCurrentDateComponents hour];
    NSInteger minute = [allCurrentDateComponents minute];
    NSInteger second = [allCurrentDateComponents second];
    NSInteger nanosecond = [allCurrentDateComponents nanosecond];
    
    
    NSDate *fromDate = [calendar dateWithEra:era year:fromYear month:month day:day hour:hour minute:minute second:second nanosecond:nanosecond];
    
    NSDate *toDate = [calendar dateWithEra:era year:toYear month:month day:day hour:hour minute:minute second:second nanosecond:nanosecond];
    
    NSTimeInterval rangeTimeInterval = [toDate timeIntervalSinceDate:fromDate];
    NSInteger intRangeTimeInterval = (NSInteger)rangeTimeInterval;
    NSTimeInterval randomTimeInterval = (NSTimeInterval)(arc4random() % intRangeTimeInterval);
    NSDate *dateOfBirth = [NSDate dateWithTimeInterval:randomTimeInterval sinceDate:fromDate];
    return dateOfBirth;
}


@end
