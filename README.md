
# GPU Monitoring Package

R package for monitoring NVIDIA GPU, CPU, and RAM usage using NVML and `Rcollectl`.

## Installation

### Prerequisites
- NVIDIA GPU with CUDA Toolkit 12.8
- NVML at `C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v12.8/include/`
- R packages: `Rcollectl`, `ggplot2`, `dplyr`

### Steps
```bash
git clone <repository-url>
R -e "devtools::install()"
```


## Usage

### Functions
- `get_gpu_utilization()`: Returns GPU core/memory utilization as a named list
- `start_monitor(prefix, interval = 0.1)`: Starts monitoring; returns collectl ID and start time
- `stop_and_plot(monitor, timestamps = NULL)`: Stops monitoring, plots usage, returns data frame

### Example
```R
library(packageName)
monitor <- start_monitor("test")
result <- stop_and_plot(monitor)
```

## Files
- `src/gpu_monitor.c`: NVML interface
- `R/`: R functions
- `DESCRIPTION`, `NAMESPACE`, `man/`: Package metadata/docs
- `Read-and-delete-me`: Placeholder (delete after setup)

## Notes
- Update CUDA path for non-Windows systems
- Requires `Rcollectl` for CPU/RAM data

## License
MIT License
