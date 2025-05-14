//
//  TaskPojo.m
//  ToDo
//
//  Created by abram on 07/05/2025.
//

// TaskPojo.m

#import "TaskPojo.h"

@implementation TaskPojo

- (instancetype)initWithTitle:(NSString *)title
              taskDescription:(NSString *)description
                     priority:(TaskPriority)priority
                       status:(TaskStatus)status
                    startDate:(NSDate *)startDate
                 reminderDate:(NSDate *)reminderDate {
    self = [super init];
    if (self) {
        self.taskID = [[NSUUID UUID] UUIDString];
        self.title = title;
        self.taskDescription = description;
        self.priority = priority;
        self.status = status;
        self.startDate = startDate;
        self.reminderDate = reminderDate;
    }
    return self;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.taskID forKey:@"taskID"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.taskDescription forKey:@"taskDescription"];
    [coder encodeInteger:self.priority forKey:@"priority"];
    [coder encodeInteger:self.status forKey:@"status"];
    [coder encodeObject:self.startDate forKey:@"startDate"];
    [coder encodeObject:self.reminderDate forKey:@"reminderDate"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.taskID = [coder decodeObjectOfClass:[NSString class] forKey:@"taskID"];
        self.title = [coder decodeObjectOfClass:[NSString class] forKey:@"title"];
        self.taskDescription = [coder decodeObjectOfClass:[NSString class] forKey:@"taskDescription"];
        self.priority = [coder decodeIntegerForKey:@"priority"];
        self.status = [coder decodeIntegerForKey:@"status"];
        self.startDate = [coder decodeObjectOfClass:[NSDate class] forKey:@"startDate"];
        self.reminderDate = [coder decodeObjectOfClass:[NSDate class] forKey:@"reminderDate"];
    }
    return self;
}

@end
