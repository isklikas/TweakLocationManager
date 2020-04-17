/* In CLLocationManager, the following methods are of interest

+ (id)sharedManager; //It's a private method but this doesn't mean we can't use it ;)
+ (void)setAuthorizationStatus:(BOOL)arg1 forBundle:(id)arg2; //Approve our tweak bundle
+ (void)setAuthorizationStatus:(BOOL)arg1 forBundleIdentifier:(id)arg2 ; //Approve our tweak bundle and SpringBoard (or the app that the tweak is hooking in).
- (BOOL)locationServicesAvailable; //This makes sure location requests are possible (on hardware basis).
- (BOOL)locationServicesApproved; //This makes sure that when we request the location, we are authorized to get it.
- (CLLocation *)location; //The location that we want.

*/

#import <CoreLocation/CoreLocation.h>

@interface SBFLockScreenDateViewController: UIViewController {}
-(void)viewWillAppear:(BOOL)arg1;
@end 

%hook SBFLockScreenDateViewController

-(void)viewWillAppear:(BOOL)arg1 {
	%orig(arg1);

	//First get the location Manager (it's a private method so we have to use performSelector:)
	CLLocationManager *locationManager = [CLLocationManager performSelector:@selector(sharedManager)];
	
	//Run: + (void)setAuthorizationStatus:(BOOL)arg1 forBundle:(id)arg2; 
	//It's also a private method and because arg1 is a non-id object, we have to do this through runtime.
	typedef void (*setAuthBundle)(void*, SEL, BOOL, void*);
	SEL setAuthBundleSEL = @selector(setAuthorizationStatus:forBundle:);
	setAuthBundle setAuthBundleIMP = (setAuthBundle)[[locationManager class] methodForSelector:setAuthBundleSEL];
	setAuthBundleIMP((__bridge void*)locationManager, setAuthBundleSEL, TRUE, (__bridge void*)[NSBundle mainBundle]);
	
	//Run: + (void)setAuthorizationStatus:(BOOL)arg1 forBundleIdentifier:(id)arg2;
	//It's also a private method and because arg1 is a non-id object, we have to do this through runtime.
	typedef void (*setAuthBundleID)(void*, SEL, BOOL, void*);
	SEL setAuthBundleIDSEL = @selector(setAuthorizationStatus:forBundleIdentifier:);
	setAuthBundleID setAuthBundleIDIMP = (setAuthBundleID)[[locationManager class] methodForSelector:setAuthBundleIDSEL];
	
	//This is where we approve our tweak AND SpringBoard (or the app that we have hooked in).
	setAuthBundleIDIMP((__bridge void*)locationManager, setAuthBundleIDSEL, TRUE, (__bridge void*)[[NSBundle mainBundle] bundleIdentifier]);
	setAuthBundleIDIMP((__bridge void*)locationManager, setAuthBundleIDSEL, TRUE, (__bridge void*)@"com.apple.springboard");
	
	//Run: - (BOOL)locationServicesAvailable;
	//Just to make sure it's available. You can use this as a check in your tweak.
    typedef BOOL (*getIfAvailable)(void*, SEL);
	SEL getIfAvailableSEL = @selector(locationServicesAvailable);
	getIfAvailable getIfAvailableIMP = (getIfAvailable)[[locationManager class] instanceMethodForSelector:getIfAvailableSEL];
	BOOL available = getIfAvailableIMP((__bridge void*)locationManager, getIfAvailableSEL);
	
	//Run: - (BOOL)locationServicesApproved;
	//Just to make sure we're authorized to request a location. You can also use this as a check in your tweak.
    typedef BOOL (*getIfApproved)(void*, SEL);
	SEL getIfApprovedSEL = @selector(locationServicesApproved);
	getIfApproved getIfApprovedIMP = (getIfApproved)[[locationManager class] instanceMethodForSelector:getIfApprovedSEL];
	BOOL approved = getIfApprovedIMP((__bridge void*)locationManager, getIfApprovedSEL);
	
	//Finally get the location in the standard way
	[locationManager startUpdatingLocation];
	CLLocation *location = [locationManager location];
	[locationManager stopUpdatingLocation]; 
	//Obviously, you can call stop when you deem necessary. The more time iOS updates the location, the more accurate it becomes.
	//This also means, you can also request the location later. Just remember to call stop when you're done.
	//The approval is complete, so the authorization part only needs to be called once really.
	
	#pragma clang diagnostic push
	#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	
	//I'm suppressing the deprecation warning, because the old UIAlertView is much simpler ;P 
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location" message:[NSString stringWithFormat:@"%@ \n %d \n %d", location, available, approved] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    #pragma clang diagnostic pop
}

%end
