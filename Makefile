GO_EASY_ON_ME = 1
ARCHS = armv7 arm64

include theos/makefiles/common.mk
TWEAK_NAME = FlashYellow70
FlashYellow70_FILES = Tweak.xm
FlashYellow70_FRAMEWORKS = CoreGraphics UIKit
FlashYellow70_PRIVATE_FRAMEWORKS = PhotoLibrary

include $(THEOS_MAKE_PATH)/tweak.mk
