from PIL import Image

# 原始的字节数据（直接复制了你提供的数据内容）
byte_data = [
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x00,
    0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0,
    0xC0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0xFF, 0xFF, 0xFF, 0x03, 0x83, 0xF3, 0x38,
    0xF3, 0x83, 0x03, 0xFF, 0xFF, 0x7F, 0x03, 0x03, 0x00, 0xC0, 0xF0, 0xF8, 0xB8, 0xBC, 0x9C, 0x9C,
    0x9C, 0x9C, 0xBC, 0xB8, 0xF8, 0xF0, 0xC0, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0xFF, 0xFF,
    0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xC0, 0xF0, 0xF8, 0x78, 0x3C, 0x1C, 0x1C,
    0x1C, 0x1C, 0x3C, 0x78, 0xFC, 0xFC, 0x00, 0x00, 0x00, 0xC0, 0xE0, 0xF0, 0x78, 0x3C, 0x1C, 0x1C,
    0x1C, 0x1C, 0x3C, 0x78, 0xF0, 0xF0, 0xC0, 0x00, 0x1C, 0xFC, 0xFC, 0xFC, 0x38, 0x1C, 0x1C, 0xFC,
    0xF8, 0xF8, 0x3C, 0x1C, 0x1C, 0xFC, 0xF8, 0xF0, 0x00, 0xC0, 0xF0, 0xF8, 0xB8, 0xBC, 0x9C, 0x9C,
    0x9C, 0x9C, 0xBC, 0xB8, 0xF8, 0xF0, 0xC0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7F, 0x7F, 0x7C, 0x1F, 0x03, 0x00,
    0x03, 0x1F, 0x7C, 0x7F, 0x7F, 0x00, 0x00, 0x00, 0x00, 0x07, 0x1F, 0x3F, 0x3D, 0x79, 0x71, 0x71,
    0x71, 0x71, 0x71, 0x71, 0x39, 0x39, 0x39, 0x00, 0x00, 0x70, 0x70, 0x70, 0x70, 0x70, 0x7F, 0x7F,
    0x7F, 0x70, 0x70, 0x70, 0x70, 0x70, 0x00, 0x00, 0x00, 0x07, 0x1F, 0x3F, 0x38, 0x78, 0x70, 0x70,
    0x70, 0x70, 0x70, 0x70, 0x38, 0x38, 0x18, 0x00, 0x00, 0x07, 0x1F, 0x3F, 0x3C, 0x78, 0x70, 0x70,
    0x70, 0x70, 0x78, 0x3C, 0x3F, 0x1F, 0x07, 0x00, 0x70, 0x7F, 0x7F, 0x7F, 0x70, 0x70, 0x00, 0x7F,
    0x7F, 0x7F, 0x70, 0x70, 0x00, 0x7F, 0x7F, 0x7F, 0x00, 0x07, 0x1F, 0x3F, 0x3D, 0x79, 0x71, 0x71,
    0x71, 0x71, 0x71, 0x71, 0x39, 0x39, 0x39, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
]

# 将字节数据转换为4 * 128的二维数组
two_d_array = [[0 for _ in range(128)] for _ in range(4)]
index = 0
for row in range(4):
    for col in range(128):
        two_d_array[row][col] = byte_data[index]
        index += 1

# 打印4 * 128二维数组的十六进制形式
print("4 * 128二维数组（十六进制形式）:")
for row in two_d_array:
    hex_row = [hex(num)[2:].zfill(2) for num in row]
    print(",".join(hex_row))

# 创建32 * 128的模拟RGB数组（用包含三个元素的元组表示RGB值，这里初始化为黑色(0, 0, 0)）
rgb_array = [[(0, 0, 0) for _ in range(128)] for _ in range(32)]

# 遍历4 * 128二维数组的每个字节的每个bit，放入32 * 128的rgb数组
for y in range(4):
    for x in range(128):
        byte_data = two_d_array[y][x]
        for bit in range(8):
            row_index = y * 8 + bit
            if (byte_data >> bit) & 1:
                # 如果bit为1，设置为白色（这里简单用(255, 255, 255)表示白色，实际可能需按RGB规范转换）
                rgb_array[row_index][x] = (255, 255, 255)
            else:
                # 如果bit为0，保持黑色(0, 0, 0)
                rgb_array[row_index][x] = (0, 0, 0)

# 打印32 * 128的模拟RGB数组的十六进制形式（这里只打印RGB三个分量合并后的十六进制值，每个像素用6位十六进制表示）
print("\n32 * 128模拟RGB数组（十六进制形式，每个像素6位十六进制表示）:")
for row in rgb_array:
    hex_row = []
    for color in row:
        r, g, b = color
        hex_value = hex((r << 16) + (g << 8) + b)[2:].zfill(6)
        hex_row.append(hex_value)
    # print(",".join(hex_row))

# 将模拟的RGB数组转换为图像
image = Image.new('RGB', (128, 32))
for y in range(32):
    for x in range(128):
        image.putpixel((x, y), rgb_array[y][x])

# 显示图像
image.show()

# 以下代码用于保存图像到文件，可根据需求选择是否使用
# 保存图像到当前目录下名为 'output.png' 的文件（可根据需求修改文件名和路径）
image.save('output.png')