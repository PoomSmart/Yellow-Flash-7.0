#import <Foundation/Foundation.h>

/*@interface CAMFlashBadge : UIButton
@end*/

@interface UIColor (FlashYellow70Addition)
+ (UIColor *)systemYellowColor;
@end

@interface UIImage (FlashYellow70Addition)
+ (UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
- (UIImage *)_flatImageWithColor:(UIColor *)color;
@end

@interface UIView (FlashYellow70Addition)
- (void)pl_setHidden:(BOOL)hidden animated:(BOOL)animated;
@end

@interface PLCameraView : UIView
- (int)cameraMode;
- (int)_currentFlashMode;
- (BOOL)_shouldHideFlashButtonForMode:(int)mode;
- (BOOL)_isStillImageMode:(int)mode;
- (BOOL)_isVideoMode:(int)mode;
- (BOOL)_isHidingBadgesForFilterUI;
@end

@interface PLCameraController : NSObject
@property(assign, nonatomic) BOOL performingTimedCapture;
+ (PLCameraController *)sharedInstance;
- (PLCameraView *)delegate;
- (BOOL)flashWillFire;
@end

/*@interface PLCameraView (FlashYellow70Addition)
- (CAMFlashBadge *)_flashBadge;
- (id)_HDRBadge;
- (BOOL)_shouldHideFlashBadgeForMode:(int)mode;
- (void)_70_updateFlashBadge;
- (void)_createFlashBadgeIfNecessary;
@end*/

@interface CAMButtonLabel : UILabel
@end

@interface CAMFlashButton : UIButton
@property(assign, nonatomic) int flashMode;
@property(assign, nonatomic) int orientation;
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

/*@implementation CAMFlashBadge

- (void)_commonInit
{
	[self setImage:[[UIImage imageNamed:@"CAMFlashBadge" inBundle:PLPhotoLibraryFrameworkBundle()] _flatImageWithColor:[UIColor systemYellowColor]] forState:UIControlStateNormal];
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
		[self _commonInit];
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self)
		[self _commonInit];
	return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end*/

//static CAMFlashBadge *flashBadge = nil;

/*%hook PLCameraController

- (void)setDelegate:(PLCameraView *)delegate
{
	%orig;
	if (delegate != nil)
		[delegate _70_updateFlashBadge];
}

- (void)_flashStateChanged
{
	%orig;
	[[self delegate] _70_updateFlashBadge];
}

%end*/

/*%hook PLCameraView

%new
- (BOOL)_shouldHideFlashBadgeForMode:(int)mode
{
	if ([[%c(PLCameraController) sharedInstance] performingTimedCapture])
		return YES;
	if ([self _currentFlashMode] != 0)
		return YES;
	return [self _shouldHideFlashButtonForMode:mode];
}

%new
- (CAMFlashBadge *)_flashBadge
{
	return flashBadge;
}

%new
- (void)_70_updateFlashBadge
{
	BOOL hidden = [self _shouldHideFlashBadgeForMode:[self cameraMode]];
	flashBadge.frame = [[self _HDRBadge] frame];
	[[self _flashBadge] pl_setHidden:hidden animated:YES];
}

%new
- (void)_createFlashBadgeIfNecessary
{
	flashBadge = [[[CAMFlashBadge alloc] initWithFrame:CGRectZero] retain];
	[self addSubview:flashBadge];
}

- (void)cameraControllerTorchAvailabilityChanged:(id)change
{
	%orig;
	[self _70_updateFlashBadge];
}

- (void)setVideoFlashMode:(int)mode
{
	%orig;
	[self _70_updateFlashBadge];
}

- (void)_setFlashMode:(int)mode
{
	%orig;
	[self _70_updateFlashBadge];
}

- (void)_createStillImageControlsIfNecessary
{
	%orig;
	[self _createFlashBadgeIfNecessary];
}

- (void)dealloc
{
	[flashBadge removeFromSuperview];
	[flashBadge release];
	%orig;
}

- (void)_showControlsForChangeToMode:(int)mode animated:(BOOL)animated
{
	%orig;
	[self _70_updateFlashBadge];
}

- (void)_hideControlsForChangeToMode:(int)mode animated:(BOOL)animated
{
	%orig;
	[self _70_updateFlashBadge];
}

- (void)_updateForStartTransitionToShowFilterSelection:(id)arg1 animated:(BOOL)animated
{
	%orig;
	[self _70_updateFlashBadge];
}

%end*/

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
	//[[[%c(PLCameraController) sharedInstance] delegate] _70_updateFlashBadge];
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
    BOOL shouldYellow = NO;
    BOOL expanded = [self isExpanded];
    BOOL landscape = self.orientation > 2;
    BOOL flashOn = self.flashMode != -1;
    shouldYellow = (expanded && !landscape) || (!expanded && flashOn);
	[self._flashIconView setImage:[image _flatImageWithColor:shouldYellow ? y : w]];
}

%end
