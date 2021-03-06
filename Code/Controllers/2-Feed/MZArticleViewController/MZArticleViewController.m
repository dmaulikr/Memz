//
//  MZArticleViewController.m
//  Memz
//
//  Created by Bastien Falcou on 3/6/16.
//  Copyright © 2016 Falcou. All rights reserved.
//

#import "MZArticleViewController.h"
#import "MZArticlePictureTableViewCell.h"
#import "MZArticleTitleTableViewCell.h"
#import "MZArticleDetailsTableViewCell.h"
#import "MZArticleBodyTableViewCell.h"
#import "MZArticleAddAllTableViewCell.h"
#import "MZArticleSuggestedWordTableViewCell.h"
#import "MZArticleShareTableViewCell.h"
#import "UIImageView+MemzDownloadImage.h"
#import "NSDate+MemzAdditions.h"
#import "MZTableView.h"
#import "MZDataManager.h"

@import Social;

typedef NS_ENUM(NSUInteger, MZArticleTableViewRowType) {
	MZArticleTableViewRowTypePicture,
	MZArticleTableViewRowTypeTitle,
	MZArticleTableViewRowTypeDetails,
	MZArticleTableViewRowTypeBody,
	MZArticleTableViewRowTypeAddAll,
	MZArticleTableViewRowTypeSuggestedWord,
	MZArticleTableViewRowTypeShare
};

NSString * const kArticlePictureTableViewCellIdentifier = @"MZArticlePictureTableViewCellIdentifier";
NSString * const kArticleTitleTableViewCellIdentifier = @"MZArticleTitleTableViewCellIdentifier";
NSString * const kArticleDetailsTableViewCellIdentifier = @"MZArticleDetailsTableViewCellIdentifier";
NSString * const kArticleBodyTableViewCellIdentifier = @"MZArticleBodyTableViewCellIdentifier";
NSString * const kArticleAddAllTableViewCellIdentifier = @"MZArticleAddAllTableViewCellIdentifier";
NSString * const kArticleSuggestedWordTableViewCellIdentifier = @"MZArticleSuggestedWordTableViewCellIdentifier";
NSString * const kArticleShareTableViewCellIdentifier = @"MZArticleShareTableViewCellIdentifier";

const CGFloat kArticleTableViewEstimatedRowHeight = 100.0f;

@interface MZArticleViewController () <UITableViewDataSource,
UITableViewDelegate,
MZArticleAddAllTableViewCellDelegate,
MZArticleSuggestedWordTableViewCellDelegate,
MZArticleShareTableViewCellDelegate>

@property (nonatomic, strong) IBOutlet MZTableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *tableViewData;

@end

@implementation MZArticleViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.tableView.estimatedRowHeight = kArticleTableViewEstimatedRowHeight;
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)setupTableViewData {
	if (!self.article) {
		return;
	}

	self.tableViewData = [@[@{@"cellType": @(MZArticleTableViewRowTypePicture),
													 @"content": self.article.imageUrl},
												  @{@"cellType": @(MZArticleTableViewRowTypeTitle),
													 @"content": self.article.title},
												  @{@"cellType": @(MZArticleTableViewRowTypeDetails),
													 @"content": self.article.additionDate,
													 @"secondaryContent": self.article.source},
												  @{@"cellType": @(MZArticleTableViewRowTypeBody),
													 @"content": self.article.body}] mutableCopy];

	if (self.article.suggestedWords.count > 0) {
		[self.tableViewData addObject:@{@"cellType": @(MZArticleTableViewRowTypeAddAll)}];

		for (MZWord *suggestedWord in self.article.suggestedWords) {
			[self.tableViewData addObject:@{@"cellType": @(MZArticleTableViewRowTypeSuggestedWord),
																			@"content": suggestedWord}];
		}
	}

	[self.tableViewData addObject:@{@"cellType": @(MZArticleTableViewRowTypeShare)}];
}

#pragma mark - Custom Setters

- (void)setArticle:(MZArticle *)article {
	_article = article;

	[self setupTableViewData];
	[self.tableView reloadData];
}

#pragma mark - Table View Data Source & Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.tableViewData[indexPath.row][@"cellType"] integerValue] == MZArticleTableViewRowTypePicture) {
		return self.view.frame.size.height / 3.0f;
	}
	return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.tableViewData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch ([self.tableViewData[indexPath.row][@"cellType"] integerValue]) {
		case MZArticleTableViewRowTypePicture: {
			MZArticlePictureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kArticlePictureTableViewCellIdentifier
																																						forIndexPath:indexPath];
			[cell.articleImageView setImageWithURL:self.tableViewData[indexPath.row][@"content"]];
			return cell;
		}
		case MZArticleTableViewRowTypeTitle: {
			MZArticleTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kArticleTitleTableViewCellIdentifier
																																						forIndexPath:indexPath];
			cell.titleLabel.text = self.tableViewData[indexPath.row][@"content"];
			return cell;
		}
		case MZArticleTableViewRowTypeDetails: {
			MZArticleDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kArticleDetailsTableViewCellIdentifier
																																						forIndexPath:indexPath];
			NSDate *articleDate = [self.tableViewData[indexPath.row][@"content"] safeCastToClass:[NSDate class]];
			cell.dateLabel.text = [articleDate humanReadableDateString];
			cell.sourceLabel.text = self.tableViewData[indexPath.row][@"secondaryContent"];
			return cell;
		}
		case MZArticleTableViewRowTypeBody: {
			MZArticleBodyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kArticleBodyTableViewCellIdentifier
																																				 forIndexPath:indexPath];
			cell.bodyLabel.text = self.tableViewData[indexPath.row][@"content"];
			return cell;
		}
		case MZArticleTableViewRowTypeAddAll: {
			MZArticleAddAllTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kArticleAddAllTableViewCellIdentifier
																																					 forIndexPath:indexPath];
			cell.delegate = self;
			return cell;
		}
		case MZArticleTableViewRowTypeSuggestedWord: {
			MZArticleSuggestedWordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kArticleSuggestedWordTableViewCellIdentifier
																																					 forIndexPath:indexPath];
			cell.word = self.tableViewData[indexPath.row][@"content"];
			cell.delegate = self;
			return cell;
		}
		case MZArticleTableViewRowTypeShare: {
			MZArticleShareTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kArticleShareTableViewCellIdentifier
																																					forIndexPath:indexPath];
			cell.delegate = self;
			return cell;
		}
	}
	return nil;
}

#pragma mark - Add All Suggested Words Cell Delegate

- (void)articleAddAllTableViewCellDidTap:(MZArticleAddAllTableViewCell *)cell {
	for (MZWord *word in self.article.suggestedWords) {
		[[MZUser currentUser] addTranslationsObject:word];
	}

	[[MZAnalyticsManager sharedManager] trackArticleWordSuggestionAddition:YES];
	[[MZDataManager sharedDataManager] saveChanges];

	for (UITableViewCell *cell in self.tableView.visibleCells) {
		[[cell safeCastToClass:[MZArticleSuggestedWordTableViewCell class]] forceUpdate];
	}
}

#pragma mark - Add Suggested Word Cell Delegate

- (void)articleSuggestedWordTableViewCellDidTap:(MZArticleSuggestedWordTableViewCell *)cell {
	if (![[MZUser currentUser].translations containsObject:cell.word]) {
		[[MZUser currentUser] addTranslationsObject:cell.word];
	} else {
		[[MZUser currentUser] removeTranslationsObject:cell.word];
	}

	[[MZAnalyticsManager sharedManager] trackArticleWordSuggestionAddition:NO];
	[[MZDataManager sharedDataManager] saveChanges];
	[cell forceUpdate];
}

#pragma mark - Social Media Cell Delegate 

- (void)articleShareTableViewCell:(MZArticleShareTableViewCell *)cell didTapShareOption:(MZShareOption)shareOption {
	UIImage *image = [UIImage imageWithAssetIdentifier:MZAssetIdentifierCommonTitleIcon];
	[MZShareManager shareForType:shareOption title:self.article.title images:@[image] urls:nil completionHandler:nil];
}

@end
