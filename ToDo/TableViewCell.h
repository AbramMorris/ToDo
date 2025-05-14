//
//  TableViewCell.h
//  ToDo
//
//  Created by abram on 07/05/2025.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleview;
@property (weak, nonatomic) IBOutlet UILabel *descriptionView;
@property (weak, nonatomic) IBOutlet UILabel *dateView;
@property (weak, nonatomic) IBOutlet UIImageView *imageVieww;
- (void)configureWithTitle:(NSString *)title
              description:(NSString *)description
                     date:(NSDate *)date
                   image:(UIImage * _Nullable)image;

- (void)configureWithTitle:(NSString *)title
              description:(NSString *)description
                dateString:(NSString *)dateString
                   image:(UIImage * _Nullable)image;

+ (CGFloat)heightForCellWithTitle:(NSString *)title
                     description:(NSString *)description
                      tableWidth:(CGFloat)tableWidth;
@end

NS_ASSUME_NONNULL_END
