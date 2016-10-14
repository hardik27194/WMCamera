//
//  WMAlbumView.m
//  WMCamera
//
//  Created by leon on 11/23/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import "WMAlbumView.h"
#import "WMAlbumCell.h"

NSString * const kAlbumCellId   = @"WMAlbumCell";

@interface WMAlbumView ()
@property (nonatomic, weak) IBOutlet UITableView        *tableView;

@end

@implementation WMAlbumView

+ (instancetype)albumView {
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    WMAlbumView *albumView = [[bundle loadNibNamed:@"WMAlbumView"
                                                            owner:self
                                                          options:nil] firstObject];
    return albumView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configTableView];
}

#pragma mark - Setter

- (void)setAlbums:(NSArray<ALAssetsGroup *> *)albums {
    _albums = albums;
    [self.tableView reloadData];
}

#pragma mark - Private

- (void)configTableView {
    UINib *nib = [UINib nibWithNibName:kAlbumCellId bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:nib forCellReuseIdentifier:kAlbumCellId];
    self.tableView.tableFooterView  = [UIView new];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.albums count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WMAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:kAlbumCellId];
    if(indexPath.row < [self.albums count]) {
        ALAssetsGroup *group = self.albums[indexPath.row];
        [cell configWithAssetGroup:group];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_delegate && [_delegate respondsToSelector:@selector(albumView:didSelectedIndex:)]) {
        [_delegate albumView:self didSelectedIndex:indexPath.row];
    }
}

@end
