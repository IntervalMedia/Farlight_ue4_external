//
// Apple Compatibility Layer
// Provides Apple-compatible definitions for iOS jailbreak tweak
//

#ifndef APPLE_COMPAT_H
#define APPLE_COMPAT_H

#include <cstdint>
#include <string>

// For testing on non-Apple systems, conditionally include mach headers
#ifdef __APPLE__
    #include <mach/mach.h>
    using vm_address_t = mach_vm_address_t;
    // Include iOS-specific driver implementation
    #include "ios_driver.h"
#else
    // For testing purposes on non-Apple systems
    using vm_address_t = uintptr_t;
#endif

// Apple-compatible type definitions to replace Windows types
using DWORD_PTR = uintptr_t;
using DWORD = uint32_t;
using UINT64 = uint64_t;
using UINT32 = uint32_t; 
using UINT16 = uint16_t;
using ULONG = uint32_t;
using USHORT = uint16_t;
using INT32 = int32_t;
using INT16 = int16_t;

#ifndef __APPLE__
// For non-Apple systems (testing), provide mock implementations

// Forward declarations for functions that would be implemented
// in the iOS-specific memory management layer
template<typename T>
T read(uint64_t address);

template<typename T>
void write(uint64_t address, T buffer);

template<typename T>
bool read_array(uint64_t address, T *array, size_t len);

// Mock implementation for compilation (would be replaced by actual iOS driver)
namespace driver {
    static bool readBoolean(uint64_t address, uint8_t bitOffset) {
        // This would be implemented in the iOS-specific driver
        return false;
    }
    
    static int32_t find_process(const char* processName) {
        // This would be implemented in the iOS-specific driver
        return -1;
    }
}

// Minimal declarations for functions that would be implemented elsewhere
// in the iOS-specific driver layer
extern uintptr_t processId;
extern uintptr_t baseId;

#endif // !__APPLE__

// Essential Unreal Engine data structures for Apple compatibility
template<class T>
class TArray {
public:
    [[nodiscard]] int length() const {
        return dataCount;
    }

    [[nodiscard]] bool isValid() const {
        if (dataCount > dataMax)
            return false;
        if (!memoryData)
            return false;
        return true;
    }

    [[nodiscard]] uint64_t getAddress() const {
        return memoryData;
    }

    T getValue(int position) {
        return read<T>(memoryData + position * 0x8);
    }

    T getObject(int position) {
        return T(getValuePointer(position));
    }

    DWORD_PTR getValuePointer(int position) {
        return read<DWORD_PTR>(memoryData + position * 0x8);
    }

protected:
    uint64_t memoryData;
    uint32_t dataCount;
    uint32_t dataMax;
};

struct FString : private TArray<wchar_t> {
    [[nodiscard]] std::string toString() const {
        auto *buffer = new wchar_t[dataCount];
        read_array(memoryData, buffer, dataCount);
        std::string s = wchar_to_UTF8(buffer);
        delete[] buffer;
        return s;
    }

    static std::string wchar_to_UTF8(const wchar_t *in) {
        std::string out;
        unsigned int codepoint = 0;
        for (in; *in != 0; ++in) {
            if (*in >= 0xd800 && *in <= 0xdbff)
                codepoint = ((*in - 0xd800) << 10) + 0x10000;
            else {
                if (*in >= 0xdc00 && *in <= 0xdfff)
                    codepoint |= *in - 0xdc00;
                else
                    codepoint = *in;
                if (codepoint <= 0x7f)
                    out.append(1, static_cast<char>(codepoint));
                else if (codepoint <= 0x7ff) {
                    out.append(1, static_cast<char>(0xc0 | ((codepoint >> 6) & 0x1f)));
                    out.append(1, static_cast<char>(0x80 | (codepoint & 0x3f)));
                } else if (codepoint <= 0xffff) {
                    out.append(1, static_cast<char>(0xe0 | ((codepoint >> 12) & 0x0f)));
                    out.append(1, static_cast<char>(0x80 | ((codepoint >> 6) & 0x3f)));
                    out.append(1, static_cast<char>(0x80 | (codepoint & 0x3f)));
                } else {
                    out.append(1, static_cast<char>(0xf0 | ((codepoint >> 18) & 0x07)));
                    out.append(1, static_cast<char>(0x80 | ((codepoint >> 12) & 0x3f)));
                    out.append(1, static_cast<char>(0x80 | ((codepoint >> 6) & 0x3f)));
                    out.append(1, static_cast<char>(0x80 | (codepoint & 0x3f)));
                }
                codepoint = 0;
            }
        }
        return out;
    }
};

struct FName {
    uint32_t index = 0;
    int32_t number = 0;

    inline bool operator==(const FName &other) const {
        return index == other.index && number == other.number;
    }
};

// Apple-compatible definitions for offsets namespace
namespace offsets {
    // These would be iOS-specific memory offsets for the game
    // Values would need to be determined for the iOS version
    extern uint32_t gWorld;
    extern uint32_t gNames;
    extern uint32_t gObject;
    extern uint32_t oaObjectArrayToNumElements;
    extern uint32_t fFieldToText;
    extern uint32_t oObjectToInternalIndex;
    extern uint32_t oObjectToClassPrivate;
    extern uint32_t oNamePrivate;
    extern uint32_t oOuterPrivate;
    extern uint32_t lOwningWorld;
    extern uint32_t lActorCluster;
    // Add other offsets as needed for iOS version...
}

// Function declarations that would be used by the nameFromId function
std::string nameFromId(int id);

#endif // APPLE_COMPAT_H