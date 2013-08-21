#import <UIKit/UIKit.h>

int main(int argc, char *argv[])
{
	srand((unsigned int)::time(NULL));
    
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	int retVal = UIApplicationMain(argc, argv, nil, @"LittlePooAppDelegate");
	[pool release];
	return retVal;
}
