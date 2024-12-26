"""_summary_
convert picture to rgb565 array and output file
"""
import sys
sys.path.append("/home/loong/.local/lib/python3.10/site-packages")

from PIL import Image, ImageDraw, ImageFont
import numpy as np


# 将RGB颜色转换为RGB565格式，确保数据类型和范围正确
def rgb_to_rgb565(r, g, b):
    """
    把常规的RGB颜色值转换为RGB565格式。
    先确保RGB值在合法范围（0 - 255）内，再通过位运算提取并组合各通道位，
    整个过程使用np.uint16类型来处理数据，避免出现数据类型范围冲突问题。
    """
    r = np.uint16(max(0, min(255, r)))
    g = np.uint16(max(0, min(255, g)))
    b = np.uint16(max(0, min(255, b)))
    r5 = np.uint16((r >> 3) & 0x1F)
    g6 = np.uint16((g >> 2) & 0x3F)
    b5 = np.uint16((b >> 3) & 0x1F)
    return np.uint16((r5 << 11) | (g6 << 5) | b5)


# 根据RGB565值转回RGB格式（用于绘制图片），确保还原后的RGB值范围合法
def rgb565_to_rgb(rgb565_value):
    """
    将RGB565值逆向转换回常规的RGB格式，
    通过位运算提取各通道位，再经过移位和组合还原RGB值，
    并对还原后的RGB值进行范围检查，确保在0 - 255之间。
    """
    r5 = (rgb565_value >> 11) & 0x1F
    g6 = (rgb565_value >> 5) & 0x3F
    b5 = rgb565_value & 0x1F
    r = np.uint16((r5 << 3) | (r5 >> 2))
    g = np.uint16((g6 << 2) | (g6 >> 4))
    b = np.uint16((b5 << 3) | (b5 >> 2))
    r = np.uint16(max(0, min(255, r)))
    g = np.uint16(max(0, min(255, g)))
    b = np.uint16(max(0, min(255, b)))
    return r, g, b


# 打开图片并转换为RGB565数组，增加更多调试检查逻辑
def image_to_rgb565_array(image_path):
    """
    读取指定路径的图片，转换为RGB模式后，将其像素的RGB值转换为RGB565值，存储在数组中。
    过程中添加了多处调试打印和检查逻辑，确保像素处理的准确性。
    """
    try:
        image = Image.open(image_path).convert("RGB")
    except FileNotFoundError:
        print(f"图片文件 {image_path} 不存在，请检查路径是否正确！")
        return None
    width, height = image.size
    print(f"图片尺寸：宽度 {width}，高度 {height}")
    rgb_array = np.array(image)
    total_pixels = width * height
    processed_pixels = 0
    rgb565_array = np.zeros((height, width), dtype=np.uint16)
    for y in range(height):
        for x in range(width):
            r, g, b = rgb_array[y, x]
            print(f"正在处理坐标 ({x}, {y}) 处的像素，RGB值为: ({r}, {g}, {b})")
            rgb565_array[y, x] = rgb_to_rgb565(r, g, b)
            processed_pixels += 1
            assert processed_pixels <= total_pixels, "处理的像素数超过图片总像素数，可能存在重复处理！"
    assert processed_pixels == total_pixels, "存在像素遗漏未处理的情况！"
    return rgb565_array


# 以C语言风格将RGB565数组输出到文件，方便后续使用
def print_rgb565_array_as_c_style_to_file(rgb565_array, file_path):
    """
    按照C语言二维数组的格式，将RGB565数组以十六进制形式输出到指定文件中，
    便于将文件内容复制到C语言代码中使用。
    """
    try:
        with open(file_path, 'w') as file:
            height, width = rgb565_array.shape
            file.write("uint16_t image_array[{}][{}] = {{\n".format(height, width))
            for y in range(height):
                file.write("    {")
                for x in range(width):
                    if x!= 0:
                        file.write(", ")
                    file.write("0x{:04X}".format(rgb565_array[y, x]))
                if y!= height - 1:
                    file.write("},\n")
                else:
                    file.write("}\n")
            file.write("};\n")
    except IOError:
        print(f"无法写入文件 {file_path}，请检查文件路径或权限是否正确！")


# 根据RGB565数组绘制图片，增加颜色范围检查
def draw_image_from_rgb565(rgb565_array):
    """
    根据给定的RGB565数组创建图片对象，并将数组中的值转换回RGB格式后，
    设置到图片相应像素位置上，绘制出图片，过程中确保还原的RGB值范围合法。
    """
    height, width = rgb565_array.shape
    image = Image.new("RGB", (width, height))
    draw = ImageDraw.Draw(image)
    for y in range(height):
        for x in range(width):
            rgb565_value = rgb565_array[y, x]
            r, g, b = rgb565_to_rgb(rgb565_value)
            r = np.uint16(max(0, min(255, r)))
            g = np.uint16(max(0, min(255, g)))
            b = np.uint16(max(0, min(255, b)))
            draw.point((x, y), fill=(r, g, b))
    return image


if __name__ == "__main__":
    image_path = "input.png"  # 务必替换为实际的图片路径
    output_file_path = "rgb565_array.txt"  # 输出文件路径，可根据需要修改
    rgb565_array = image_to_rgb565_array(image_path)
    if rgb565_array is not None:
        print_rgb565_array_as_c_style_to_file(rgb565_array, output_file_path)
        drawn_image = draw_image_from_rgb565(rgb565_array)
        drawn_image.show()
