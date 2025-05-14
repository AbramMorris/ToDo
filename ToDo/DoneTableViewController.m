//
//  DoneTableViewController.m
//  ToDo
//
//  Created by abram on 07/05/2025.
//

#import "DoneTableViewController.h"
#import "TaskPojo.h"
#import "TableViewCell.h"
#import "EditViewController.h"

@interface DoneTableViewController () <UITableViewDelegate, UITableViewDataSource>

@property NSMutableArray<TaskPojo *> *tasks;
@property (nonatomic) BOOL isSorted;

@end

@implementation DoneTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Done Tasks";
    [self.tableView registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil]
         forCellReuseIdentifier:@"tabelCell"];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.isSorted = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithTitle:@"Unsort"
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
        NSPredicate *donePredicate = [NSPredicate predicateWithBlock:^BOOL(TaskPojo *task, NSDictionary *bindings) {
            return task.status == TaskStatusDone;
        }];
        self.tasks = [[allTasks filteredArrayUsingPredicate:donePredicate] mutableCopy];
    } else {
        self.tasks = [NSMutableArray array];
    }
    [self.tableView reloadData];
}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.isSorted ? 3 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(TaskPojo *task, NSDictionary *bindings) {
        return task.status == TaskStatusDone && (self.isSorted ? task.priority == section : YES);
    }];
    return [[self.tasks filteredArrayUsingPredicate:predicate] count];
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

- (NSArray<TaskPojo *> *)filteredTasksForSection:(NSInteger)section {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(TaskPojo *task, NSDictionary *bindings) {
        return task.status == TaskStatusDone && (self.isSorted ? task.priority == section : YES);
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
                [self.tasks removeObject:taskToDelete];
                [self.tableView reloadData];
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
