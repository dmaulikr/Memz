//
//  MZArticleDetailsTableViewCell.h
//  Memz
//
//  Created by Bastien Falcou on 3/6/16.
//  Copyright © 2016 Falcou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MZArticleDetailsTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *sourceLabel;

@end