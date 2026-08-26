# Multi-Stage Build Observations

## 1. Image Size Comparison

- **Single-Stage Image (`multistage-lab:single`)**: 76211717 bytes (~76.2 MB)
- **Multi-Stage Optimized Image (`multistage-lab:optimized`)**: 1271722 bytes (~1.27 MB)
- **Size Reduction**: 74939995 bytes (~98.3% reduction)

The optimized image is drastically smaller because it discards the Go SDK, package caches, temporary build artifacts, and base OS utilities, retaining exclusively the statically linked binary inside an empty `scratch` image.

## 2. Non-Root User Configuration

Inspection of the image configuration (`docker image inspect multistage-lab:optimized --format '{{.Config.User}}'`) returns:

```text
65532:65532