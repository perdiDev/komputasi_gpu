#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"
#include <iostream>
#include <chrono>

// Kernel GPU untuk memproses gambar
__global__ void convertToGrayscaleGPU(unsigned char* img, unsigned char* grayImg, int width, int height, int channels) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x < width && y < height) {
        int idx = y * width + x;
        int r = img[idx * channels];
        int g = img[idx * channels + 1];
        int b = img[idx * channels + 2];
        grayImg[idx] = (unsigned char)(0.299 * r + 0.587 * g + 0.114 * b);
    }
}

int main() {
    int width, height, channels;
    unsigned char* h_img = stbi_load("sampel.jpg", &width, &height, &channels, 3);
    if (h_img == NULL) return -1;

    size_t img_size_color = width * height * 3;
    size_t img_size_gray = width * height * 1;
    
    unsigned char* h_grayImg = new unsigned char[img_size_gray];
    unsigned char *d_img, *d_grayImg;

    // Alokasi memori di GPU
    cudaMalloc(&d_img, img_size_color);
    cudaMalloc(&d_grayImg, img_size_gray);

    // Copy data dari Host (CPU) ke Device (GPU)
    cudaMemcpy(d_img, h_img, img_size_color, cudaMemcpyHostToDevice);

    // Atur arsitektur blok dan grid (2D karena ini gambar)
    dim3 blockSize(16, 16);
    dim3 gridSize((width + blockSize.x - 1) / blockSize.x, (height + blockSize.y - 1) / blockSize.y);

    auto start = std::chrono::high_resolution_clock::now();
    
    // Panggil kernel
    convertToGrayscaleGPU<<<gridSize, blockSize>>>(d_img, d_grayImg, width, height, 3);
    cudaDeviceSynchronize(); // Tunggu GPU selesai
    
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double, std::milli> duration = end - start;

    // Copy kembali hasilnya ke CPU
    cudaMemcpy(h_grayImg, d_grayImg, img_size_gray, cudaMemcpyDeviceToHost);

    std::cout << "Waktu eksekusi GPU: " << duration.count() << " ms\n";

    stbi_write_jpg("hasil_gpu.jpg", width, height, 1, h_grayImg, 100);

    // Bersihkan memori
    cudaFree(d_img);
    cudaFree(d_grayImg);
    stbi_image_free(h_img);
    delete[] h_grayImg;

    return 0;
}
