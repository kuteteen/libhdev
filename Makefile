export ARCHS = armv7 arm64 arm64e
export TARGET = iphone:clang:12.2:10.0

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = libhdev
libhdev_FILES = $(wildcard HPreferences/*.m) $(wildcard HUtilities/*.m)
libhdev_PUBLIC_HEADERS = libhdev.h HPreferences HUtilities
libhdev_INSTALL_PATH = /Library/Frameworks
libhdev_PRIVATE_FRAMEWORKS = Preferences
libhdev_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/framework.mk
