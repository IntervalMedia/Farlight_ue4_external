// images.mm
#import "cheat/images.h"
#import <MetalKit/MetalKit.h>

namespace Icons {
    namespace Weapon {
        Texture AK, dikobraz, generator, invader, jupiter, M4A, madRat, vss, hound,
                whiteDwarf, bar95, defender, MF18, UMP99, stellarWind, fanatic,
                madRabbit, rhino, vega, MG7, UZI, arm;
    }

    static NSURL* BundleURLForPNG(const char* bundlePathNoExt) {
        // Supports paths like "resources/ak" (no extension).
        NSString* full = [NSString stringWithUTF8String:bundlePathNoExt];
        NSString* dir  = [full stringByDeletingLastPathComponent];
        NSString* name = [full lastPathComponent];

        if ([dir isEqualToString:@"."] || dir.length == 0) dir = nil;

        return [[NSBundle mainBundle] URLForResource:name withExtension:@"png" subdirectory:dir];
    }

    bool loadTextureFromFile(id<MTLDevice> device, const char* bundlePathNoExt, Texture& out) {
        out = {}; // reset

        if (!device || !bundlePathNoExt) return false;

        NSURL* url = BundleURLForPNG(bundlePathNoExt);
        if (!url) return false;

        MTKTextureLoader* loader = [[MTKTextureLoader alloc] initWithDevice:device];

        NSDictionary* options = @{
            MTKTextureLoaderOptionSRGB   : @NO,
            MTKTextureLoaderOptionOrigin : MTKTextureLoaderOriginTopLeft
        };

        NSError* err = nil;
        id<MTLTexture> tex = [loader newTextureWithContentsOfURL:url options:options error:&err];
        if (!tex) return false;

        out.tex = tex;
        out.width  = (float)tex.width;
        out.height = (float)tex.height;
        return true;
    }

    bool loadIcons(id<MTLDevice> device) {
        // Match your Windows filenames; use bundle paths without ".png"
        bool ok = true;
        ok &= loadTextureFromFile(device, "resources/ak", &Weapon::AK);
        ok &= loadTextureFromFile(device, "resources/dikobraz", &Weapon::dikobraz);
        ok &= loadTextureFromFile(device, "resources/generator", &Weapon::generator);
        ok &= loadTextureFromFile(device, "resources/invader", &Weapon::invader);
        ok &= loadTextureFromFile(device, "resources/jupiter", &Weapon::jupiter);
        ok &= loadTextureFromFile(device, "resources/m4a", &Weapon::M4A);
        ok &= loadTextureFromFile(device, "resources/madrat", &Weapon::madRat);
        ok &= loadTextureFromFile(device, "resources/vss", &Weapon::vss);
        ok &= loadTextureFromFile(device, "resources/mg7", &Weapon::MG7);
        ok &= loadTextureFromFile(device, "resources/hound", &Weapon::hound);
        ok &= loadTextureFromFile(device, "resources/whitedwarf", &Weapon::whiteDwarf);
        ok &= loadTextureFromFile(device, "resources/bar95", &Weapon::bar95);
        ok &= loadTextureFromFile(device, "resources/defender", &Weapon::defender);
        ok &= loadTextureFromFile(device, "resources/mf18", &Weapon::MF18);
        ok &= loadTextureFromFile(device, "resources/ump99", &Weapon::UMP99);
        ok &= loadTextureFromFile(device, "resources/stellarwind", &Weapon::stellarWind);
        ok &= loadTextureFromFile(device, "resources/fanatic", &Weapon::fanatic);
        ok &= loadTextureFromFile(device, "resources/madrabbit", &Weapon::madRabbit);
        ok &= loadTextureFromFile(device, "resources/rhino", &Weapon::rhino);
        ok &= loadTextureFromFile(device, "resources/ancientstar", &Weapon::vega);
        ok &= loadTextureFromFile(device, "resources/uzi", &Weapon::UZI);
        ok &= loadTextureFromFile(device, "resources/arm", &Weapon::arm);
        return ok;
    }

    void clearIcons() {
        Weapon::AK = {};
        Weapon::dikobraz = {};
        Weapon::generator = {};
        Weapon::invader = {};
        Weapon::jupiter = {};
        Weapon::M4A = {};
        Weapon::madRat = {};
        Weapon::vss = {};
        Weapon::hound = {};
        Weapon::whiteDwarf = {};
        Weapon::bar95 = {};
        Weapon::defender = {};
        Weapon::MF18 = {};
        Weapon::UMP99 = {};
        Weapon::stellarWind = {};
        Weapon::fanatic = {};
        Weapon::madRabbit = {};
        Weapon::rhino = {};
        Weapon::vega = {};
        Weapon::MG7 = {};
        Weapon::UZI = {};
        Weapon::arm = {};
    }
}
