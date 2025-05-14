//
//  TaskPojo.h
//  ToDo
//
//  Created by abram on 07/05/2025.
//
// TaskPojo.h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TaskPriority) {
    TaskPriorityLow,
    TaskPriorityMedium,
    TaskPriorityHigh
};

typedef NS_ENUM(NSInteger, TaskStatus) {
    TaskStatusTodo,
    TaskStatusInProgress,
    TaskStatusDone
};

@interface TaskPojo : NSObject <NSSecureCoding>

@property (nonatomic, strong) NSString *taskID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *taskDescription;
@property (nonatomic) TaskPriority priority;
@property (nonatomic) TaskStatus status;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *reminderDate;

- (instancetype)initWithTitle:(NSString *)title
              taskDescription:(NSString *)description
                     priority:(TaskPriority)priority
                       status:(TaskStatus)status
                    startDate:(NSDate *)startDate
                 reminderDate:(NSDate *)reminderDate;

@end
