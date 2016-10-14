//
//  WMAlbumsController.m
//  WMCamera
//
//  Created by leon on 11/23/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import "WMAlbumsController.h"
#import "WMAlbumCell.h"


static NSString *kAlbumCellId   = @"WMAlbumCell";

@interface WMAlbumsController ()
{
    @private
    IBOutlet UITableView                *_tableView;
}

@end

@implementation WMAlbumsController
- (id)init {
    if(self = [super initWithNibName:NSStringFromClass([self class])
                              bundle:[NSBundle bundleForClass:[self class]]]) {

    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configTableView];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    [_tableView reloadData];
}

#pragma mark - Private

- (void)configTableView {
    self.view.backgroundColor = [UIColor clearColor];
    
    UINib *nib = [UINib nibWithNibName:kAlbumCellId bundle:[NSBundle bundleForClass:[self class]]];
    [_tableView registerNib:nib forCellReuseIdentifier:kAlbumCellId];
    _tableView.separatorColor   = [UIColor colorWithRed:62.f/255.f green:62.f/255.f blue:62.f/255.f alpha:1.0];
    _tableView.tableFooterView  = [UIView new];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_albums count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WMAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:kAlbumCellId];
    if(indexPath.row < [_albums count]) {
        ALAssetsGroup *group = _albums[indexPath.row];
        [cell configWithAssetGroup:group];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_delegate && [_delegate respondsToSelector:@selector(albumsController:didSelectedIndexPath:)]) {
        [_delegate albumsController:self didSelectedIndexPath:indexPath];
    }
}

@end
