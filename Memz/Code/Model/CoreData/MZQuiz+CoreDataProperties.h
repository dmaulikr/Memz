//
//  MZQuiz+CoreDataProperties.h
//  
//
//  Created by Bastien Falcou on 12/27/15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MZQuiz.h"
#import "MZResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface MZQuiz (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSNumber *isAnswered;
@property (nullable, nonatomic, retain) NSSet<MZResponse *> *responses;

@end

@interface MZQuiz (CoreDataGeneratedAccessors)

- (void)addResponsesObject:(MZResponse *)value;
- (void)removeResponsesObject:(MZResponse *)value;
- (void)addResponses:(NSSet<MZResponse *> *)values;
- (void)removeResponses:(NSSet<MZResponse *> *)values;

@end

NS_ASSUME_NONNULL_END
