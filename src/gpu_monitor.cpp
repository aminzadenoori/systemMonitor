// src/gpu_monitor.c

#include <R.h>
#include <Rinternals.h>
#include <C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v12.8/include/nvml.h>

SEXP get_gpu_utilization(void) {
  nvmlReturn_t result;
  unsigned int device_count;
  
  // Initialize NVML
  result = nvmlInit_v2();
  if (result != NVML_SUCCESS) {
    error("Failed to initialize NVML: %s", nvmlErrorString(result));
  }
  
  // Get device count
  result = nvmlDeviceGetCount(&device_count);
  if (result != NVML_SUCCESS) {
    nvmlShutdown();
    error("Failed to get device count: %s", nvmlErrorString(result));
  }
  
  // Allocate output: [gpu_util, mem_util] for each GPU
  SEXP out = PROTECT(allocVector(VECSXP, device_count));
  for (unsigned int i = 0; i < device_count; i++) {
    nvmlDevice_t device;
    result = nvmlDeviceGetHandleByIndex_v2(i, &device);
    if (result != NVML_SUCCESS) {
      nvmlShutdown();
      error("Failed to get device handle: %s", nvmlErrorString(result));
    }
    
    // Get utilization
    nvmlUtilization_t utilization;
    result = nvmlDeviceGetUtilizationRates(device, &utilization);
    if (result != NVML_SUCCESS) {
      nvmlShutdown();
      error("Failed to get utilization: %s", nvmlErrorString(result));
    }
    
    // Store results
    SEXP gpu_out = PROTECT(allocVector(REALSXP, 2));
    REAL(gpu_out)[0] = (double)utilization.gpu;
    REAL(gpu_out)[1] = (double)utilization.memory;
    
    SEXP gpu_names = PROTECT(allocVector(STRSXP, 2));
    SET_STRING_ELT(gpu_names, 0, mkChar("gpu"));
    SET_STRING_ELT(gpu_names, 1, mkChar("memory"));
    setAttrib(gpu_out, R_NamesSymbol, gpu_names);
    
    SET_VECTOR_ELT(out, i, gpu_out);
    UNPROTECT(2);
  }
  
  // Set names for GPUs
  char name[32];
  SEXP gpu_names = PROTECT(allocVector(STRSXP, device_count));
  for (unsigned int i = 0; i < device_count; i++) {
    snprintf(name, sizeof(name), "GPU_%d", i);
    SET_STRING_ELT(gpu_names, i, mkChar(name));
  }
  setAttrib(out, R_NamesSymbol, gpu_names);
  
  nvmlShutdown();
  UNPROTECT(1 + device_count * 2);
  return out;
}