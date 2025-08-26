//
// iOS-Specific Driver Implementation
// Provides iOS jailbreak-compatible memory access for ARM64 devices
//

#include "ios_driver.h"
#include <libproc.h>
#include <sys/sysctl.h>
#include <mach/mach_traps.h>
#include <vector>

// Global instance
iOSMemoryManager* g_iosMemory = nullptr;

// Global variables for process information
uintptr_t processId = 0;
uintptr_t baseId = 0;

bool iOSMemoryManager::initialize(const char* processName) {
    // Find the target process
    targetPID = findProcess(processName);
    if (targetPID <= 0) {
        return false;
    }
    
    // Get task port for the target process
    kern_return_t kr = task_for_pid(mach_task_self(), targetPID, &targetTask);
    if (kr != KERN_SUCCESS) {
        // On iOS jailbreak, this requires proper entitlements or root privileges
        return false;
    }
    
    // Get base address of the main executable
    baseId = getImageBase(processName);
    processId = targetPID;
    
    return true;
}

bool iOSMemoryManager::readMemory(uint64_t address, void* buffer, size_t size) {
    if (!buffer || size == 0) return false;
    
    mach_vm_size_t bytesRead = 0;
    kern_return_t kr = mach_vm_read_overwrite(
        targetTask,
        (mach_vm_address_t)address,
        size,
        (mach_vm_address_t)buffer,
        &bytesRead
    );
    
    return (kr == KERN_SUCCESS && bytesRead == size);
}

bool iOSMemoryManager::writeMemory(uint64_t address, const void* buffer, size_t size) {
    if (!buffer || size == 0) return false;
    
    kern_return_t kr = mach_vm_write(
        targetTask,
        (mach_vm_address_t)address,
        (vm_offset_t)buffer,
        (mach_msg_type_number_t)size
    );
    
    return (kr == KERN_SUCCESS);
}

bool iOSMemoryManager::readBoolean(uint64_t address, uint8_t bitOffset) {
    uint8_t byte = 0;
    if (!readMemory(address, &byte, sizeof(byte))) {
        return false;
    }
    
    // Extract the specific bit using bitwise operations
    return (byte & (1 << bitOffset)) != 0;
}

pid_t iOSMemoryManager::findProcess(const char* processName) {
    // Get list of all processes
    int numberOfProcesses = proc_listpids(PROC_ALL_PIDS, 0, NULL, 0);
    if (numberOfProcesses <= 0) return -1;
    
    std::vector<pid_t> pids(numberOfProcesses);
    proc_listpids(PROC_ALL_PIDS, 0, pids.data(), numberOfProcesses * sizeof(pid_t));
    
    // Search for process by name
    for (pid_t pid : pids) {
        char name[PROC_PIDPATHINFO_MAXSIZE];
        if (proc_name(pid, name, sizeof(name)) > 0) {
            if (strstr(name, processName) != nullptr) {
                return pid;
            }
        }
    }
    
    return -1;
}

uint64_t iOSMemoryManager::getImageBase(const char* imageName) {
    // For iOS jailbreak tweaks, this would typically involve:
    // 1. Reading the process memory maps
    // 2. Finding the main executable or specific dylib
    // 3. Returning its base address
    
    // This is a simplified implementation - in practice, you'd need to:
    // - Parse the mach-o header
    // - Walk through loaded images using dyld functions
    // - Find the specific image base address
    
    // For now, return a placeholder that would be determined during runtime
    return 0x100000000; // Typical iOS app base address on ARM64
}

void iOSMemoryManager::cleanup() {
    if (targetTask != MACH_PORT_NULL) {
        mach_port_deallocate(mach_task_self(), targetTask);
        targetTask = MACH_PORT_NULL;
    }
    targetPID = 0;
}

// iOS-specific initialization function that would be called from main.mm
extern "C" bool initializeiOSDriver(const char* targetProcessName) {
    if (g_iosMemory) {
        delete g_iosMemory;
    }
    
    g_iosMemory = new iOSMemoryManager();
    bool success = g_iosMemory->initialize(targetProcessName);
    
    if (!success) {
        delete g_iosMemory;
        g_iosMemory = nullptr;
        return false;
    }
    
    return true;
}

// Cleanup function
extern "C" void cleanupiOSDriver() {
    if (g_iosMemory) {
        g_iosMemory->cleanup();
        delete g_iosMemory;
        g_iosMemory = nullptr;
    }
}