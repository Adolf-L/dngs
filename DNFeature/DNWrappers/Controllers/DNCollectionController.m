/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNCollectionController.m
 *
 * Description  : DNCollectionController
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/2/22, Create the file
 *****************************************************************************************
 **/

#import "DNCollectionController.h"
#import "DNCollectInfoCell.h"

@interface DNCollectionController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *collectionBtn;
@property (weak, nonatomic) IBOutlet UIButton *historyBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineLeading;
@property (weak, nonatomic) IBOutlet UITableView *collectionTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarToping;

@property (nonatomic, strong) NSMutableArray* collectionArray;

@end

@implementation DNCollectionController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBarHidden = YES;    
    self.collectionArray = [NSMutableArray array];
    NSArray* tmpArray = [[NSUserDefaults standardUserDefaults] objectForKey:kCoordCollection];
    if (tmpArray && [tmpArray isKindOfClass:[NSArray class]] && tmpArray.count>0) {
        self.collectionArray = [[NSMutableArray alloc] initWithArray:tmpArray];
    }
    self.collectionBtn.selected = YES;
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    
    if (@available(iOS 11, *)) {
        UIEdgeInsets safeEdge = self.view.safeAreaInsets;
        self.navBarToping.constant = safeEdge.top;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

#pragma mark - Actions

- (IBAction)actionBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showCollection:(UIButton *)sender
{
    self.historyBtn.selected = NO;
    self.collectionBtn.selected = YES;

    [UIView animateWithDuration:0.3 animations:^{
        self.bottomLineLeading.constant = 0;
        [self.view layoutIfNeeded];
    }];
    
    [self.collectionArray removeAllObjects];
    NSArray* tmpArray = [[NSUserDefaults standardUserDefaults] objectForKey:kCoordCollection];
    if (tmpArray && [tmpArray isKindOfClass:[NSArray class]] && tmpArray.count>0) {
        self.collectionArray = [[NSMutableArray alloc] initWithArray:tmpArray];
    }
    [self.collectionTable reloadData];
}

- (IBAction)showHistoryRecord:(UIButton *)sender
{
    self.historyBtn.selected = YES;
    self.collectionBtn.selected = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.bottomLineLeading.constant = [UIScreen mainScreen].bounds.size.width/2;
        [self.view layoutIfNeeded];
    }];
    
    [self.collectionArray removeAllObjects];
    NSArray* tmpArray = [[NSUserDefaults standardUserDefaults] objectForKey:kHookedCoordCollection];
    if (tmpArray && [tmpArray isKindOfClass:[NSArray class]] && tmpArray.count>0) {
        self.collectionArray = [[NSMutableArray alloc] initWithArray:tmpArray];
    }
    [self.collectionTable reloadData];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.collectionArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"DNCollectInfoCellIden";
    
    NSDictionary* infoDic = [self.collectionArray objectAtIndex:indexPath.row];
    DNCollectInfoCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        UINib* nib = [UINib nibWithNibName:@"DNCollectInfoCell" bundle:nil];
        cell = [nib instantiateWithOwner:nil options:nil].lastObject;
        [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.collectionBtn.hidden = self.collectionBtn.selected;
    [cell configWithInfo:infoDic];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* infoDic = [self.collectionArray objectAtIndex:indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:SelectCollectionPoint
                                                        object:nil
                                                      userInfo:infoDic];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.collectionArray removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
        if (self.collectionBtn.selected) {
            [[NSUserDefaults standardUserDefaults] setObject:self.collectionArray forKey:kCoordCollection];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:self.collectionArray forKey:kHookedCoordCollection];
        }
    }
}

@end
