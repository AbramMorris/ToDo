//
//  EditViewCnotrollerViewController.h
//  ToDo
//
//  Created by abram on 07/05/2025.
//

#import <UIKit/UIKit.h>
#import "TaskPojo.h"

@interface EditViewController : UIViewController

@property (nonatomic, strong) TaskPojo *taskToEdit;
@property (nonatomic, strong) NSMutableArray<TaskPojo*> *arr;

@end
