#import "SSPowerDown.h"


static int nextValidIndex();
static void update (
                    CFNotificationCenterRef center,
                    void *observer,
                    CFStringRef name,
                    const void *object,
                    CFDictionaryRef userInfo
                    );

static int currentIndex = 0;
static SSPreferences *PREFS = nil;
static BOOL powerDownTrackTextSet = NO;

static int nextValidIndex()
{
    BOOL firstValuePassed = NO;
    

    for (int i = (currentIndex + 1); i != currentIndex; i++)
    {
        if (i == [PREFS.modes count])
            i = 0;
        
        BOOL enabled = [[PREFS valueForSpecifier: @"enabled" mode: [PREFS modeForIndex: i]] boolValue];

        
        if (enabled)
            return i;
        
        firstValuePassed = YES;
    }
    return -1;
}

static void update (
                    CFNotificationCenterRef center,
                    void *observer,
                    CFStringRef name,
                    const void *object,
                    CFDictionaryRef userInfo
                    )
{
    PREFS = [SSPreferences new];
}



%hook _UIActionSlider

%new
- (UIImageView*)knobImageView {
    return MSHookIvar<UIImageView*>(self, "_knobImageView");
}

%new
- (void)setNewKnobImage:(UIImage*)image {
    image = [image imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
    [self knobImageView].image = image;
    //hmm, considering adding a tint view, but i don't know how to best implement it. I mean, no one wants to have to set a custom tint for EVERY flipswitch.
    //[self knobImageView].tintColor = [PREFS tintColorForMode: [PREFS modeForIndex: currentIndex]];
}

%new
- (void)knobTapped
{
