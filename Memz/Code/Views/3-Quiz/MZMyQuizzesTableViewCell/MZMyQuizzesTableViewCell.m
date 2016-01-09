//
//  MZMyQuizzesTableViewCell.m
//  Memz
//
//  Created by Bastien Falcou on 12/16/15.
//  Copyright © 2015 Falcou. All rights reserved.
//

#import "MZMyQuizzesTableViewCell.h"
#import "NSDate+MemzAdditions.h"

@interface MZMyQuizzesTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *isAnsweredLabel;

@end

@implementation MZMyQuizzesTableViewCell

- (void)setQuiz:(MZQuiz *)quiz {
	_quiz = quiz;

	self.dateLabel.text = [quiz.date humanReadableDateString];
	self.isAnsweredLabel.text = quiz.isAnswered.boolValue ? NSLocalizedString(@"QuizResponseIsAnswered", nil) : NSLocalizedString(@"QuizResponsePending!", nil);
	self.contentView.backgroundColor = quiz.isAnswered ? [UIColor myQuizzesAnsweredBackgroundColor] : [UIColor myQuizzesPendingBackgroundColor];
}

@end
