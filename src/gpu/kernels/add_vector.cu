#include <algorithm>

#include "bipp//config.h"
#include "gpu/kernels/add_vector.hpp"
#include "gpu/util/kernel_launch_grid.hpp"
#include "gpu/util/runtime.hpp"
#include "gpu/util/runtime_api.hpp"

namespace bipp {
namespace gpu {

template <typename T>
__global__ static void add_vector_real_to_complex_kernel(std::size_t n,
                                                         const api::ComplexType<T>* __restrict__ a,
                                                         T* __restrict__ b) {
  for (std::size_t i = threadIdx.x + blockIdx.x * blockDim.x; i < n; i += gridDim.x * blockDim.x) {
    b[i] += a[i].x;
  }
}

template <typename T>
auto add_vector_real_to_complex(Queue& q, std::size_t n, const api::ComplexType<T>* a, T* b)
    -> void {
  constexpr int blockSize = 256;

  const dim3 block(std::min<int>(blockSize, q.device_prop().maxThreadsDim[0]), 1, 1);
  const auto grid = kernel_launch_grid(q.device_prop(), {n, 1, 1}, block);
  api::launch_kernel(add_vector_real_to_complex_kernel<T>, grid, block, 0, q.stream(), n, a, b);
}

template auto add_vector_real_to_complex<float>(Queue& q, std::size_t n,
                                                const api::ComplexType<float>* a, float* b) -> void;

template auto add_vector_real_to_complex<double>(Queue& q, std::size_t n,
                                                 const api::ComplexType<double>* a, double* b)
    -> void;

}  // namespace gpu
}  // namespace bipp
