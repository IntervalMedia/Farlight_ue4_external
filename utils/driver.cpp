// MemoryManager.h
// Accessing memory in this way requires proper entitlements, such as com.apple.security.get-task-allow, on iOS.
#import <mach/mach.h>
#import <mach-o/dyld.h>
#import <mach-o/loader.h>

class MemoryManager {
public:
    bool read_virtual_memory(vm_address_t address, void* buffer, size_t size);
    bool write_virtual_memory(vm_address_t address, const void* buffer, size_t size);
    uintptr_t find_image_base(const char* imageName);
};

// MemoryManager.mm
#import "MemoryManager.h"

bool MemoryManager::read_virtual_memory(vm_address_t address, void* buffer, size_t size) {
    mach_vm_size_t bytesRead = 0;
    kern_return_t result = vm_read_overwrite(
        mach_task_self(), // Current task
        address,          // Address to read
        size,             // Number of bytes to read
        (vm_address_t)buffer, // Buffer to store the data
        &bytesRead);      // Actual bytes read

    return result == KERN_SUCCESS && bytesRead == size;
}

bool MemoryManager::write_virtual_memory(vm_address_t address, const void* buffer, size_t size) {
    // Temporarily change memory protection to allow writing
    vm_prot_t originalProtection;
    kern_return_t result = vm_protect(
        mach_task_self(), // Current task
        address,          // Memory address
        size,             // Size of the memory region
        false,            // Set to false for the enclosing region
        VM_PROT_WRITE | VM_PROT_READ // Allow write and read
    );

    if (result != KERN_SUCCESS) {
        return false; // Failed to update memory protection
    }

    // Perform the write using vm_write
    result = vm_write(
        mach_task_self(), // Current task
        address,          // Memory address to write to
        (vm_offset_t)buffer, // Data to write
        (mach_msg_type_number_t)size // Number of bytes to write
    );

    // Restore original memory protection
    vm_protect(
        mach_task_self(), // Current task
        address,
        size,
        false,
        originalProtection
    );

    return result == KERN_SUCCESS;
}

uintptr_t MemoryManager::find_image_base(const char* imageName) {
    for (uint32_t i = 0; i < _dyld_image_count(); ++i) {
        const char* currentImageName = _dyld_get_image_name(i);
        if (strstr(currentImageName, imageName)) {
            const struct mach_header* header = _dyld_get_image_header(i);
            return (uintptr_t)header;
        }
    }
    return 0; // Image not found
}

/* 

void exampleUsage() {
    MemoryManager memoryManager;

    // Reading memory
    uint8_t buffer[16];
    if (memoryManager.read_virtual_memory(0x1000, buffer, sizeof(buffer))) {
        printf("Memory read successfully\n");
    } else {
        printf("Memory read failed\n");
    }

    // Writing memory
    uint8_t dataToWrite[16] = {0x01, 0x02, 0x03, 0x04};
    if (memoryManager.write_virtual_memory(0x2000, dataToWrite, sizeof(dataToWrite))) {
        printf("Memory written successfully\n");
    } else {
        printf("Memory write failed\n");
    }

    // Finding the base address of a Mach-O image
    uintptr_t imageBase = memoryManager.find_image_base("libexample.dylib");
    if (imageBase) {
        printf("Image base found at: 0x%lx\n", imageBase);
    } else {
        printf("Image not found\n");
    }
}

 */


