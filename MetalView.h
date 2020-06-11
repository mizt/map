#import <MetalKit/MetalKit.h>

@interface MetalView:NSView
-(void)update:(void (^)(id<MTLCommandBuffer>))onComplete;
-(bool)reloadShader:(dispatch_data_t)data;
-(id<MTLTexture>)o0;
-(id<MTLTexture>)o1;
-(id<MTLTexture>)o2;
-(id<MTLTexture>)o3;
-(id<MTLTexture>)s0;
-(id<MTLTexture>)s1;
-(id<MTLTexture>)s2;
-(id<MTLTexture>)s3;
-(id<MTLTexture>)drawableTexture;
-(void)cleanup;
@end
