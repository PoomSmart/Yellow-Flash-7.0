#import <Foundation/Foundation.h>

@interface CAMHDRBadge : UIButton
@end

@interface UIColor (FlashYellow70Addition)
+ (UIColor *)systemYellowColor;
@end

@interface UIImage (FlashYellow70Addition)
+ (UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
- (UIImage *)_flatImageWithColor:(UIColor *)color;
@end

@interface CAMButtonLabel : UILabel
@end

@interface CAMFlashButton : UIButton
@property(assign, nonatomic) int flashMode;
@property(readonly, assign, nonatomic) CAMButtonLabel *_offLabel;
@property(readonly, assign, nonatomic) CAMButtonLabel *_onLabel;
@property(readonly, assign, nonatomic) CAMButtonLabel *_autoLabel;
@property(readonly, assign, nonatomic) UIImageView *_flashIconView;
- (BOOL)isExpanded;
@end

@interface CAMFlashButton (FlashYellow70Addition)
- (void)_70_updateColors;
@end

extern "C" NSBundle *PLPhotoLibraryFrameworkBundle();

%hook CAMFlashButton

- (void)_setExpanded:(BOOL)expand
{
	%orig;
	[self _70_updateColors];
}

- (void)_commonCAMFlashButtonInitialization
{
	%orig;
	[self _70_updateColors];
}

- (void)setFlashMode:(int)mode notifyDelegate:(BOOL)delegate
{
	%orig;
	if (![self isExpanded])
		[self _70_updateColors];
}

- (void)setOrientation:(int)orientation animated:(BOOL)animated
{
	%orig;
	[self _70_updateColors];
}

%new
- (void)_70_updateColors
{
	UIColor *y = [UIColor systemYellowColor];
	UIColor *w = [UIColor whiteColor];
    [self._autoLabel setTextColor:y];
    [self._onLabel setTextColor:y];
    [self._offLabel setTextColor:w];
    UIImage *image = [UIImage imageNamed:@"CAMFlashButton" inBundle:PLPhotoLibraryFrameworkBundle()];
	[self._flashIconView setImage:[image _flatImageWithColor:self.flashMode != -1 || [self isExpanded] ? y : w]];
}

%end
