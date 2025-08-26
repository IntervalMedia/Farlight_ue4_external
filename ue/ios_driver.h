//
// iOS-Specific Driver Implementation
// Replaces Windows driver with iOS jailbreak-compatible memory access
//

#ifndef IOS_DRIVER_H
#define IOS_DRIVER_H

#include <cstdint>
#include <mach/mach.h>
#include <mach/vm_map.h>
#include <mach/mach_vm.h>

// iOS-specific memory management class for jailbreak tweaks
class iOSMemoryManager {
private:
    mach_port_t targetTask;
    pid_t targetPID;
    
public:
    // Initialize memory manager for target process
    bool initialize(const char* processName);
    
    // Read memory from target process
    bool readMemory(uint64_t address, void* buffer, size_t size);
    
    // Write memory to target process
    bool writeMemory(uint64_t address, const void* buffer, size_t size);
    
    // Read boolean value from specific bit offset
    bool readBoolean(uint64_t address, uint8_t bitOffset);
    
    // Find process by name
    pid_t findProcess(const char* processName);
    
    // Get base address of loaded image/module
    uint64_t getImageBase(const char* imageName);
    
    // Clean up resources
    void cleanup();
};

// Global instance for iOS memory management
extern iOSMemoryManager* g_iosMemory;

// iOS-compatible implementations of the original driver functions
namespace driver {
    // iOS implementation of readBoolean function
    static inline bool readBoolean(uint64_t address, uint8_t bitOffset) {
        if (!g_iosMemory) return false;
        return g_iosMemory->readBoolean(address, bitOffset);
    }
    
    // iOS implementation of find_process function
    static inline int32_t find_process(const char* processName) {
        if (!g_iosMemory) return -1;
        return g_iosMemory->findProcess(processName);
    }
}

// iOS-compatible template functions for memory access
template<typename T>
T read(uint64_t address) {
    T buffer{};
    if (g_iosMemory) {
        g_iosMemory->readMemory(address, &buffer, sizeof(T));
    }
    return buffer;
}

template<typename T>
void write(uint64_t address, T buffer) {
    if (g_iosMemory) {
        g_iosMemory->writeMemory(address, &buffer, sizeof(T));
    }
}

template<typename T>
bool read_array(uint64_t address, T* array, size_t len) {
    if (!g_iosMemory || !array) return false;
    return g_iosMemory->readMemory(address, array, sizeof(T) * len);
}

// Global variables that would be set by the iOS-specific initialization
extern uintptr_t processId;
extern uintptr_t baseId;

#endif // IOS_DRIVER_H