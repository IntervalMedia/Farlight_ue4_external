ARCHS = arm64 arm64e
TARGET = iphone:clang:15.5:15.0
THEOS_PACKAGE_DIR_NAME = debs
# THEOS_DEVICE_IP = localhost

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Farlight

Farlight_FILES = main.mm \
                 images.mm \
                 utils/driver.cpp \
                 imgui/imgui_widgets.cpp \
                 imgui/imgui_tables.cpp \
                 imgui/imgui.cpp \
                 imgui/imgui_draw.cpp
                 
Farlight_CFLAGS = -std=c++20 -Wall -fno-rtti
Farlight_LDFLAGS = -static -static-libgcc -static-libstdc++

# Generate embedded weapon data before building
before-all::
	python3 scripts/embed_images.py

include $(THEOS_MAKE_PATH)/tweak.mk
