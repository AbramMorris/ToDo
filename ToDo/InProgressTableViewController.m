//
//  InProgressTableViewController.m
//  ToDo
//
//  Created by abram on 08/05/2025.
//

#import "InProgressTableViewController.h"
#import "TaskPojo.h"
#import "TableViewCell.h"
#import "EditViewController.h"

@interface InProgressTableViewController () <UITableViewDelegate, UITableViewDataSource>

@property NSMutableArray<TaskPojo *> *tasks;
@property (nonatomic) BOOL isSorted;

@end

@implementation InProgressTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"In Progress Tasks";
    [self.tableView registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:@"tabelCell"];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.isSorted = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unsort"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(toggleSort)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadTasks];
}

- (void)toggleSort {
    self.isSorted = !self.isSorted;
    self.navigationItem.rightBarButtonItem.title = self.isSorted ? @"Unsort" : @"Sort";
    [self.tableView reloadData];
}

- (void)loadTasks {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedTasks"];
    if (data) {
        NSSet *classes = [NSSet setWithArray:@[NSArray.class, TaskPojo.class]];
        NSArray *allTasks = [NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:data error:nil];
        self.tasks = [[allTasks filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TaskPojo *task, NSDictionary *bindings) {
            return task.status == TaskStatusInProgress;
        }]] mutableCopy];
    } else {
        self.tasks = [NSMutableArray array];
    }
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.isSorted ? 3 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self filteredTasksForSection:section].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (!self.isSorted) return nil;
    switch (section) {
        case TaskPriorityLow: return @"Low Priority";
        case TaskPriorityMedium: return @"Medium Priority";
        case TaskPriorityHigh: return @"High Priority";
        default: return @"";
    }
}

- (NSArray<TaskPojo *> *)filteredTasksForSection:(NSInteger)section {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(TaskPojo *task, NSDictionary *bindings) {
        return task.status == TaskStatusInProgress && (self.isSorted ? task.priority == section : YES);
    }];
    return [self.tasks filteredArrayUsingPredicate:predicate];
}

- (UIImage *)priorityImageForTask:(TaskPojo *)task {
    switch (task.priority) {
        case TaskPriorityLow: return [UIImage imageNamed:@"less"];
        case TaskPriorityMedium: return [UIImage imageNamed:@"mid"];
        case TaskPriorityHigh: return [UIImage imageNamed:@"imp"];
        default: return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tabelCell" forIndexPath:indexPath];
    
    NSArray *filtered = [self filteredTasksForSection:indexPath.section];
    if (indexPath.row < filtered.count) {
        TaskPojo *task = filtered[indexPath.row];
        [cell configureWithTitle:task.title
                     description:task.taskDescription
                            date:task.startDate
                           image:[self priorityImageForTask:task]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *filtered = [self filteredTasksForSection:indexPath.section];
    if (indexPath.row < filtered.count) {
        TaskPojo *task = filtered[indexPath.row];
        return [TableViewCell heightForCellWithTitle:task.title
                                         description:task.taskDescription
                                          tableWidth:tableView.frame.size.width];
    }
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *filtered = [self filteredTasksForSection:indexPath.section];
    if (indexPath.row < filtered.count) {
        TaskPojo *task = filtered[indexPath.row];
        EditViewController *eVC = [self.storyboard instantiateViewControllerWithIdentifier:@"edit"];
        eVC.taskToEdit = task;
        eVC.arr = _tasks;
        [self.navigationController pushViewController:eVC animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *filtered = [self filteredTasksForSection:indexPath.section];
        if (indexPath.row < filtered.count) {
            TaskPojo *taskToDelete = filtered[indexPath.row];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Task"
                                                                           message:@"Are you sure you want to delete this task?"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes"
                                                          style:UIAlertActionStyleDestructive
                                                        handler:^(UIAlertAction * _Nonnull action) {
                // Load all tasks
                NSData *savedData = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedTasks"];
                if (!savedData) return;
                
                NSSet *classes = [NSSet setWithArray:@[NSArray.class, TaskPojo.class]];
                NSMutableArray<TaskPojo *> *allTasks = [[NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:savedData error:nil] mutableCopy];
                
                // Find and remove matching task
                for (TaskPojo *task in allTasks) {
                    if ([task.title isEqualToString:taskToDelete.title] &&
                        [task.taskDescription isEqualToString:taskToDelete.taskDescription] &&
                        [task.startDate isEqualToDate:taskToDelete.startDate] &&
                        task.priority == taskToDelete.priority &&
                        task.status == taskToDelete.status) {
                        
                        [allTasks removeObject:task];
                        break;
                    }
                }
                
                // Save updated list
                NSData *updatedData = [NSKeyedArchiver archivedDataWithRootObject:allTasks requiringSecureCoding:NO error:nil];
                [[NSUserDefaults standardUserDefaults] setObject:updatedData forKey:@"savedTasks"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                // Reload filtered tasks
                [self loadTasks];
            }];
            
            UIAlertAction *no = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];
            [alert addAction:yes];
            [alert addAction:no];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

@end
