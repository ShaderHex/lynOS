How to compile

'''
mkdir build
nasm -f bin src/bootloader/boot.asm -o build/boot.bin
qemu-system-i386 -drive format=raw,file=build/boot.bin
```

That's it, there is no magic behind it. Make sure the compilers and qemu are installed though