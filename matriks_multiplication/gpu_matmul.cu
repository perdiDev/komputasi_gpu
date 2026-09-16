#include <iostream>
#include <chrono>

__global__ void gpuMatMul(float* A, float* B, float* C, int N) {
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    if (row < N && col < N) {
        float sum = 0.0f;
        for (int k = 0; k < N; ++k) {
            sum += A[row * N + k] * B[k * N + col];
        }
        C[row * N + col] = sum;
    }
}

int main() {
    int N = 256;
    size_t bytes = N * N * sizeof(float);
    float *A, *B, *C;

    cudaMallocManaged(&A, bytes);
    cudaMallocManaged(&B, bytes);
    cudaMallocManaged(&C, bytes);

    // Inisialisasi
    for (int i = 0; i < N * N; ++i) {
        A[i] = 1.0f; B[i] = 2.0f; C[i] = 0.0f;
    }

    dim3 threads(16, 16);
    dim3 blocks((N + 15) / 16, (N + 15) / 16);

    std::cout << "Memulai perhitungan GPU dengan N = " << N << "...\n";
    auto start = std::chrono::high_resolution_clock::now();
    
    gpuMatMul<<<blocks, threads>>>(A, B, C, N);
    cudaDeviceSynchronize(); // Wajib: tunggu GPU selesai sebelum menghentikan timer
    
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double, std::milli> duration = end - start;
    std::cout << "Selesai! Waktu GPU: " << duration.count() << " ms\n";

    cudaFree(A); cudaFree(B); cudaFree(C);
    return 0;
}
