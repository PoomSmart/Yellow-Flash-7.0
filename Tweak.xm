#import "../PS.h"

@interface CAMFlashBadge : UIButton
@end

@interface PLCameraView (FlashYellow70Addition)
- (CAMFlashBadge *)_flashBadge;
- (id)_HDRBadge;
- (BOOL)_shouldHideFlashBadgeForMode:(NSInteger)mode;
- (void)_70_updateFlashBadge;
- (void)_createFlashBadgeIfNecessary;
@end

@interface CAMFlashButton (FlashYellow70Addition)
- (void)_70_updateColors;
@end

extern "C" NSBundle *PLPhotoLibraryFrameworkBundle();

@implementation CAMFlashBadge

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

@end

static CAMFlashBadge *flashBadge = nil;

%hook PLCameraController

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

%end

%hook PLCameraView

%new
- (BOOL)_shouldHideFlashBadgeForMode:(NSInteger)mode
{
	PLCameraController *cont = [%c(PLCameraController) sharedInstance];
	BOOL performingTimedCapture = [cont performingTimedCapture];
	NSInteger currentFlashMode = [self _currentFlashMode];
	if (!performingTimedCapture && currentFlashMode == 0) {
		NSInteger cameraMode = self.cameraMode;
		BOOL isStillImageMode = [self _isStillImageMode:cameraMode];
		BOOL isVideoMode = [self _isVideoMode:cameraMode];
		BOOL shouldHideFlashButton = [self _shouldHideFlashButtonForMode:mode];
		BOOL isShowingGrid = [cont.effectsRenderer isShowingGrid];
		BOOL isReviewing = MSHookIvar<BOOL>(self, "_reviewingImagePickerCapture");
		NSInteger flashMode = cont.flashMode;
		if (isStillImageMode) {
			BOOL flashWillFire = [cont flashWillFire];
			if (flashWillFire) {
				if (isVideoMode && flashMode == 1)
					if (!shouldHideFlashButton)
						return isShowingGrid || isReviewing;
			}
		} else {
			if (isVideoMode) {
				if (flashMode == 1 && !shouldHideFlashButton)
					return isShowingGrid || isReviewing;
			} else {
				if (!shouldHideFlashButton)
					return isShowingGrid || isReviewing;
			}
		}
		return NO;
	}
	return YES;
}

%new
- (void)_70_updateFlashBadge
{
	BOOL hidden = [self _shouldHideFlashBadgeForMode:self.cameraMode];
	[UIView animateWithDuration:[UIView pl_setHiddenAnimationDuration] animations:^{
		flashBadge.alpha = hidden ? 0.0f : 1.0f;
	}];
}

%new
- (void)_createFlashBadgeIfNecessary
{
	flashBadge = [[CAMFlashBadge alloc] initWithFrame:CGRectZero];
	flashBadge.tag = 5454;
	flashBadge.enabled = YES;
	flashBadge.userInteractionEnabled = NO;
	flashBadge.frame = [self _HDRBadge].frame;
	if ([self viewWithTag:5454] != nil) {
		[[self viewWithTag:5454] removeFromSuperview];
		[[self viewWithTag:5454] release];
	}
	[self addSubview:flashBadge];
	[self _70_updateFlashBadge];
}

- (void)setCameraMode:(NSInteger)mode
{
	%orig;
	if (!MSHookIvar<BOOL>(self, "_capturingPhoto"))
		[self _70_updateFlashBadge];
}

- (void)cameraControllerTorchAvailabilityChanged:(id)change
{
	%orig;
	[self _70_updateFlashBadge];
}

- (void)setVideoFlashMode:(NSInteger)mode
{
	%orig;
	[self _70_updateFlashBadge];
}

- (void)_setFlashMode:(NSInteger)mode
{
	%orig;
	[self _70_updateFlashBadge];
}

- (void)_createStillImageControlsIfNecessary
{
	%orig;
	[self _createFlashBadgeIfNecessary];
}

- (id)initWithFrame:(CGRect)frame spec:(id)spec
{
	self = %orig;
	[self _70_updateFlashBadge];
	return self;
}

- (void)dealloc
{
	if (flashBadge != nil) {
		[flashBadge removeFromSuperview];
		[flashBadge release];
		flashBadge = nil;
	}
	%orig;
}

- (void)_showControlsForChangeToMode:(NSInteger)mode animated:(BOOL)animated
{
	%orig;
	[self _70_updateFlashBadge];
}

- (void)_hideControlsForChangeToMode:(NSInteger)mode animated:(BOOL)animated
{
	%orig;
	[self _70_updateFlashBadge];
}

- (void)_updateForStartTransitionToShowFilterSelection:(id)arg1 animated:(BOOL)animated
{
	%orig;
	[self _70_updateFlashBadge];
}

- (void)_rotateCameraControlsAndInterface
{
	%orig;
	[self _70_updateFlashBadge];
}

%end

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

- (void)setFlashMode:(NSInteger)mode notifyDelegate:(BOOL)delegate
{
	%orig;
	if (![self isExpanded])
		[self _70_updateColors];
	[[[%c(PLCameraController) sharedInstance] delegate] _70_updateFlashBadge];
}

- (void)setOrientation:(NSInteger)orientation animated:(BOOL)animated
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
