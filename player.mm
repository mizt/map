#import <Cocoa/Cocoa.h>
#import "MetalView.h"
#import <string>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcomma"
#pragma clang diagnostic ignored "-Wunused-function"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#define STB_IMAGE_IMPLEMENTATION
#define STBI_ONLY_PNG
namespace stb_image {
    #import "./libs/stb_image.h"
}
#pragma clang diagnostic pop

#define WIDTH 1920
#define HEIGHT 1080 

class App {
    
    private:
        
        NSWindow *win;
        MetalView *view;
        
        dispatch_source_t timer;
        
        unsigned int *src = nullptr;
        unsigned int *map = nullptr;

    public:
        
        App() {
            
            int w;
            int h;
            int bpp;
            std::string url = "./src.png";
            this->src = (unsigned int *)stb_image::stbi_load(url.c_str(),&w,&h,&bpp,4);
            if(!(w==WIDTH&&h==HEIGHT&&bpp==4)) {
                delete[] this->src;
                this->src = nullptr;
            }
            else {
                url = "./maps/map.png";
                this->map = (unsigned int *)stb_image::stbi_load(url.c_str(),&w,&h,&bpp,4);
                if(!(w==WIDTH&&h==HEIGHT&&bpp==4)) {
                    delete[] this->map;
                    delete[] this->src;
                    this->src = nullptr;
                    this->map = nullptr;
                }
            }
            
            CGRect rect = CGRectMake(0,0,1920>>1,1080>>1);
            
            this->win = [[NSWindow alloc] initWithContentRect:rect styleMask:1 backing:NSBackingStoreBuffered defer:NO];
            this->view = [[MetalView alloc] initWithFrame:CGRectMake(0,0,WIDTH,HEIGHT)];
            [this->view setFrame:rect];
            [[this->win contentView] addSubview:this->view];
            
            this->timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0,0,dispatch_queue_create("ENTER_FRAME",0));
            dispatch_source_set_timer(this->timer,dispatch_time(0,0),(1.0/30)*1000000000,0);
            dispatch_source_set_event_handler(this->timer,^{
                
                if(src&&map) {
                    
                    
                    id<MTLTexture> texture = [this->view texture];
                    int width  = (int)texture.width;
                    int height = (int)texture.height;
                            
                    [texture replaceRegion:MTLRegionMake2D(0,0,width,height) mipmapLevel:0 withBytes:this->src bytesPerRow:width<<2];
                        
                    id<MTLTexture> map = [this->view map];
                    [map replaceRegion:MTLRegionMake2D(0,0,width,height) mipmapLevel:0 withBytes:this->map bytesPerRow:width<<2];
                                        
                                     
                    [this->view update:
                    ^(id<MTLCommandBuffer> commandBuffer){
                        [this->view cleanup];
                    }];
                    
                    
                    static dispatch_once_t oncePredicate;
                    dispatch_once(&oncePredicate,^{
                        dispatch_async(dispatch_get_main_queue(),^{
                            [this->win center];
                            [this->win makeKeyAndOrderFront:nil];
                        });
                    });
                    
                }
                  
            });
            if(this->timer) dispatch_resume(this->timer);                
        }
        
        ~App() {
            
            if(this->timer){
                dispatch_source_cancel(this->timer);
                this->timer = nullptr;
            }
            
            if(this->src) delete[] this->src;
            if(this->map) delete[] this->map;
                
            [this->win setReleasedWhenClosed:NO];
            [this->win close];
            this->win = nil;
        }
};

#pragma mark AppDelegate
@interface AppDelegate:NSObject <NSApplicationDelegate> {
    App *app;
}
@end
@implementation AppDelegate
-(void)applicationDidFinishLaunching:(NSNotification*)aNotification {
    app = new App();
}
-(void)applicationWillTerminate:(NSNotification *)aNotification {
    delete app;
}
@end

int main(int argc, char *argv[]) {
    @autoreleasepool {
    
        id app = [NSApplication sharedApplication];
        id delegat = [AppDelegate alloc];
        [app setDelegate:delegat];
        [app run];
    }
}