//
//  ViewController.m
//  ToDo
//
//  Created by abram on 07/05/2025.
//

#import "ViewController.h"
#import "TaskPojo.h"
#import "AddTaskViewController.h"
#import "EditViewController.h"
#import "TableViewCell.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property NSMutableArray<TaskPojo *> *allTasks;
@property NSMutableArray<TaskPojo *> *tasks;
@property NSMutableArray<TaskPojo *> *filtered;
@property IBOutlet UITableView *tableView;
@property BOOL isFiltered;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isFiltered = false;

    self.searchBar.delegate = self;
    [self setupTableView];

    UIImage *image = [UIImage systemImageNamed:@"plus"];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(doneTapped)];
    self.navigationItem.rightBarButtonItem = rightButton;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNewTask:)
                                                 name:@"TaskAddedNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUpdatedTask:)
                                                 name:@"TaskUpdatedNotification"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadTasks];
}

- (void)setupTableView {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.allowsSelection = YES;
    [self.tableView registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:@"tabelCell"];
}

- (void)loadTasks {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedTasks"];
    if (data) {
        NSSet *classes = [NSSet setWithArray:@[NSArray.class, TaskPojo.class]];
        self.allTasks = [[NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:data error:nil] mutableCopy];
    }
    if (!self.allTasks) {
        self.allTasks = [NSMutableArray array];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(TaskPojo *task, NSDictionary *bindings) {
        return task.status == TaskStatusTodo;
    }];
    self.tasks = [[self.allTasks filteredArrayUsingPredicate:predicate] mutableCopy];
    
    [self.tableView reloadData];
}

- (void)handleNewTask:(NSNotification *)notification {
    [self loadTasks];
}

- (void)handleUpdatedTask:(NSNotification *)notification {
    [self loadTasks];
    
    NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:self.allTasks
                                                requiringSecureCoding:YES
                                                                error:nil];
    [[NSUserDefaults standardUserDefaults] setObject:encodedData forKey:@"savedTasks"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        _isFiltered = false;
        _filtered = nil;
    } else {
        _isFiltered = true;
        _filtered = [NSMutableArray new];
        for (TaskPojo *task in _tasks) {
            if ([task.title rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [_filtered addObject:task];
            }
        }
    }
    [self.tableView reloadData];
}

- (void)doneTapped {
    AddTaskViewController *add = [self.storyboard instantiateViewControllerWithIdentifier:@"addtask"];
    [self presentViewController:add animated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 120; 
//}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sourceArray = _isFiltered ? _filtered : _tasks;
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(TaskPojo *task, NSDictionary *bindings) {
        return task.priority == section;
    }];
    return [[sourceArray filteredArrayUsingPredicate:predicate] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case TaskPriorityLow: return @"Low Priority";
        case TaskPriorityMedium: return @"Medium Priority";
        case TaskPriorityHigh: return @"High Priority";
        default: return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tabelCell" forIndexPath:indexPath];

    NSArray *sourceArray = _isFiltered ? _filtered : _tasks;
    NSMutableArray *sectionTasks = [NSMutableArray array];
    
    for (TaskPojo *task in sourceArray) {
        if (task.priority == indexPath.section) {
            [sectionTasks addObject:task];
        }
    }

    TaskPojo *task = sectionTasks[indexPath.row];

    [cell configureWithTitle:task.title
                  description:task.taskDescription
                         date:task.startDate
                        image:[self priorityImageForTask:task]];
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sourceArray = _isFiltered ? _filtered : _tasks;
    NSMutableArray *sectionTasks = [NSMutableArray array];

    for (TaskPojo *task in sourceArray) {
        if (task.priority == indexPath.section) {
            [sectionTasks addObject:task];
        }
    }

    TaskPojo *task = sectionTasks[indexPath.row];

    EditViewController *eVC = [self.storyboard instantiateViewControllerWithIdentifier:@"edit"];
    eVC.taskToEdit = task;
    [self.navigationController pushViewController:eVC animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Task"
                                                                       message:@"Are you sure you want to delete this task?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete"
                                                               style:UIAlertActionStyleDestructive
                                                             handler:^(UIAlertAction * _Nonnull action) {
            NSArray *sourceArray = self->_isFiltered ? self->_filtered : self->_tasks;
            NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(TaskPojo *task, NSDictionary *bindings) {
                return task.priority == indexPath.section;
            }];
            NSArray *filteredTasks = [sourceArray filteredArrayUsingPredicate:predicate];
            TaskPojo *taskToDelete = filteredTasks[indexPath.row];
            
            [self.allTasks removeObject:taskToDelete];
            [self.tasks removeObject:taskToDelete];
            if (self->_isFiltered) {
                [self.filtered removeObject:taskToDelete];
            }

            NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:self.allTasks
                                                        requiringSecureCoding:YES
                                                                        error:nil];
            [[NSUserDefaults standardUserDefaults] setObject:encodedData forKey:@"savedTasks"];
            [self.tableView reloadData];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        [alert addAction:deleteAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (UIImage *)priorityImageForTask:(TaskPojo *)task {
    if (task.priority == TaskPriorityLow) {
        return [UIImage imageNamed:@"less"];
    } else if (task.priority == TaskPriorityMedium) {
        return [UIImage imageNamed:@"mid"];
    } else {
        return [UIImage imageNamed:@"imp"];
    }
}

@end
