INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SpringBoardLocationManager

SpringBoardLocationManager_FILES = Tweak.x
SpringBoardLocationManager_FRAMEWORKS = UIKit CoreLocation
SpringBoardLocationManager_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
