#import "EditViewController.h"
#import "TaskPojo.h"
#import <UserNotifications/UserNotifications.h>

@interface EditViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleEdit;
@property (weak, nonatomic) IBOutlet UITextView *descEdit;
@property (weak, nonatomic) IBOutlet UISegmentedControl *priorityEdit;
@property (weak, nonatomic) IBOutlet UISegmentedControl *statuesEdit;
@property (weak, nonatomic) IBOutlet UIDatePicker *reminderPicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UIButton *editbutton;
@property (strong, nonatomic) NSArray<NSString *> *statusTitles;
@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.statusTitles = @[@"To Do", @"In Progress", @"Done"];
    
    NSDate *currentDate = [NSDate date];
    self.startDatePicker.minimumDate = currentDate;
    self.reminderPicker.minimumDate = currentDate;
    [self.statuesEdit removeAllSegments];
    if(self.taskToEdit.status ==TaskStatusDone){
        self.titleEdit.enabled=NO;
        self.descEdit.userInteractionEnabled=NO;
        self.priorityEdit.enabled=NO;
        self.statuesEdit.enabled=NO;
        self.editbutton.hidden=YES;
    }
    if (self.taskToEdit) {
        self.titleEdit.text = self.taskToEdit.title;
        self.descEdit.text = self.taskToEdit.taskDescription;
        self.priorityEdit.selectedSegmentIndex = self.taskToEdit.priority;
        self.startDatePicker.date = self.taskToEdit.startDate;
        self.reminderPicker.date = self.taskToEdit.reminderDate;
        [self setupStatusSegments:self.taskToEdit.status];
    } else {
        [self setupStatusSegments:0];
    }
}

- (void)setupStatusSegments:(NSInteger)currentStatus {
    [self.statuesEdit removeAllSegments];
    
    for (NSInteger i = currentStatus; i < self.statusTitles.count; i++) {
        [self.statuesEdit insertSegmentWithTitle:self.statusTitles[i] atIndex:self.statuesEdit.numberOfSegments animated:NO];
    }

    self.statuesEdit.selectedSegmentIndex = 0;
}

- (IBAction)saveButtonTapped:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm Edit"
                                                                   message:@"Are you sure you want to edit this task?"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        
//        if ([self isStringEmptyOrWhitespace:self.titleEdit.text] && [self isStringEmptyOrWhitespace:self.descEdit.text]) {
//            [self alertForEmptyTitleOrDescription];\
//            return;
//        }
        if(self.titleEdit.text.length==0|| self.descEdit.text.length==0){
            [self alertForEmptyTitleOrDescription];
            return;
        }
        
        self.taskToEdit.title = self.titleEdit.text;
        self.taskToEdit.taskDescription = self.descEdit.text;
        self.taskToEdit.priority = self.priorityEdit.selectedSegmentIndex;
        self.taskToEdit.startDate = self.startDatePicker.date;
        self.taskToEdit.reminderDate = self.reminderPicker.date;

        self.taskToEdit.status = self.statuesEdit.selectedSegmentIndex + (3 - self.statuesEdit.numberOfSegments);

        [self saveTasks];

        if (self.taskToEdit.reminderDate) {
            [self updateNotificationForTask:self.taskToEdit];
        }

        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];

    [alert addAction:yesAction];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];
}

//- (BOOL)isStringEmptyOrWhitespace:(NSString *)string {
//    if (string == nil || [string isEqualToString:@""]) {
//        return YES;
//    }
//    NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
//    return [[string stringByTrimmingCharactersInSet:whitespaceSet] length] == 0;
//}

- (void)alertForEmptyTitleOrDescription {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing Task Details"
                                                                   message:@"Title or description is missing. Please update the task details!"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];

    [alert addAction:okAction];

    [self presentViewController:alert animated:YES completion:nil];
}


- (void)statusSegmentChanged:(UISegmentedControl *)sender {
    NSInteger globalSelectedStatus = sender.selectedSegmentIndex + (3 - sender.numberOfSegments);
    [self setupStatusSegments:globalSelectedStatus];
}

- (void)saveTasks {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedTasks"];
    NSMutableArray<TaskPojo *> *allTasks = [NSMutableArray array];
    
    if (data) {
        NSSet *classes = [NSSet setWithObjects:[NSArray class], [TaskPojo class], nil];
        allTasks = [[NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:data error:nil] mutableCopy];
    }

    for (int i = 0; i < allTasks.count; i++) {
        TaskPojo *task = allTasks[i];
        if ([task.taskID isEqualToString:self.taskToEdit.taskID]) {
            allTasks[i] = self.taskToEdit;
            break;
        }
    }

    [allTasks sortUsingComparator:^NSComparisonResult(TaskPojo *task1, TaskPojo *task2) {
        if (task1.priority > task2.priority) {
            return NSOrderedAscending;
        } else if (task1.priority < task2.priority) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];

    NSError *error = nil;
    NSData *updatedData = [NSKeyedArchiver archivedDataWithRootObject:allTasks requiringSecureCoding:YES error:&error];
    
    if (!error) {
        [[NSUserDefaults standardUserDefaults] setObject:updatedData forKey:@"savedTasks"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        NSLog(@"Error saving updated tasks: %@", error.localizedDescription);
    }
}

- (void)updateNotificationForTask:(TaskPojo *)task {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center removePendingNotificationRequestsWithIdentifiers:@[task.taskID]];

    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = task.title;
    content.body = task.taskDescription.length > 0 ? task.taskDescription : @"You have a task reminder!";
    content.sound = [UNNotificationSound defaultSound];

    NSDateComponents *triggerDate = [[NSCalendar currentCalendar] components:NSCalendarUnitYear |
                                    NSCalendarUnitMonth |
                                    NSCalendarUnitDay |
                                    NSCalendarUnitHour |
                                    NSCalendarUnitMinute fromDate:task.reminderDate];
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:triggerDate repeats:NO];

    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:task.taskID
                                                                          content:content
                                                                          trigger:trigger];

    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error updating notification: %@", error.localizedDescription);
        } else {
            NSLog(@"Notification updated successfully.");
        }
    }];
}

@end
