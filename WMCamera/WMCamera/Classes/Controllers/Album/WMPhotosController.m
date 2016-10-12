//
//  WMPhotosController.m
//  WMCamera
//
//  Created by leon on 11/6/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "WMPhotosController.h"
#import "WMAlbumsController.h"
#import "WMCameraViewController.h"
#import "WMPhotoCell.h"
#import "WMAlbumSelectionView.h"
#import "WMAlbumView.h"
#import "WMNavigationBarView.h"
#import "WMAlbumUtils.h"
#import "WMKeyConsts.h"
#import "ALAsset+Utils.h"

NSString * const kPhotoCellReuseId          = @"WMPhotoCell";

static NSUInteger   kColumns                = 4;
static CGFloat      kSpace                  = 1.0;
static CGFloat      kInset                  = 1.0;

@interface WMPhotosController ()<UICollectionViewDataSource, UICollectionViewDelegate, WMAlbumViewDelegate>
{
    @private
    UICollectionView                        *_collectionView;
    
    ALAssetsGroup                           *_selectedGroup;
    NSArray                                 *_assetGroups;
    NSMutableArray                          *_muAssets;
    NSMutableArray                          *_muSelectedAssets;
}
@property (nonatomic, weak) WMNavigationBarView             *navigationBarView;
@property (nonatomic, weak) WMAlbumSelectionView            *albumSelectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout    *photoLayout;
@property (nonatomic, strong) WMAlbumView                   *albumView;

@property (nonatomic, strong) NSString                      *userLastestAlbumName;

@end

@implementation WMPhotosController
@synthesize userLastestAlbumName = _userLastestAlbumName;

- (id)init {
    if(self = [super init]) {
        [self commonInit];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configViews];
    [self initAlbum];
    [self refreshConfirmBtnState];
}

#pragma mark - Getter / Setter

- (NSString *)userLastestAlbumName {
    if(!_userLastestAlbumName) {
        _userLastestAlbumName = [[NSUserDefaults standardUserDefaults] objectForKey:kUserLastestAlbumNameKey];
    }
    return _userLastestAlbumName;
}

- (void)setUserLastestAlbumName:(NSString *)userLastestAlbumName {
    _userLastestAlbumName = userLastestAlbumName;
    
    if(!_userLastestAlbumName) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:_userLastestAlbumName forKey:kUserLastestAlbumNameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (WMAlbumView *)albumView {
    if(!_albumView) {
        _albumView          = [WMAlbumView albumView];
        _albumView.delegate = self;
    }
    
    return _albumView;
}

- (UICollectionViewFlowLayout *)photoLayout {
    if(!_photoLayout) {
        _photoLayout                         = [[UICollectionViewFlowLayout alloc] init];
        _photoLayout.minimumInteritemSpacing = kInset;
        _photoLayout.minimumLineSpacing      = kSpace;
        _photoLayout.itemSize                = CGSizeMake((self.view.frame.size.width - kInset * 3) / kColumns,
                                                          (self.view.frame.size.width - kInset * 3) / kColumns);
    }
    return _photoLayout;
}

- (void)setAllowsMultipleSelectionCount:(NSUInteger)allowsMultipleSelectionCount {
    _allowsMultipleSelectionCount = allowsMultipleSelectionCount;
    [_collectionView setAllowsMultipleSelection:(allowsMultipleSelectionCount > 1)];
}

#pragma mark - Private

- (void)commonInit {
    _statusBarHidden              = NO;
    _muAssets                     = [NSMutableArray new];
    _muSelectedAssets             = [NSMutableArray new];
    _allowsMultipleSelectionCount = 1;
}

- (void)configViews {
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.view addSubview:({
        UICollectionView *collectionView            = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                                         collectionViewLayout:self.photoLayout];
        collectionView.dataSource                   = self;
        collectionView.delegate                     = self;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.backgroundColor              = [UIColor colorWithWhite:52.0f / 255.0f
                                                                        alpha:1.0f];
        
        UINib *nib = [UINib nibWithNibName:kPhotoCellReuseId bundle:nil];
        [collectionView registerNib:nib forCellWithReuseIdentifier:kPhotoCellReuseId];
        [collectionView setAllowsMultipleSelection:(_allowsMultipleSelectionCount > 1)];
        
        _collectionView                  = collectionView;
    })];
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.and.bottom.equalTo(self.view);
    }];
    
    [self.view layoutIfNeeded];
    [_collectionView reloadData];


    WMNavigationBarView *navigationBarView = [[WMNavigationBarView alloc] init];
    navigationBarView.backgroundColor      = [UIColor colorWithWhite:52.0f / 255.0f
                                                               alpha:1.0f];
    [navigationBarView setLeftView:({
        UIButton *leftBtn         = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.bounds            = CGRectMake(0.0, 0.0, 60.0, 40.0);
        leftBtn.contentEdgeInsets = UIEdgeInsetsMake(0.0, -30.0, 0.0, 0.0);
        [leftBtn setImage:[UIImage imageNamed:@"btn_close_camera_normal"]
                 forState:UIControlStateNormal];
        [leftBtn setImage:[UIImage imageNamed:@"btn_close_camera_pressed"]
                 forState:UIControlStateHighlighted];
        [leftBtn addTarget:self
                    action:@selector(closeAction:)
          forControlEvents:UIControlEventTouchUpInside];
        leftBtn;
    })];
    
    [navigationBarView setTitleView:({
        WMAlbumSelectionView *albumSelectionView = [WMAlbumSelectionView albumSelectionView];
        [albumSelectionView addTarget:self
                               action:@selector(changeAlbumAction:)
                     forControlEvents:UIControlEventTouchUpInside];
        
        _albumSelectionView = albumSelectionView;
    })];
    
    [navigationBarView setRightView:({
        UIButton *rightBtn         = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.bounds            = CGRectMake(0.0, 0.0, 60.0, 40.0);
        rightBtn.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -15.0);
        [rightBtn setTitle:self.rightTitle
                  forState:UIControlStateNormal];
        [rightBtn addTarget:self
                     action:@selector(confirmAction:)
           forControlEvents:UIControlEventTouchUpInside];
        rightBtn;
    })];
    
    [self.view addSubview:navigationBarView];
    _navigationBarView = navigationBarView;
    [navigationBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.and.top.equalTo(self.view);
        make.height.mas_equalTo(44.0);
        make.bottom.equalTo(_collectionView.mas_top);
    }];
}

- (void)initAlbum {
    __block ALAssetsGroup *selectedGroup = nil;
    ALAssetsGroupType types = ALAssetsGroupAll & (~ALAssetsGroupPhotoStream);
    [WMAlbumUtils fetchGroups:types completion:^(NSArray * _Nullable groups, NSError * _Nullable error) {
        NSMutableArray *muGroups = [NSMutableArray new];
        for (ALAssetsGroup *group in groups) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            if([group numberOfAssets] == 0) {
                continue;
            }
            
            [muGroups addObject:group];
            NSString *name =[group valueForProperty:ALAssetsGroupPropertyName];
            if(self.userLastestAlbumName.length > 0) {
                if([name isEqualToString:self.userLastestAlbumName]) selectedGroup = group;
            }
            else {
                if([selectedGroup numberOfAssets] < [group numberOfAssets]) selectedGroup = group;
            }
        }
        
        if(!selectedGroup) {
            selectedGroup = [muGroups firstObject];
        }
        
        _assetGroups = [muGroups copy];
        
        self.albumView.albums = _assetGroups;
        
        [self loadPhotosFromGroup:selectedGroup];
    }];
}

- (void)loadPhotosFromGroup:(ALAssetsGroup *)group {
    [_muSelectedAssets removeAllObjects];
    [_muAssets removeAllObjects];
    [_collectionView setContentOffset:CGPointZero animated:NO];
    
    _selectedGroup              = group;
    self.userLastestAlbumName   = [group valueForProperty:ALAssetsGroupPropertyName];
    [self.albumSelectionView setAlbumName:[group valueForProperty:ALAssetsGroupPropertyName]];
    

    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    [group enumerateAssetsWithOptions:NSEnumerationReverse
                                    usingBlock:
     ^(ALAsset *asset, NSUInteger idx, BOOL *stop){
         if(asset) {
             [_muAssets addObject:asset];
         }
         else {
             *stop = YES;
         }
     }];
    
    [_collectionView reloadData];
    [self refreshConfirmBtnState];
}

- (void)showAlbumViewAnimated:(BOOL)animated {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGRect frameOnWindow = [self.view convertRect:self.navigationBarView.frame toView:window];
    CGRect toFrame = CGRectMake(0.0,
                                frameOnWindow.origin.y + frameOnWindow.size.height,
                                window.frame.size.width,
                                window.frame.size.height - frameOnWindow.size.height);
    CGRect fromFrame = CGRectMake(0.0,
                                  window.frame.size.height,
                                  window.frame.size.width,
                                  window.frame.size.height - frameOnWindow.size.height);
    
    self.albumView.frame = fromFrame;
    [window addSubview:self.albumView];
    
    void (^ block)() = ^{
        self.albumView.frame                   = toFrame;
        self.navigationBarView.leftView.alpha  = 0.0;
        self.navigationBarView.rightView.alpha = 0.0;
    };
    
    void (^ completionBlock)(BOOL finished) = ^(BOOL finished) {
        self.albumSelectionView.userInteractionEnabled = YES;
    };
    
    self.albumSelectionView.userInteractionEnabled = NO;
    if(animated) {
        [UIView animateWithDuration:0.25
                         animations:block
                         completion:completionBlock];
    }
    else {
        block();
        completionBlock(YES);
    }
    
    [_albumSelectionView rotateArrowDownAnimated:animated];
}

- (void)hideAlbumViewAnimated:(BOOL)animated {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGRect frameOnWindow = [self.view convertRect:self.navigationBarView.frame toView:window];
    CGRect toFrame = CGRectMake(0.0,
                                window.frame.size.height,
                                window.frame.size.width,
                                window.frame.size.height - frameOnWindow.size.height);
    
    void (^ block)() = ^{
        self.albumView.frame                   = toFrame;
        self.navigationBarView.leftView.alpha  = 1.0;
        self.navigationBarView.rightView.alpha = 1.0;
    };
    
    void (^ completionBlock)(BOOL finished) = ^(BOOL finished) {
        [self.albumView removeFromSuperview];
        self.albumSelectionView.userInteractionEnabled = YES;
    };
    
    self.albumSelectionView.userInteractionEnabled = NO;
    if(animated) {
        [UIView animateWithDuration:0.25
                         animations:block
                         completion:completionBlock];
    }
    else {
        block();
        completionBlock(YES);
    }
    
    [_albumSelectionView rotateArrowUpAnimated:animated];
}

- (void)refreshConfirmBtnState {
    if([_collectionView.indexPathsForSelectedItems count] == 0 || _allowsMultipleSelectionCount <= 1) {
        self.navigationBarView.rightView.hidden = YES;
    }
    else {
        self.navigationBarView.rightView.hidden = NO;
    }
}

#pragma mark - Actions

- (IBAction)closeAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeAlbumAction:(id)sender {
    if(self.albumView.superview) {
        [self hideAlbumViewAnimated:YES];
    }
    else {
        [self showAlbumViewAnimated:YES];
    }
}

- (IBAction)confirmAction:(id)sender {
    NSMutableArray *muArray = [[NSMutableArray alloc] init];
    for (NSUInteger idx = 0; idx < _muSelectedAssets.count; ++idx) {
        ALAsset *asset = [_muSelectedAssets objectAtIndex:idx];
        UIImage *image = [asset fullResolutionImage];
        [muArray addObject:image];
    }
    
    if(_delegate && [_delegate respondsToSelector:@selector(photosController:didSelectImages:)]) {
        [_delegate photosController:self didSelectImages:[muArray copy]];
    }
}

- (ALAsset *)assetWithIndexPath:(NSIndexPath *)indexPath {
    ALAsset *asset = nil;
    if(indexPath.row < [_muAssets count]) {
        asset = [_muAssets objectAtIndex:indexPath.row];
    }
    
    return asset;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_muAssets count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WMPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellReuseId
                                                                  forIndexPath:indexPath];
    if(indexPath.row < [_muAssets count]) {
        ALAsset *asset = [_muAssets objectAtIndex:indexPath.row];
        UIImage *image = [asset thumbnailImage];
        [cell setPhoto:image];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ALAsset *asset = [self assetWithIndexPath:indexPath];

    if(_allowsMultipleSelectionCount <= 1) {
        UIImage *image = [asset fullResolutionImage];
        if(image && _delegate && [_delegate respondsToSelector:@selector(photosController:didSelectImage:)]) {
            [_delegate photosController:self didSelectImage:image];
        }
    }
    else {
        if(asset)
            [_muSelectedAssets addObject:asset];
    }
    [self refreshConfirmBtnState];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(_allowsMultipleSelectionCount <= 1) {
        return NO;
    }

    if([collectionView.indexPathsForSelectedItems containsObject:indexPath]) {
        ALAsset *asset = [self assetWithIndexPath:indexPath];
        if(asset) [_muSelectedAssets removeObject:asset];
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        [self refreshConfirmBtnState];
        return NO;
    }
    
    if(_muSelectedAssets.count >= _allowsMultipleSelectionCount) {
        ALAsset *asset = [self assetWithIndexPath:indexPath];
        UIImage *image = [asset fullResolutionImage];
        if(image && _delegate && [_delegate respondsToSelector:@selector(photosController:willExceedAllowsSelectionCountWithImage:)]) {
            [_delegate photosController:self willExceedAllowsSelectionCountWithImage:image];
        }
        return NO;
    }

    return YES;
}

#pragma mark - WMAlbumViewDelegate

- (void)albumView:(WMAlbumView *)albumView didSelectedIndex:(NSUInteger)aIndex {
    if(aIndex >= _assetGroups.count) {
        return;
    }
    
    ALAssetsGroup *group = _assetGroups[aIndex];
    if(group == _selectedGroup) {
        return;
    }

    [self loadPhotosFromGroup:group];
    [self hideAlbumViewAnimated:YES];
}

@end
