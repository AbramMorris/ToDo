//
//  AddTaskViewController.m
//  ToDo
//
//  Created by abram on 07/05/2025.
//

#import "AddTaskViewController.h"
#import "TaskPojo.h"
#import <UserNotifications/UserNotifications.h>

@interface AddTaskViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *startDate;
@property (weak, nonatomic) IBOutlet UIDatePicker *reminder;
@property (weak, nonatomic) IBOutlet UISegmentedControl *priorityControl;
@property (assign, nonatomic) TaskPriority selectedPriority;

@end

@implementation AddTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Add Task";

    NSDate *currentDate = [NSDate date];
    self.startDate.minimumDate = currentDate;
    self.reminder.minimumDate = currentDate;

    self.selectedPriority = TaskPriorityLow;
    self.priorityControl.selectedSegmentIndex = self.selectedPriority;

    [self requestNotificationPermission];
}

- (void)requestNotificationPermission {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            NSLog(@"Notification permission granted.");
        } else {
            NSLog(@"Notification permission denied.");
        }
    }];
}


- (IBAction)priorityChanged:(UISegmentedControl *)sender {
    self.selectedPriority = (TaskPriority)sender.selectedSegmentIndex;
}

- (IBAction)saveTask:(id)sender {
    if (self.titleTextField.text.length == 0) {
        [self showAlertWithTitle:@"Missing Title" message:@"Please enter a task title."];
        return;
    }

    // Create task object
    TaskPojo *newTask = [[TaskPojo alloc] initWithTitle:self.titleTextField.text
                                        taskDescription:self.descriptionTextField.text
                                               priority:self.selectedPriority
                                                 status:TaskStatusTodo
                                              startDate:self.startDate.date
                                           reminderDate:self.reminder.date];

    // Save task to UserDefaults
    [self saveTaskToUserDefaults:newTask];

    // Schedule notification if reminder date is set
    if (newTask.reminderDate) {
        [self scheduleNotificationForTask:newTask];
    }

    // Post notification to notify others that a task was added
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskAddedNotification" object:newTask];

    // Dismiss the view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scheduleNotificationForTask:(TaskPojo *)task {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

    // Create notification content
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = task.title;
    content.body = task.taskDescription.length > 0 ? task.taskDescription : @"You have a task reminder!";
    content.sound = [UNNotificationSound defaultSound];

    // Create a trigger for the reminder time
    NSDateComponents *triggerDate = [[NSCalendar currentCalendar] components:NSCalendarUnitYear |
                                    NSCalendarUnitMonth |
                                    NSCalendarUnitDay |
                                    NSCalendarUnitHour |
                                    NSCalendarUnitMinute fromDate:task.reminderDate];
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:triggerDate repeats:NO];

    // Create notification request
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:task.title
                                                                          content:content
                                                                          trigger:trigger];

    // Add the request to the notification center
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error scheduling notification: %@", error.localizedDescription);
        } else {
            NSLog(@"Notification scheduled successfully.");
        }
    }];
}

- (void)saveTaskToUserDefaults:(TaskPojo *)task {
    NSMutableArray<TaskPojo *> *tasks = [[self loadTasksFromUserDefaults] mutableCopy] ?: [NSMutableArray array];
    [tasks addObject:task];

    NSError *error = nil;
    NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:tasks
                                               requiringSecureCoding:YES
                                                               error:&error];

    if (!error) {
        [[NSUserDefaults standardUserDefaults] setObject:encodedData forKey:@"savedTasks"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        NSLog(@"Error saving tasks: %@", error.localizedDescription);
    }
}

- (NSArray<TaskPojo *> *)loadTasksFromUserDefaults {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedTasks"];
    if (!data) return @[];

    NSError *error = nil;
    NSArray<TaskPojo *> *tasks = [NSKeyedUnarchiver unarchivedObjectOfClasses:
                                  [NSSet setWithObjects:[NSArray class], [TaskPojo class], nil]
                                                                     fromData:data
                                                                        error:&error];

    if (error) {
        NSLog(@"Error loading tasks: %@", error.localizedDescription);
        return @[];
    }

    return tasks ?: @[];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
