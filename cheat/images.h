// header
// Images are now embedded at compile-time using compressed pixel data
#pragma once
#import <Metal/Metal.h>

namespace Icons {

    struct Texture {
        id<MTLTexture> tex = nil;
        float width = 0.0f;
        float height = 0.0f;
        explicit operator bool() const { return tex != nil; }
    };

    namespace Weapon {
        extern Texture AK;
        extern Texture dikobraz;
        extern Texture generator;
        extern Texture invader;
        extern Texture jupiter;
        extern Texture M4A;
        extern Texture madRat;
        extern Texture vss;
        extern Texture hound;
        extern Texture whiteDwarf;
        extern Texture bar95;
        extern Texture defender;
        extern Texture MF18;
        extern Texture UMP99;
        extern Texture stellarWind;
        extern Texture fanatic;
        extern Texture madRabbit;
        extern Texture rhino;
        extern Texture vega;
        extern Texture MG7;
        extern Texture UZI;
        extern Texture arm;
    }

    // call once at startup (after you have a MTLDevice)
    bool loadIcons(id<MTLDevice> device);

    // optional cleanup (ARC will release when set to nil)
    void clearIcons();
}
