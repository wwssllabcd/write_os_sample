CC=gcc
LD=ld
LDFILE=solrex_x86.ld #使用上面提供的连接脚本 solrex_x86.ld
OBJCOPY=objcopy

all: boot.img

# Step 1: gcc 调用 as 将 boot.S 编译成目标文件 boot.o
boot.o: boot.S
	$(CC) -c boot.S

# Step 2: ld 调用连接脚本 solrex_x86.ld 将 boot.o 连接成可执行文件 boot.elf
boot.elf: boot.o
	$(LD) boot.o -o boot.elf -e c -T$(LDFILE)

# Step 3: objcopy 移除 boot.elf 中没有用的 section(.pdr,.comment,.note),
# strip 掉所有符号信息，输出为二进制文件 boot.bin 。
boot.bin : boot.elf
	@$(OBJCOPY) -R .pdr -R .comment -R.note -S -O binary boot.elf boot.bin

# Step 4: 生成可启动软盘镜像。
boot.img: boot.bin
	@dd if=boot.bin of=boot.img bs=512 count=1 #用 boot.bin 生成镜像文件第一个扇区
# 在 bin 生成的镜像文件后补上空白，最后成为合适大小的软盘镜像
	@dd if=/dev/zero of=boot.img skip=1 seek=1 bs=512 count=2879

clean:
	@rm -rf boot.o boot.elf boot.bin boot.img