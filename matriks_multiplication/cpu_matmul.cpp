#include <iostream>
#include <vector>
#include <chrono>

void cpuMatMul(const std::vector<float>& A, const std::vector<float>& B, std::vector<float>& C, int N) {
    for (int row = 0; row < N; ++row) {
        for (int col = 0; col < N; ++col) {
            float sum = 0.0f;
            for (int k = 0; k < N; ++k) {
                sum += A[row * N + k] * B[k * N + col];
            }
            C[row * N + col] = sum;
        }
    }
}

int main() {
    int N = 256;
    std::vector<float> A(N * N, 1.0f);
    std::vector<float> B(N * N, 2.0f);
    std::vector<float> C(N * N, 0.0f);

    std::cout << "Memulai perhitungan CPU dengan N = " << N << "...\n";
    auto start = std::chrono::high_resolution_clock::now();
    
    cpuMatMul(A, B, C, N);
    
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double, std::milli> duration = end - start;
    std::cout << "Selesai! Waktu CPU: " << duration.count() << " ms\n";

    return 0;
}
