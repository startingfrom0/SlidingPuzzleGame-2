//
//  GamesListTVC.m
//  GameHouse
//
//  Created by Alex Smith on 13/06/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "GamesListTVC.h"
#import "PreviousGameCell.h"
#import "SlidingPuzzleGame.h"
#import "PuzzleGameVC.h"
#import "ObjectDatabase.h"

@interface GamesListTVC () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UISegmentedControl *completedGamesToggle;
@property (strong, nonatomic) NSArray *completeGames;
@property (strong, nonatomic) NSArray *incompleteGames;
@property (strong, nonatomic) NSArray *gamesForTable;

@end

@implementation GamesListTVC

#define CELL_IDENTIFIER @"PreviousGameCell"

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [PreviousGameCell cellHeight];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SlidingPuzzleGame *game = self.gamesForTable[indexPath.row];
    
    if (!game.solved) {
        PuzzleGameVC *gameVC = [[PuzzleGameVC alloc] init];
        [gameVC setupFromPreviousGame:game];
        [self.navigationController pushViewController:gameVC animated:YES];
    }
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.gamesForTable count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PreviousGameCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    SlidingPuzzleGame *game = self.gamesForTable[indexPath.row];

    cell.rankLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[self.gamesForTable indexOfObject:game] + 1];
        
    cell.image.image = [UIImage imageNamed:game.imageName];
    cell.mainLabel.text = [NSString stringWithFormat:@"%lu moves", (unsigned long)game.numberOfMovesMade];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    cell.subLabel.text = [dateFormatter stringFromDate:game.datePlayed];
    
    return cell;
}

#pragma mark - Actions

-(void)toggleGameType:(UISegmentedControl *)control
{
    [self.tableView reloadData];
}

#pragma mark - Properties

-(NSArray *)gamesForTable
{
    return self.completedGamesToggle.selectedSegmentIndex == 0 ?
                    [self.incompleteGames copy]: [self.completeGames copy];
}

-(UISegmentedControl *)completedGamesToggle
{
    if (!_completedGamesToggle) {
        _completedGamesToggle = [[UISegmentedControl alloc]
                                        initWithItems:@[@"Incomplete", @"Complete"]];
        _completedGamesToggle.selectedSegmentIndex = 0;
        [_completedGamesToggle addTarget:self
                                  action:@selector(toggleGameType:)
                        forControlEvents:UIControlEventValueChanged];
    }
    
    return _completedGamesToggle;
}

-(NSArray *)completeGames
{
    if (!_completeGames) {
        _completeGames = [NSArray array];
    }
    
    return _completeGames;
}

-(NSArray *)incompleteGames
{
    if (!_incompleteGames) {
        _incompleteGames = [NSArray array];
    }
    
    return _incompleteGames;
}

#pragma mark - View Life Cycle

-(void)back:(UIBarButtonItem *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UINib *nib = [UINib nibWithNibName:CELL_IDENTIFIER bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CELL_IDENTIFIER];
    
    self.navigationItem.titleView = self.completedGamesToggle;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(back:)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // reload the data if we have loaded an old game and the data has changed
    [self transformData];
    [self.tableView reloadData];
}

#pragma mark - Other

-(NSArray *)sortedGamesByNumMovesWithGames:(NSArray *)games
{
    return [games sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        SlidingPuzzleGame *game1 = (SlidingPuzzleGame *)obj1;
        SlidingPuzzleGame *game2 = (SlidingPuzzleGame *)obj2;
        
        if (game1.numberOfMovesMade > game2.numberOfMovesMade) {
            return NSOrderedDescending;
        } else if (game1.numberOfMovesMade < game2.numberOfMovesMade) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
        
        //return game1.numberOfMovesMade > game2.numberOfMovesMade;
        
    }];
}

-(NSArray *)sortedGamesByDateWithGames:(NSArray *)games
{
     return [games sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        SlidingPuzzleGame *game1 = (SlidingPuzzleGame *)obj1;
        SlidingPuzzleGame *game2 = (SlidingPuzzleGame *)obj2;
        return [game2.datePlayed compare:game1.datePlayed];
    }];
}


-(void)transformData
{
    NSMutableArray *completeGamesTemp = [NSMutableArray array];
    NSMutableArray *incompleteGamesTemp = [NSMutableArray array];
    
    // split the games up by complete and incomplete
    for (SlidingPuzzleGame *game in self.games) {
        game.solved ? [completeGamesTemp addObject:game] : [incompleteGamesTemp addObject:game];
        /*if (game.solved) {
            [completeGamesTemp addObject:game];
        } else {
            [incompleteGamesTemp addObject:game];
        }*/
    }
    
    self.completeGames = [self sortedGamesByNumMovesWithGames:completeGamesTemp];
    self.incompleteGames = [self sortedGamesByDateWithGames:incompleteGamesTemp];
}

@end
