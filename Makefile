ARCHS = arm64 arm64e
TARGET = iphone:clang:14.5:14.5
SDK = 14.5

INSTALL_TARGET_PROCESSES = Standoff2

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = hack77
hack77_FILES = Tweak.xm

hack77_CFLAGS = -fobjc-arc -std=c++17
hack77_LDFLAGS = -framework UIKit -framework CoreGraphics -lobjc -lc++

include $(THEOS_MAKE_PATH)/tweak.mk

after-stage::
	@cp $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/$(TWEAK_NAME).dylib ./$(TWEAK_NAME).dylib 2>/dev/null || true
