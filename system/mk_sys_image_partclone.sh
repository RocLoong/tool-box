#!/bin/bash


# 源分区设备，需根据实际情况修改
# GParted 显示的分区路径，例如 /dev/nvme0n1p6
SOURCE_PARTITION="/dev/nvme0n1p6"
# 目标镜像文件的路径和名称
TARGET_IMAGE="/dev/nvme0n1p3/ubuntu_image.img"


# 确保 partclone 已安装
if ! command -v partclone.ext4 &> /dev/null; then
    echo "partclone 未安装，正在尝试安装..."
    sudo apt-get update
    sudo apt-get install -y partclone
    if [ $? -ne 0 ]; then
        echo "partclone 安装失败，请手动安装。"
        exit 1
    fi
fi


# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
    echo "请以 root 权限运行此脚本。"
    exit 1
fi

# 开始使用 partclone 创建镜像文件
echo "开始创建镜像文件，请耐心等待..."
sudo partclone.ext4 -c -s $SOURCE_PARTITION -o $TARGET_IMAGE

# 检查复制是否成功
if [ $? -eq 0 ]; then
    echo "镜像文件创建成功，路径为：$TARGET_IMAGE"
else
    echo "镜像文件创建失败，请检查错误信息。"
fi
