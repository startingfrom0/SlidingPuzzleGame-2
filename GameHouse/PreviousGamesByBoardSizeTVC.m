//
//  PreviousGamesByBoardSizeTVC.m
//  GameHouse
//
//  Created by Alex Smith on 13/06/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "PreviousGamesByBoardSizeTVC.h"
#import "PuzzleGame.h"
#import "GamesListTVC.h"

@interface PreviousGamesByBoardSizeTVC ()

@end

@implementation PreviousGamesByBoardSizeTVC

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GamesListTVC *gamesList = [[GamesListTVC alloc] init];
    gamesList.games = [self gamesForRow:(int)indexPath.row];
    [self.navigationController pushViewController:gamesList animated:YES];
}

#pragma mark - Concrete Implementation of Abstract Methods

-(NSString *)stringToPivotGame:(PuzzleGame *)game
{
    return [game.board boardSizeStringFromNumTiles];
}

-(NSString *)headerForTable
{
    return @"Board Size";
}

@end