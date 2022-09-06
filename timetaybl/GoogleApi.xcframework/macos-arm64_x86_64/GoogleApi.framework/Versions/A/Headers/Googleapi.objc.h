// Objective-C API for talking to googleapi Go package.
//   gobind -lang=objc googleapi
//
// File is generated by gobind. Do not edit.

#ifndef __Googleapi_H__
#define __Googleapi_H__

@import Foundation;
#include "ref.h"
#include "Universe.objc.h"


@class GoogleapiGoogleDataLoader;

@interface GoogleapiGoogleDataLoader : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
- (NSString* _Nonnull)getAuthURLstring;
- (void)getClient:(NSString* _Nullable)authCode;
- (NSString* _Nonnull)getEvents;
@end

FOUNDATION_EXPORT GoogleapiGoogleDataLoader* _Nullable GoogleapiNewDataLoader(NSString* _Nullable credentials);

#endif
