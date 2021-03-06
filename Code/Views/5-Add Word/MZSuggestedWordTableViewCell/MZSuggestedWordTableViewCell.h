//
//  MZSuggestedWordTableViewCell.h
//  Memz
//
//  Created by Bastien Falcou on 12/25/15.
//  Copyright © 2015 Falcou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZTableViewCell.h"

@interface MZSuggestedWordTableViewCell : MZTableViewCell

@property (nonatomic, strong) IBOutlet UILabel *suggestedWordLabel;

@property (nonatomic, assign) MZLanguage language;

@end
