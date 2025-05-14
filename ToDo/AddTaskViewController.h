//
//  AddTaskViewController.h
//  ToDo
//
//  Created by abram on 07/05/2025.
//

#import <UIKit/UIKit.h>
#import "TaskPojo.h"

@interface AddTaskViewController : UIViewController

@property (nonatomic, copy) void (^onTaskAdded)(TaskPojo *task);

@end
