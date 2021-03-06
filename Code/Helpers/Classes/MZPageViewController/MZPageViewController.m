//
//  MZPageViewController.m
//  Memz
//
//  Created by Bastien Falcou on 12/15/15.
//  Copyright © 2015 Falcou. All rights reserved.
//

#import "MZPageViewController.h"
#import "MZInjector.h"
#import "MZPageControl.h"
#import "CADisplayLink+MemzBlocks.h"
#import "UIPageControl+MemzCompatibility.h"
#import "UIImage+AssetIdentifiers.h"

const CGFloat kTitleViewHorizontalMargin = 80.0f;
const CGFloat kTitleViewMaxHeight = 26.0f;
const CGFloat kTitleViewMinimumAlpha = 0.45f;

const CGFloat kPageControlHeight = 6.0f;
const CGFloat kPageControlTopMargin = 2.0f;
const CGFloat kPageControlDotsSoace = 7.0f;

@interface MZPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong, readonly) MZPageControl *pageControl;
@property (nonatomic, strong, readonly) UIScrollView *titleScrollView;
@property (nonatomic, strong, readonly) UIView *titleView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) NSMutableDictionary *cachedViewControllers;
@property (nonatomic, copy) NSArray *titleLabels;

@end

@implementation MZPageViewController
@synthesize pageControl = _pageControl;
@synthesize titleScrollView = _titleScrollView;
@synthesize titleView = _titleView;

#pragma mark - Initializers 

- (id)init {
	return [self initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
								 navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
															 options:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	if (self = [super initWithCoder:coder]) {
		self.delegate = self;
		self.dataSource = self;

		_cachedViewControllers = [NSMutableDictionary dictionary];
	}
	return self;
}

- (id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style
				navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation
											options:(NSDictionary *)options {
	self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options];
	if (self != nil) {
		self.dataSource = self;
		self.dataSource = self;

		_cachedViewControllers = [NSMutableDictionary dictionary];
	}
	return self;
}

#pragma mark - Overridden Methods

- (void)viewDidLoad {
	[super viewDidLoad];

	self.navigationItem.titleView = self.titleView;

	[self setViewControllers:@[[self viewControllerForPage:0]]
								 direction:UIPageViewControllerNavigationDirectionForward
									animated:NO
								completion:nil];

	self.pageControl.currentPage = 0;

	__weak MZPageViewController *weakSelf = self;
	self.displayLink = [CADisplayLink displayLinkWithBlock:^(CADisplayLink *displayLink) {
		[weakSelf updateTitleViewPosition];
	}];
	NSRunLoop *runner = [NSRunLoop currentRunLoop];
	[self.displayLink addToRunLoop:runner forMode:NSRunLoopCommonModes];
}

- (void)dealloc {
	[self.displayLink invalidate];
	self.displayLink = nil;
}

- (UIViewController *)viewControllerForPage:(NSInteger)page {
	if (self.cachedViewControllers[@(page)] != nil) {
		return self.cachedViewControllers[@(page)];
	}

	MZPageViewControllerFactoryBlock factory = [self viewControllerFactoryForPage:page];
	NSAssert(factory != nil, @"Factory for page %ld is not defined", (long)page);
	UIViewController *viewController = factory();
	NSAssert(viewController != nil, @"View controller for page %ld is not defined", (long)page);
	self.cachedViewControllers[@(page)] = viewController;
	return viewController;
}

- (MZPageViewControllerFactoryBlock)viewControllerFactoryForPage:(NSInteger)page {
	return nil;
}

- (NSString *)titleForViewControllerForPage:(NSInteger)page {
	return nil;
}

- (NSAttributedString *)attributedTitleForViewControllerForPage:(NSInteger)page {
	return nil;
}

- (NSInteger)numberOfPage {
	return 0;
}

- (void)willChangeToPage:(NSInteger)page {
}

- (void)didChangeToPage:(NSInteger)page {
}

- (NSInteger)currentPage {
	return self.pageControl.currentPage;
}

- (void)setCurrentPage:(NSInteger)page {
	[self setViewControllers:@[[self viewControllerForPage:page]]
								 direction:UIPageViewControllerNavigationDirectionForward
									animated:NO
								completion:nil];

	[self updateTitleViewPosition];
	self.pageControl.currentPage = page;
}

- (UIViewController *)currentViewController {
	return [self viewControllerForPage:self.currentPage];
}

#pragma mark - UIPageViewController delegate methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
			viewControllerBeforeViewController:(UIViewController *)viewController {
	NSInteger page = [self pageOfViewController:viewController];
	if (--page < 0) {
		return nil;
	}

	UIViewController * nextViewController = [self viewControllerForPage:page];
	return nextViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
			 viewControllerAfterViewController:(UIViewController *)viewController {
	NSInteger page = [self pageOfViewController:viewController];
	if (++page >= [self numberOfPage]) {
		return nil;
	}

	UIViewController * nextViewController = [self viewControllerForPage:page];
	return nextViewController;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
	[self willChangeToPage:[self pageOfViewController:[pendingViewControllers firstObject]]];
}

- (void)pageViewController:(UIPageViewController *)pageViewController
				didFinishAnimating:(BOOL)finished
	 previousViewControllers:(NSArray *)previousViewControllers
			 transitionCompleted:(BOOL)completed {
	NSInteger page = [self pageOfViewController:[pageViewController.viewControllers firstObject]];
	self.pageControl.currentPage = page;

	[self didChangeToPage:page];
}

#pragma mark - Custom getters

- (MZPageControl *)pageControl {
	if (_pageControl == nil) {
		_pageControl = [[MZPageControl alloc] init];
		_pageControl.numberOfPages = [self numberOfPage];
		_pageControl.currentPage = 0;
		_pageControl.dotsSpace = kPageControlDotsSoace;
		_pageControl.middleDotImageInactive = [UIImage imageWithAssetIdentifier:MZAssetIdentifierCommonCarouselDotInactive];
		_pageControl.middleDotImageActive = [UIImage imageWithAssetIdentifier:MZAssetIdentifierCommonCarouselDotActive];
	}
	return _pageControl;
}

- (UIScrollView *)titleScrollView {
	if (_titleScrollView == nil) {
		UIScrollView * titleScrollView = [[UIScrollView alloc] init];

		CGSize size = CGSizeMake(self.view.frame.size.width - kTitleViewHorizontalMargin * 2.0f, kTitleViewMaxHeight);

		NSMutableArray * labels = [NSMutableArray array];
		for(NSInteger i = 0;i < [self numberOfPage];++i) {
			UILabel * label = [[UILabel alloc] init];
			label.font = [[UINavigationBar appearance] titleTextAttributes][NSFontAttributeName];
			label.text = [self titleForViewControllerForPage:i];
			label.attributedText = [self attributedTitleForViewControllerForPage:i];
			label.textAlignment = NSTextAlignmentCenter;
			label.textColor = [[UINavigationBar appearance] titleTextAttributes][NSForegroundColorAttributeName];
			label.frame = CGRectMake(size.width * i, 0.0f, size.width, size.height);

			[titleScrollView addSubview:label];
			[labels addObject:label];
		}

		self.titleLabels = labels;

		titleScrollView.showsHorizontalScrollIndicator = NO;
		titleScrollView.pagingEnabled = YES;
		titleScrollView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
		titleScrollView.contentSize = CGSizeMake(size.width * 2.0f, size.height);
		_titleScrollView = titleScrollView;
	}
	return _titleScrollView;
}

- (UIView *)titleView {
	if(_titleView == nil) {
		UIView * titleView = [[UIView alloc] initWithFrame:self.titleScrollView.frame];

		titleView.frame = CGRectMake(0.0f,
																 0.0f,
																 self.titleScrollView.frame.size.width,
																 self.titleScrollView.frame.size.height + kPageControlTopMargin + kPageControlHeight);

		self.pageControl.frame = CGRectMake(0.0f,
																				self.titleScrollView.frame.size.height + kPageControlTopMargin,
																				titleView.frame.size.width,
																				kPageControlHeight);

		[titleView addSubview:_titleScrollView];
		[titleView addSubview:self.pageControl];

		titleView.userInteractionEnabled = NO;
		_titleView = titleView;
	}
	return _titleView;
}

#pragma mark - Helper method

- (NSInteger)pageOfViewController:(UIViewController *)viewController {
	for (NSNumber * currentPage in [self.cachedViewControllers allKeys]) {
		UIViewController * currentViewController = self.cachedViewControllers[currentPage];
		if (viewController == currentViewController) {
			return [currentPage integerValue];
		}
	}
	return NSNotFound;
}

- (void)updateTitleViewPosition {
	CGFloat position = [self currentPosition];
	[self.titleScrollView setContentOffset:CGPointMake(position * self.titleView.frame.size.width, 0.0f)];

	[self updateTitleViewAlphaWithPosition:position];
}

- (void)updateTitleViewAlphaWithPosition:(CGFloat)position {
	CGFloat (^ calculateProgress)(CGFloat, CGFloat) = ^CGFloat(CGFloat origin, CGFloat offset) {
		offset -= origin;
		offset  = (CGFloat)fabs(offset);
		// Linear function
		CGFloat a = (1.0f - kTitleViewMinimumAlpha) / (0.0f - 0.5f);
		CGFloat b = 1.0f - a * 0.0f;
		offset = a * offset + b;
		if (offset < kTitleViewMinimumAlpha) {
			return kTitleViewMinimumAlpha;
		} else if (offset > 1.0f) {
			return 1.0f;
		}
		return offset;
	};

	NSUInteger count = [self.titleLabels count];
	for(NSUInteger i = 0; i < count; ++i) {
		[self.titleLabels[i] setAlpha:calculateProgress(i * 1.0f, position)];
	}
}

- (CGFloat)currentPosition {
	NSUInteger offset = 0;
	UIViewController *firstVisibleViewController;
	while ([(firstVisibleViewController = [self viewControllerForPage:offset]).view superview] == nil) {
		++offset;
	}
	CGRect rect = [[firstVisibleViewController.view superview] convertRect:firstVisibleViewController.view.frame fromView:self.view];
	rect.origin.x /= self.view.frame.size.width;
	rect.origin.x += (CGFloat)offset;
	return rect.origin.x;
}

@end
