# Base Image Selection Decision

## 1. Candidate Measurements

- **`base-lab:ubuntu`**: 28890847 bytes
- **`base-lab:debian-slim`**: 28120333 bytes
- **`base-lab:alpine`**: 4123676 bytes

## 2. Justification for Selected Base (`alpine`)

`alpine:3.20` was selected because it is the smallest candidate image that fully satisfies all stated runtime requirements:
- **Minimal Footprint**: It drastically reduces overall image size (4.1 MB vs. ~28 MB for Debian/Ubuntu), saving disk space and network bandwidth.
- **Runtime Compatibility**: It natively provides a POSIX-compliant shell (`/bin/sh` via BusyBox) required to run the shell script without installing additional system packages.
- **Reduced Attack Surface**: Shipping fewer pre-installed system binaries inherently minimizes exposure to software vulnerabilities (CVEs).

## 3. Scenario Where Debian-Slim is Safer Than Alpine

While Alpine offers a smaller footprint, **`debian-slim` is safer when an application depends on the standard GNU C library (`glibc`)**. 

Alpine relies on **`musl libc`**. If an application requires precompiled C/C++ binaries, Python packages with native C extensions, or Go applications built using `cgo`, differences between `musl` and `glibc` can cause subtle runtime bugs, memory allocation issues, or unexpected crashes. In these scenarios, `debian-slim` guarantees native `glibc` compatibility while remaining lightweight.

## 4. Versioned Tag vs. Immutable Digest Reference

- **Versioned Tag (e.g., `alpine:3.20`)**: Improves build stability over mutable tags like `latest` by pinning to a specific release line. However, tags remain mutable—upstream maintainers can publish updated image layers under the same tag to apply security patches.
- **Digest Reference (e.g., `alpine@sha256:...`)**: Points directly to the unique cryptographic SHA-256 hash of the image content. Using a digest guarantees absolute immutability and 100% build reproducibility, ensuring the base image layer content never changes regardless of upstream updates.