#' Get GPU Utilization
#' 
#' Retrieves GPU core and memory utilization percentages for all NVIDIA GPUs.
#' 
#' @return A named list with GPU and memory utilization for each GPU.
#' @export
get_gpu_utilization <- function() {
  .Call("get_gpu_utilization")
}

#' Monitor System Resources
#' 
#' Monitors RAM, CPU (per-core), and GPU utilization at 0.1s intervals.
#' 
#' @param prefix File prefix for collectl output.
#' @param interval Monitoring interval in seconds (default 0.1).
#' @return A list with collectl ID and start time.
#' @export
start_monitor <- function(prefix, interval = 0.1) {
  library(Rcollectl)
  id <- cl_start(prefix)
  return(list(id = id, start_time = Sys.time()))
}

#' Stop Monitoring and Plot
#' 
#' Stops monitoring, collects data, and plots CPU, RAM, and GPU usage.
#' 
#' @param monitor List from start_monitor.
#' @param timestamps List of timestamps and labels.
#' @return Data frame with collected metrics.
#' @export
stop_and_plot <- function(monitor, timestamps = NULL) {
  library(Rcollectl)
  library(ggplot2)
  library(dplyr)
  
  # Stop collectl
  cl_stop(monitor$id)
  path <- cl_result_path(monitor$id)
  usage_df <- cl_parse(path)
  
  # Collect GPU data
  gpu_data <- data.frame(
    Time = seq(monitor$start_time, by = 0.1, length.out = nrow(usage_df)),
    GPU_Util = NA, GPU_Mem = NA
  )
  for (i in 1:nrow(usage_df)) {
    gpu <- get_gpu_utilization()
    if (length(gpu) > 0) {
      gpu_data$GPU_Util[i] <- gpu[[1]]["gpu"]
      gpu_data$GPU_Mem[i] <- gpu[[1]]["memory"]
    }
  }
  
  # Merge GPU data with collectl data
  usage_df <- usage_df %>%
    mutate(Time = seq(monitor$start_time, by = 0.1, length.out = nrow(usage_df))) %>%
    left_join(gpu_data, by = "Time")
  
  # Plot
  p <- plot_usage(usage_df) +
    geom_line(aes(x = Time, y = GPU_Util, color = "GPU Utilization")) +
    geom_line(aes(x = Time, y = GPU_Mem, color = "GPU Memory")) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))
  
  if (!is.null(timestamps)) {
    p <- p + cl_timestamp_layer(path) + cl_timestamp_label(path)
  }
  
  print(p)
  return(usage_df)
}