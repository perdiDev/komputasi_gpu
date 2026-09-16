#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"
#include <iostream>
#include <chrono>

// Fungsi CPU untuk mengubah RGB ke Grayscale
void convertToGrayscaleCPU(unsigned char* img, unsigned char* grayImg, int width, int height, int channels) {
    for (int i = 0; i < width * height; ++i) {
        int r = img[i * channels];
        int g = img[i * channels + 1];
        int b = img[i * channels + 2];
        // Rumus standar luminance
        grayImg[i] = (unsigned char)(0.299 * r + 0.587 * g + 0.114 * b);
    }
}

int main() {
    int width, height, channels;
    // Load gambar
    unsigned char* img = stbi_load("sampel.jpg", &width, &height, &channels, 3);
    if (img == NULL) {
        std::cout << "Gagal memuat gambar!" << std::endl;
        return -1;
    }

    size_t img_size = width * height;
    unsigned char* grayImg = new unsigned char[img_size];

    auto start = std::chrono::high_resolution_clock::now();
    
    convertToGrayscaleCPU(img, grayImg, width, height, 3);
    
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double, std::milli> duration = end - start;

    std::cout << "Waktu eksekusi CPU: " << duration.count() << " ms\n";

    // Simpan hasil
    stbi_write_jpg("hasil_cpu.jpg", width, height, 1, grayImg, 100);

    stbi_image_free(img);
    delete[] grayImg;
    return 0;
}
