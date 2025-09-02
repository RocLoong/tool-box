#!/bin/bash

# 确保脚本以root权限运行
if [ "$(id -u)" != "0" ]; then
   echo "该脚本必须以root权限运行" 1>&2
   exit 1
fi

# 定义镜像文件的名称和路径
IMAGE_NAME="ubuntu_image.img"
IMAGE_PATH="/mnt/ssd/$IMAGE_NAME"

# 定义系统磁盘设备，这里假设是/dev/sda
DISK_DEVICE="/dev/nvme0n1p6"

# 显示脚本将要执行的操作
echo "开始创建系统镜像..."
echo "镜像将被保存到: $IMAGE_PATH"

# 使用dd命令创建镜像
# 注意: bs=4M 是块大小，可以根据需要调整
# 注意: 这个操作可能需要一些时间，取决于磁盘的大小
dd if=$DISK_DEVICE of=$IMAGE_PATH bs=4M status=progress conv=noerror,sync

# 检查dd命令是否成功执行
if [ $? -eq 0 ]; then
    echo "镜像创建成功！"
else
    echo "镜像创建失败！" 1>&2
    exit 1
fi

# 镜像文件现在已经保存在当前目录下
echo "镜像文件已保存到: $IMAGE_PATH"
