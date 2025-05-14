//
//  TableViewCell.m
//  ToDo
//
//  Created by abram on 07/05/2025.
//

#import "TableViewCell.h"

@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupCellAppearance];
}

- (void)setupCellAppearance {
    
    self.descriptionView.font = [UIFont systemFontOfSize:14];
    self.descriptionView.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];
    self.descriptionView.numberOfLines = 0;
    
    self.dateView.font = [UIFont systemFontOfSize:12];
    self.dateView.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
    
    self.imageVieww.contentMode = UIViewContentModeScaleAspectFill;
    self.imageVieww.layer.cornerRadius = 4.0;
    self.imageVieww.clipsToBounds = YES;
    self.imageVieww.layer.borderWidth = 0.5;
    self.imageVieww.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
}


- (void)configureWithTitle:(NSString *)title
              description:(NSString *)description
                     date:(NSDate *)date
                   image:(UIImage * _Nullable)image {
    
    self.titleview.text = title;
    self.descriptionView.text = description;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, yyyy h:mm a"];
    self.dateView.text = [formatter stringFromDate:date];
    
    [self configureImageViewWithImage:image];
}

- (void)configureWithTitle:(NSString *)title
              description:(NSString *)description
                dateString:(NSString *)dateString
                   image:(UIImage * _Nullable)image {
    
    self.titleview.text = title;
    self.descriptionView.text = description;
    self.dateView.text = dateString;
    
    [self configureImageViewWithImage:image];
}

- (void)configureImageViewWithImage:(UIImage *)image {
    if (image) {
        self.imageVieww.image = image;
        self.imageVieww.hidden = NO;
    } else {
        self.imageVieww.image = nil;
        self.imageVieww.hidden = YES;
    }
}


+ (CGFloat)heightForCellWithTitle:(NSString *)title
                     description:(NSString *)description
                      tableWidth:(CGFloat)tableWidth {
    
    static TableViewCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [[[NSBundle mainBundle] loadNibNamed:@"TableViewCell" owner:nil options:nil] firstObject];
    });
    
    [sizingCell configureWithTitle:title description:description dateString:@"Sample date" image:nil];
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.titleview.text = nil;
    self.descriptionView.text = nil;
    self.dateView.text = nil;
    self.imageVieww.image = nil;
    self.imageVieww.hidden = YES;
}

@end
