// images.mm
// Weapon icons are now embedded at compile-time using compressed pixel data
#import "cheat/images.h"
#import "cheat/embedded_weapon_data.h"
#import <MetalKit/MetalKit.h>
#import <zlib.h>
#import <memory>

namespace Icons {
    namespace Weapon {
        Texture AK, dikobraz, generator, invader, jupiter, M4A, madRat, vss, hound,
                whiteDwarf, bar95, defender, MF18, UMP99, stellarWind, fanatic,
                madRabbit, rhino, vega, MG7, UZI, arm;
    }

    bool loadTextureFromCompressedData(
        id<MTLDevice> device,
        const unsigned char* compressedData,
        size_t compressedSize,
        unsigned int width,
        unsigned int height,
        Texture& out
    ) {
        if (!device || !compressedData) return false;
        
        out = {}; // reset
        
        // Calculate uncompressed size (RGBA = 4 bytes per pixel)
        size_t uncompressedSize = width * height * 4;
        
        // Allocate buffer for decompressed data using unique_ptr for RAII
        auto pixelData = std::make_unique<unsigned char[]>(uncompressedSize);
        
        // Decompress using zlib
        uLongf destLen = uncompressedSize;
        int result = uncompress(pixelData.get(), &destLen, compressedData, compressedSize);
        
        if (result != Z_OK || destLen != uncompressedSize) {
            return false;
        }
        
        // Create Metal texture descriptor
        MTLTextureDescriptor* descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
                                                                                              width:width
                                                                                             height:height
                                                                                          mipmapped:NO];
        descriptor.usage = MTLTextureUsageShaderRead;
        descriptor.storageMode = MTLStorageModeShared;
        
        // Create the texture
        id<MTLTexture> texture = [device newTextureWithDescriptor:descriptor];
        if (!texture) {
            return false;
        }
        
        // Upload pixel data to texture
        MTLRegion region = MTLRegionMake2D(0, 0, width, height);
        [texture replaceRegion:region
                   mipmapLevel:0
                     withBytes:pixelData.get()
                   bytesPerRow:width * 4];
        
        // Store in output (pixelData automatically freed when unique_ptr goes out of scope)
        out.tex = texture;
        out.width = (float)width;
        out.height = (float)height;
        
        return true;
    }

    bool loadIcons(id<MTLDevice> device) {
        using namespace EmbeddedWeaponData;
        
        bool ok = true;
        ok &= loadTextureFromCompressedData(device, ak_data, ak_compressed_size, ak_width, ak_height, Weapon::AK);
        ok &= loadTextureFromCompressedData(device, dikobraz_data, dikobraz_compressed_size, dikobraz_width, dikobraz_height, Weapon::dikobraz);
        ok &= loadTextureFromCompressedData(device, generator_data, generator_compressed_size, generator_width, generator_height, Weapon::generator);
        ok &= loadTextureFromCompressedData(device, invader_data, invader_compressed_size, invader_width, invader_height, Weapon::invader);
        ok &= loadTextureFromCompressedData(device, jupiter_data, jupiter_compressed_size, jupiter_width, jupiter_height, Weapon::jupiter);
        ok &= loadTextureFromCompressedData(device, m4a_data, m4a_compressed_size, m4a_width, m4a_height, Weapon::M4A);
        ok &= loadTextureFromCompressedData(device, madrat_data, madrat_compressed_size, madrat_width, madrat_height, Weapon::madRat);
        ok &= loadTextureFromCompressedData(device, vss_data, vss_compressed_size, vss_width, vss_height, Weapon::vss);
        ok &= loadTextureFromCompressedData(device, mg7_data, mg7_compressed_size, mg7_width, mg7_height, Weapon::MG7);
        ok &= loadTextureFromCompressedData(device, hound_data, hound_compressed_size, hound_width, hound_height, Weapon::hound);
        ok &= loadTextureFromCompressedData(device, whitedwarf_data, whitedwarf_compressed_size, whitedwarf_width, whitedwarf_height, Weapon::whiteDwarf);
        ok &= loadTextureFromCompressedData(device, bar95_data, bar95_compressed_size, bar95_width, bar95_height, Weapon::bar95);
        ok &= loadTextureFromCompressedData(device, defender_data, defender_compressed_size, defender_width, defender_height, Weapon::defender);
        ok &= loadTextureFromCompressedData(device, mf18_data, mf18_compressed_size, mf18_width, mf18_height, Weapon::MF18);
        ok &= loadTextureFromCompressedData(device, ump99_data, ump99_compressed_size, ump99_width, ump99_height, Weapon::UMP99);
        ok &= loadTextureFromCompressedData(device, stellarwind_data, stellarwind_compressed_size, stellarwind_width, stellarwind_height, Weapon::stellarWind);
        ok &= loadTextureFromCompressedData(device, fanatic_data, fanatic_compressed_size, fanatic_width, fanatic_height, Weapon::fanatic);
        ok &= loadTextureFromCompressedData(device, madrabbit_data, madrabbit_compressed_size, madrabbit_width, madrabbit_height, Weapon::madRabbit);
        ok &= loadTextureFromCompressedData(device, rhino_data, rhino_compressed_size, rhino_width, rhino_height, Weapon::rhino);
        ok &= loadTextureFromCompressedData(device, ancientstar_data, ancientstar_compressed_size, ancientstar_width, ancientstar_height, Weapon::vega);
        ok &= loadTextureFromCompressedData(device, uzi_data, uzi_compressed_size, uzi_width, uzi_height, Weapon::UZI);
        ok &= loadTextureFromCompressedData(device, arm_data, arm_compressed_size, arm_width, arm_height, Weapon::arm);
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
