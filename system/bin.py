# # 获取用户输入的文件大小（单位：KB）
# try:
#     size_in_kb = int(input("请输入要生成的文件大小（单位：KB）："))
# except ValueError:
#     print("输入无效，请输入一个有效的整数。")
# else:
    # 计算文件大小（单位：字节）
size_in_kb = 8*1024
file_size = size_in_kb * 1024

# 生成一个字节对象，每个字节的值为 0xFF
data = bytes([0xFF] * file_size)

# 生成文件名
file_name = f"{size_in_kb}k_ff.bin"

# 以二进制写入模式打开文件
with open(file_name, 'wb') as f:
    # 将数据写入文件
    f.write(data)

print(f"文件生成成功，文件名为 {file_name}")

