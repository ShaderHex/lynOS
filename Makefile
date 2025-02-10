# Tools
NASM    = nasm
GCC     = gcc        # or replace with your i386-elf-gcc if available
LD      = ld
QEMU    = qemu-system-i386

# Flags
CFLAGS  = -m32 -ffreestanding -O2 -Wall -Wextra -nostdlib
ASMFLAGS= -f elf32
LDFLAGS = -m elf_i386 -T linker.ld

# Directories
BOOTLOADER_DIR = bootloader
KERNEL_DIR     = kernel
BUILD_DIR      = build

# Source Files
BOOTLOADER_SRC    = $(BOOTLOADER_DIR)/bootloader.asm
KERNEL_ENTRY_SRC  = $(KERNEL_DIR)/kernel_entry.asm
KERNEL_C_SRC      = $(KERNEL_DIR)/kernel.c
LINKER_SCRIPT     = linker.ld

# Build Output Files (placed in build/)
BOOTLOADER_BIN    = $(BUILD_DIR)/bootloader.bin
KERNEL_ENTRY_OBJ  = $(BUILD_DIR)/kernel_entry.o
KERNEL_OBJ        = $(BUILD_DIR)/kernel.o
KERNEL_BIN        = $(BUILD_DIR)/kernel.bin
OS_IMAGE          = $(BUILD_DIR)/os-image.bin

.PHONY: all clean run

all: $(OS_IMAGE)

# Ensure the build directory exists
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Assemble bootloader into a flat binary (must be exactly 512 bytes with boot signature)
$(BOOTLOADER_BIN): $(BOOTLOADER_SRC) | $(BUILD_DIR)
	$(NASM) -f bin $(BOOTLOADER_SRC) -o $(BOOTLOADER_BIN)

# Assemble the kernel entry (32-bit)
$(KERNEL_ENTRY_OBJ): $(KERNEL_ENTRY_SRC) | $(BUILD_DIR)
	$(NASM) $(ASMFLAGS) $(KERNEL_ENTRY_SRC) -o $(KERNEL_ENTRY_OBJ)

# Compile the C kernel code (32-bit, freestanding)
$(KERNEL_OBJ): $(KERNEL_C_SRC) | $(BUILD_DIR)
	$(GCC) $(CFLAGS) -c $(KERNEL_C_SRC) -o $(KERNEL_OBJ)

# Link kernel entry and C kernel into one binary at the load address (0x10000)
$(KERNEL_BIN): $(KERNEL_ENTRY_OBJ) $(KERNEL_OBJ) $(LINKER_SCRIPT) | $(BUILD_DIR)
	$(LD) $(LDFLAGS) $(KERNEL_ENTRY_OBJ) $(KERNEL_OBJ) -o $(KERNEL_BIN)

# Create the final OS image by concatenating the bootloader and the kernel binary.
$(OS_IMAGE): $(BOOTLOADER_BIN) $(KERNEL_BIN) | $(BUILD_DIR)
	cat $(BOOTLOADER_BIN) $(KERNEL_BIN) > $(OS_IMAGE)

# Run the OS image in QEMU
run: $(OS_IMAGE)
	$(QEMU) -drive format=raw,file=$(OS_IMAGE)

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)
