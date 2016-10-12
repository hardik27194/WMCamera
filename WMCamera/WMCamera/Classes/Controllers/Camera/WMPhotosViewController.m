//
//  WMPhotosViewController.m
//  WMImageCroper
//
//  Created by leon on 8/3/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "WMPhotosViewController.h"
#import "WMImageEditViewController.h"
#import "WMImageCropView.h"
#import "WMImageCollectionCell.h"
#import "WMNavigationBarView.h"
#import "WMAlbumSelectionView.h"
#import "WMAlbumView.h"
#import "WMCircleMaskView.h"
#import "WMAlbumUtils.h"
#import "WMKeyConsts.h"
#import "ALAsset+Utils.h"
#import "WMUIMacros.h"

NSString * const kCollectionCellIdentifier      = @"WMImageCollectionCell";

static NSUInteger   kColumns                = 4;
static CGFloat      kSpace                  = 1.0;
static CGFloat      kInset                  = 1.0;

@interface WMPhotosViewController () <UICollectionViewDataSource, UICollectionViewDelegate, WMAlbumViewDelegate>
{
    ALAssetsGroup                           *_selectedGroup;
    NSArray                                 *_assetGroups;
    NSMutableArray                          *_muAssets;
    NSUInteger                              _selectPhotoIndex;
    BOOL                                    _headerScrollable;
}
@property (nonatomic, strong) NSString                      *userLastestAlbumName;

@property (nonatomic, strong) UICollectionViewFlowLayout    *photoLayout;
@property (nonatomic, strong) WMAlbumView                   *albumView;

@property (nonatomic, weak) UICollectionView                *collectionView;
@property (nonatomic, weak) WMImageCropView                 *vImageCropView;
@property (nonatomic, weak) WMNavigationBarView             *navigationBarView;
@property (nonatomic, weak) WMAlbumSelectionView            *albumSelectionView;

@end

@implementation WMPhotosViewController
@synthesize userLastestAlbumName = _userLastestAlbumName;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
    [self initSubviews];
    [self initAlbum];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if(!parent) {
        return;
    }
    
    [self loadPhotosFromGroup:_selectedGroup];
}

- (void)commonInit {
    _selectPhotoIndex = 0;
    _headerScrollable = YES;
    _muAssets         = [[NSMutableArray alloc] init];
}

- (void)initSubviews {
    WMNavigationBarView *navigationBarView = [[WMNavigationBarView alloc] init];
    navigationBarView.backgroundColor = [UIColor colorWithWhite:52.0f / 255.0f
                                                          alpha:isIPhone4s ? 0.6f : 1.0f];
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
        rightBtn.titleLabel.font   = [UIFont systemFontOfSize:16.0];
        [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        //TODO: 处理一下
        //[rightBtn setTitleColor:[UIColor firstContentColor] forState:UIControlStateHighlighted];
        if(self.isSupportWatermarks) {
            [rightBtn setTitle:NSLocalizedString(@"Next", nil)
                      forState:UIControlStateNormal];
            [rightBtn addTarget:self
                         action:@selector(nextAction:)
               forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            [rightBtn setTitle:NSLocalizedString(@"Done", nil)
                      forState:UIControlStateNormal];
            [rightBtn addTarget:self
                         action:@selector(doneAction:)
               forControlEvents:UIControlEventTouchUpInside];
        }
        rightBtn;
    })];
    
    [self.view addSubview:navigationBarView];
    _navigationBarView = navigationBarView;
    [navigationBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.and.top.equalTo(self.view);
        make.height.mas_equalTo(44.0);
    }];
    
    [self.view addSubview:({
        UICollectionView *collectionView            = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                                         collectionViewLayout:self.photoLayout];
        collectionView.dataSource                   = self;
        collectionView.delegate                     = self;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.backgroundColor              = [UIColor colorWithWhite:52.0f / 255.0f
                                                                        alpha:1.0f];
        
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([WMImageCollectionCell class])
                                    bundle:nil];
        [collectionView registerNib:nib
         forCellWithReuseIdentifier:kCollectionCellIdentifier];
        
        _collectionView                  = collectionView;
    })];
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.and.bottom.equalTo(self.view);
        if(isIPhone4s) {
            make.top.equalTo(_navigationBarView.mas_top);
        }
        else {
            make.top.equalTo(_navigationBarView.mas_bottom);
        }
    }];
    
    [self.view layoutIfNeeded];
    [_collectionView reloadData];

    [self.view addSubview:({
        WMImageCropView *vContainer = [[WMImageCropView alloc] initWithFrame:CGRectMake(0.0,
                                                                                        _collectionView.frame.origin.y,
                                                                                        _collectionView.frame.size.width,
                                                                                        _collectionView.frame.size.width)];
        vContainer.backgroundColor  = [UIColor colorWithWhite:52.0f / 255.0f alpha:1.0f];
        _vImageCropView             = vContainer;
    })];
    
    if(_maskType == WMMaskType_Circle) {
        [_vImageCropView addSubview:({
            WMCircleMaskView *maskView = [[WMCircleMaskView alloc] initWithFrame:_vImageCropView.bounds];
            maskView;
        })];
    }
    
    [self.view bringSubviewToFront:_navigationBarView];
    _collectionView.contentInset    = UIEdgeInsetsMake(_vImageCropView.frame.size.height, 0.0, 0.0, 0.0);
}

#pragma mark - Getter

- (NSString *)userLastestAlbumName {
    if(!_userLastestAlbumName) {
        _userLastestAlbumName = [[NSUserDefaults standardUserDefaults] objectForKey:kUserLastestAlbumNameKey];
    }
    return _userLastestAlbumName;
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

- (WMAlbumView *)albumView {
    if(!_albumView) {
        _albumView          = [WMAlbumView albumView];
        _albumView.delegate = self;
    }
    
    return _albumView;
}

#pragma mark - Setter

- (void)setUserLastestAlbumName:(NSString *)userLastestAlbumName {
    _userLastestAlbumName = userLastestAlbumName;
    
    if(!_userLastestAlbumName) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:_userLastestAlbumName forKey:kUserLastestAlbumNameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Actions

- (void)closeAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)nextAction:(id)sender {
    
    //TODO: 处理一下
    //FLURRY(@"水印相机_Next");
    UIImage *cropedImage              = [_vImageCropView currentCropedImage];
    [self outputImage:cropedImage];
    
    WMImageEditViewController *editVC = [[WMImageEditViewController alloc] initWithImage:cropedImage];
    editVC.watermarks                 = self.watermarks;
    editVC.selectedWatermarkIndex     = -1;
    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)doneAction:(id)sender {
    UIImage *cropedImage              = [_vImageCropView currentCropedImage];
    [self outputFinalSynthetisedImage:cropedImage];
}

- (void)changeAlbumAction:(id)sender {
    
    //TODO: 处理一下
    //FLURRY(@"水印相机_相册_camera roll");
    if(self.albumView.superview) {
        [self hideAlbumViewAnimated:YES];
    }
    else {
        [self showAlbumViewAnimated:YES];
    }
}

#pragma mark - Private

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
    NSUInteger oldPhotoCount = _muAssets.count;
    [_muAssets removeAllObjects];
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
    
    if(_muAssets.count <= 0) {
        return;
    }
    
    if(group != _selectedGroup) {
        _selectPhotoIndex = 0;
    }
    else {
        _selectPhotoIndex += (_muAssets.count - oldPhotoCount);
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_selectPhotoIndex inSection:0];
    [_collectionView selectItemAtIndexPath:indexPath
                                  animated:NO
                            scrollPosition:UICollectionViewScrollPositionNone];
    [self makeSelectedPhotoVisibleAnimated:NO];

    CGRect frame           = _vImageCropView.frame;
    frame.origin.y         = _collectionView.frame.origin.y;
    _vImageCropView.frame  = frame;
    _vImageCropView.alpha  = 0.0;
    [self performAnimation:^{
        _vImageCropView.alpha = 1.0;
    } usingDuration:0.25];
    [self fillImageAtIndex:_selectPhotoIndex];
    
    _selectedGroup              = group;
    self.userLastestAlbumName   = [group valueForProperty:ALAssetsGroupPropertyName];
    [self.albumSelectionView setAlbumName:[group valueForProperty:ALAssetsGroupPropertyName]];
}

- (void)makeSelectedPhotoVisibleAnimated:(BOOL)animated {
    if(_vImageCropView.frame.origin.y != _collectionView.frame.origin.y) {
        CGRect frame                = _vImageCropView.frame;
        frame.origin.y              = _collectionView.frame.origin.y;
        
        if(!animated) _vImageCropView.frame = frame; else {
            [self performAnimation:^{
                _vImageCropView.frame = frame;
            } usingDuration:0.25];
        }
    }
    
    _headerScrollable           = YES;
    
    CGRect visibleRect = CGRectMake(0.0,
                                    _collectionView.contentOffset.y + _collectionView.contentInset.top,
                                    _collectionView.frame.size.width,
                                    _collectionView.frame.size.height - _collectionView.contentInset.top - _collectionView.contentInset.bottom);
    
    UICollectionViewCell *cell = [self collectionView:_collectionView
                               cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_selectPhotoIndex inSection:0]];
    CGRect rect = cell.frame;
    if(CGRectContainsRect(visibleRect, rect)) {
        return;
    }
    
    CGFloat maxY        = CGRectGetMaxY(rect);
    CGFloat visibleMaxY = CGRectGetMaxY(visibleRect);
    if(maxY > visibleMaxY) {
        CGPoint offset = _collectionView.contentOffset;
        offset.y       += (maxY - visibleMaxY);
        if(!animated) [_collectionView setContentOffset:offset animated:NO]; else {
            [self performAnimation:^{
                [_collectionView setContentOffset:offset animated:NO];
            } usingDuration:0.25];
        }
        return;
    }
    
    CGFloat minY        = CGRectGetMinY(rect);
    CGFloat visibleMinY = CGRectGetMinY(visibleRect);
    if(minY < visibleMinY) {
        CGPoint offset = _collectionView.contentOffset;
        offset.y       -= (visibleMinY - minY);
        if(!animated) [_collectionView setContentOffset:offset animated:NO]; else {
            [self performAnimation:^{
                [_collectionView setContentOffset:offset animated:NO];
            } usingDuration:0.25];
        }
    }
}

- (void)performAnimation:(void (^)(void))block usingDuration:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         block();
     } completion:^(BOOL finished) {
         
     }];
}

- (void)fillImageAtIndex:(NSUInteger)aIndex {
    if(aIndex >= [_muAssets count]) {
        return;
    }

    @autoreleasepool {
        ALAsset *asset          = [_muAssets objectAtIndex:aIndex];
        _vImageCropView.image   = [asset thumbnailImage];
        [_vImageCropView relayoutImage];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage *image      = [asset fullResolutionImage];
            if(aIndex == _selectPhotoIndex) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.25 animations:^{
                        _vImageCropView.image  = image;
                    }];
                });
            }
        });
    }
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

#pragma mark - Output

- (void)outputImage:(UIImage *)aImage {
    if(![self.navigationController respondsToSelector:@selector(photosViewController:outputImage:)]) {
        return;
    }
    
    [(id<WMPhotosViewControllerOutput>)self.navigationController photosViewController:self
                                                                          outputImage:aImage];
}

- (void)outputFinalSynthetisedImage:(UIImage *)aImage {
    if(![self.navigationController respondsToSelector:@selector(photosViewController:outputCropedImage:)]) {
        return;
    }
    
    [(id<WMPhotosViewControllerOutput>)self.navigationController photosViewController:self
                                                                    outputCropedImage:aImage];
}

#pragma mark - WMAlbumViewDelegate

- (void)albumView:(WMAlbumView *)albumView didSelectedIndex:(NSUInteger)aIndex {
    if(aIndex >= _assetGroups.count) {
        return;
    }
    
    [self hideAlbumViewAnimated:YES];
    
    ALAssetsGroup *group = _assetGroups[aIndex];
    if(group == _selectedGroup) {
        return;
    }
    
    [self loadPhotosFromGroup:group];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _muAssets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WMImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionCellIdentifier forIndexPath:indexPath];
    [cell setImageContentFillMode:UIViewContentModeScaleAspectFill];
    
    if(indexPath.row < [_muAssets count]) {
        ALAsset *asset = [_muAssets objectAtIndex:indexPath.row];
        UIImage *image = [asset thumbnailImage];
        [cell setImage:image];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row != _selectPhotoIndex) {
        [self fillImageAtIndex:indexPath.row];
    }
    _selectPhotoIndex = indexPath.row;
    [self makeSelectedPhotoVisibleAnimated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _headerScrollable = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(_headerScrollable) {
        return;
    }
    
    if(scrollView.contentOffset.y >= -scrollView.contentInset.top) {
        CGFloat offsetY             = scrollView.contentInset.top + scrollView.contentOffset.y;
        CGRect frame                = _vImageCropView.frame;
        frame.origin.y              = scrollView.frame.origin.y - offsetY;
        if(_vImageCropView.frame.origin.y == scrollView.frame.origin.y) {
            [self performAnimation:^{
                _vImageCropView.frame = frame;
            } usingDuration:0.25];
        }
        else {
        _vImageCropView.frame = frame;
        }
    }
    else {
        CGRect frame                = _vImageCropView.frame;
        frame.origin.y              = scrollView.frame.origin.y;
        _vImageCropView.frame = frame;
    }
}

@end
