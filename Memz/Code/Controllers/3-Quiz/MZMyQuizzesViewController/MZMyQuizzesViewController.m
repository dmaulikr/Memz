//
//  MZMyQuizzesViewController.m
//  Memz
//
//  Created by Bastien Falcou on 12/16/15.
//  Copyright © 2015 Falcou. All rights reserved.
//

#import "MZMyQuizzesViewController.h"
#import "MZMyQuizzesTableViewCell.h"
#import "MZQuizInfoView.h"
#import "MZQuizViewController.h"
#import "NSManagedObject+MemzCoreData.h"
#import "MZDataManager.h"
#import "MZQuiz.h"

typedef NS_ENUM(NSInteger, MZScrollDirection) {
	MZScrollDirectionNone = 0,
	MZScrollDirectionDown,
	MZScrollDirectionUp
};

const CGFloat kTopShrinkableViewMinimumHeight = 40.0f;
const CGFloat kTopShrinkableViewMaximumHeight = 100.0f;

const CGFloat kQuizzesTableViewEstimatedRowHeight = 100.0f;

NSString * const kQuizTableViewCellIdentifier = @"MZMyQuizzesTableViewCellIdentifier";

@interface MZMyQuizzesViewController () <UITableViewDataSource,
UITableViewDelegate,
MZQuizInfoViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray<MZQuiz *> *tableViewData;

@property (weak, nonatomic) IBOutlet MZQuizInfoView *topShrinkableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topShrinkableViewHeightConstraint;

@property (nonatomic, assign) CGPoint lastContentOffset;

@end

@implementation MZMyQuizzesViewController

// TODO: Have a NSFetchedResultsController

- (void)viewDidLoad {
	[super viewDidLoad];

	[self setupTableViewData];
	[self.tableView reloadData];

	self.tableView.estimatedRowHeight = kQuizzesTableViewEstimatedRowHeight;
	self.tableView.rowHeight = UITableViewAutomaticDimension;

	self.tableView.contentInset = UIEdgeInsetsMake(kTopShrinkableViewMaximumHeight, 0.0f, 0.0f, 0.0f);
	self.tableView.contentOffset = CGPointMake(0.0f, -self.topShrinkableViewHeightConstraint.constant);
	self.tableView.tableFooterView = [[UIView alloc] init];

	self.topShrinkableView.delegate = self;
}

- (void)setupTableViewData {
	NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"isAnswered"
																															 ascending:YES];
	self.tableViewData = [MZQuiz allObjectsMatchingPredicate:nil sortDescriptors:@[descriptor]];
}

#pragma mark - Table View DataSource & Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.tableViewData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	MZMyQuizzesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kQuizTableViewCellIdentifier
																																	 forIndexPath:indexPath];
	cell.quiz = self.tableViewData[indexPath.row];
	return cell;
}

#pragma mark - Scroll Management

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	MZScrollDirection scrollDirection = [self scrollDirectionForScrollView:scrollView];
	scrollView.contentInset = UIEdgeInsetsMake(self.topShrinkableViewHeightConstraint.constant,
																						 scrollView.contentInset.left,
																						 scrollView.contentInset.bottom,
																						 scrollView.contentInset.right);

	if (scrollView.contentOffset.y < -scrollView.contentInset.top
			|| scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height + scrollView.contentInset.bottom)) {
		// TODO: Second condition doesn't work if contentSize.height < scrollView.frame.size.height
		self.lastContentOffset = scrollView.contentOffset;
		return;
	}

	if (scrollDirection == MZScrollDirectionDown) {
		if (self.topShrinkableViewHeightConstraint.constant < kTopShrinkableViewMaximumHeight) {
			self.topShrinkableViewHeightConstraint.constant += self.lastContentOffset.y - scrollView.contentOffset.y;
		}
	}

	if (scrollDirection == MZScrollDirectionUp) {
		if (self.topShrinkableViewHeightConstraint.constant > kTopShrinkableViewMinimumHeight) {
			self.topShrinkableViewHeightConstraint.constant += self.lastContentOffset.y - scrollView.contentOffset.y;
		}
	}

	if (self.topShrinkableViewHeightConstraint.constant > kTopShrinkableViewMaximumHeight) {
		self.topShrinkableViewHeightConstraint.constant = kTopShrinkableViewMaximumHeight;
	} else if (self.topShrinkableViewHeightConstraint.constant < kTopShrinkableViewMinimumHeight) {
		self.topShrinkableViewHeightConstraint.constant = kTopShrinkableViewMinimumHeight;
	}
	self.lastContentOffset = scrollView.contentOffset;
}

- (MZScrollDirection)scrollDirectionForScrollView:(UIScrollView *)scrollView {
	if (self.lastContentOffset.y > scrollView.contentOffset.y) {
		return MZScrollDirectionDown;
	} else if (self.lastContentOffset.y < scrollView.contentOffset.y) {
		return MZScrollDirectionUp;
	} else {
		return MZScrollDirectionNone;
	}
}

#pragma mark - Quiz Info View Delegate Methods

- (void)quizInfoViewDidRequestNewQuiz:(MZQuizInfoView *)quizInfoView {
	MZQuiz *quiz = [MZQuiz generateRandomQuiz];

	[MZQuizViewController askQuiz:quiz fromViewController:self completionBlock:^{
		[[MZDataManager sharedDataManager] saveChangesWithCompletionHandler:nil];
	}];
}

@end
