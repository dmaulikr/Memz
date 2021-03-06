//
//  NSDate+MemzAdditions.m
//  Memz
//
//  Created by Bastien Falcou on 1/8/16.
//  Copyright © 2016 Falcou. All rights reserved.
//

#import "NSDate+MemzAdditions.h"

@implementation NSDate (MemzAdditions)

#pragma mark - String Formatting

// TODO: NSDateFormatter make static

- (NSString *)relativeOrAbsoluteDateString {
	if ([self isToday]) {
		return NSLocalizedString(@"DateTodayTitle", nil);
	} else if ([self isYesterday]) {
		return NSLocalizedString(@"DateYesterdayTitle", nil);
	}
	// TODO: Implement this week, last week, this month, last month
	return [self humanReadableDateString];
}

- (NSString *)humanReadableDateString {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	return [dateFormatter stringFromDate:self];
}

- (NSString *)weekDay {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
	[formatter setDateFormat:@"EEEE"];
	NSString *weekDay = [formatter stringFromDate:self];
	return weekDay.length > 1 ? [[weekDay substringToIndex:1] uppercaseString] : nil;
}

- (NSString *)month {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
	[formatter setDateFormat:@"MMM"];
	NSLog(@"DESCRIPTION: %@", [formatter stringFromDate:self]);
	return [formatter stringFromDate:self];
}

- (NSInteger)day {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSCalendarUnitDay) fromDate:self];
	return [components day];
}

- (NSString *)time {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
	[formatter setDateFormat:@"hh:mma"];
	return [formatter stringFromDate:self];
}

- (NSInteger)hour {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSCalendarUnitHour) fromDate:self];
	return [components hour];
}

- (NSInteger)minute {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSCalendarUnitMinute) fromDate:self];
	return [components minute];
}

#pragma mark - Operations Within Current Day

- (NSDate *)beginningDayDate {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute) fromDate:self];
	components.hour = 0;
	components.minute = 0;
	return [calendar dateFromComponents:components];
}

- (NSDate *)endDayDate {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:self];
	components.day = 1;
	return [calendar dateByAddingComponents:components toDate:[self beginningDayDate] options:0];
}

#pragma mark - Operations Different Days

- (NSDate *)dayForDaysInThePast:(NSUInteger)daysInPast {
	NSDate *dateBeforeDays = [self dateByAddingTimeInterval:-60 * 60 * 24 * (double)daysInPast];
	return dateBeforeDays;
}

- (NSDate *)dayBefore {
	return [self dayForDaysInThePast:1];
}

- (NSDate *)dayForDaysInTheFuture:(NSInteger)daysAfter {
	NSDate *dateAfterDays = [self dateByAddingTimeInterval:60 * 60 * 24 * (double)daysAfter];
	return dateAfterDays;
}

- (NSDate *)dayAfter {
	return [self dayForDaysInTheFuture:1];
}

- (NSDate *)hoursBefore:(NSInteger)hoursBefore {
	NSDate *dateBeforeDays = [self dateByAddingTimeInterval:-60 * 60 * (double)hoursBefore];
	return dateBeforeDays;
}

- (NSInteger)numberDaysDifferenceWithDate:(NSDate *)date {
	NSDate *fromDate;
	NSDate *toDate;

	NSCalendar *calendar = [NSCalendar currentCalendar];

	[calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:nil forDate:self];
	[calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:nil forDate:date];

	NSDateComponents *difference = [calendar components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:0];

	return [difference day];
}

#pragma mark - Checks

- (BOOL)isLaterToday {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *selectedDateComponents = [calendar components:(NSCalendarUnitHour|NSCalendarUnitMinute) fromDate:self];
	NSDateComponents *currentDateComponents = [calendar components:(NSCalendarUnitHour|NSCalendarUnitMinute) fromDate:[NSDate date]];

	return [self isToday] && (selectedDateComponents.hour < currentDateComponents.hour
															 || (selectedDateComponents.hour == currentDateComponents.hour
																	 && selectedDateComponents.minute < currentDateComponents.minute));
}

- (BOOL)isSameDay:(NSDate *)date {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components1 = [calendar components:(NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear) fromDate:date];
	NSDateComponents *components2 = [calendar components:(NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear) fromDate:self];

	return (([components1 year] == [components2 year]) &&
					([components1 month] == [components2 month]) &&
					([components1 day] == [components2 day]));
}

- (BOOL)isToday {
	return [self isSameDay:[NSDate date]];
}

- (BOOL)isTomorrow {
	NSDate *tomorrow = [NSDate dateWithTimeInterval:(24 * 60 * 60) sinceDate:[NSDate date]];
	NSUInteger tomorrowDayOfYear = [[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:tomorrow];
	NSUInteger dateDayOfYear = [[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:self];
	return tomorrowDayOfYear == dateDayOfYear;
}

- (BOOL)isTomorrowOrLater {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *selectedDateComponents = [calendar components:(NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitEra) fromDate:self];
	NSDateComponents *currentDateComponents = [calendar components:(NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitEra) fromDate:[NSDate date]];

	return (selectedDateComponents.day > currentDateComponents.day
					|| selectedDateComponents.month > currentDateComponents.month
					|| selectedDateComponents.year > currentDateComponents.year);
}

- (BOOL)isBeforeDate:(NSDate *)date {
	return [self compare:date] == NSOrderedAscending;
}

- (BOOL)isBeforeNow {
	return [self isBeforeDate:[NSDate date]];
}

- (BOOL)isYesterday {
	NSDate *yesterday = [NSDate dateWithTimeInterval:-(24 * 60 * 60) sinceDate:[NSDate date]];
	NSUInteger yesterdayDayOfYear = [[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:yesterday];
	NSUInteger dateDayOfYear = [[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:self];
	return yesterdayDayOfYear == dateDayOfYear;
}

@end
