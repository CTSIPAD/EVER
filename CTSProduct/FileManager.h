

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

+(void)appendToLogView:(NSString*)viewName function:(NSString*)functionName ExceptionTitle:(NSString*)title exceptionReason:(NSString*)reason;
+(void)deleteFileName:(NSString*)fileName;

@end
