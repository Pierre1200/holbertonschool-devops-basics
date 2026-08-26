# Layer Bloat Observations

## 1. Image Size Comparison

- **Unoptimized Image (`layer-lab:unoptimized`)**: 10417782 bytes
- **Optimized Image (`layer-lab:optimized`)**: 4123338 bytes
- **Saved Space Difference**: 6294444 bytes (Reduction >= 5 MiB)

## 2. Bloat Layer Identification

In `Dockerfile.unoptimized`, the layer created by the instruction copying the binary payload (`cp /mnt/build-payload.bin /tmp/build-payload.bin`) permanently retained the payload file. 

Analyzing `docker image history layer-lab:unoptimized` confirms that this individual `RUN` layer stored ~6.3 MB of immutable data.

## 3. Why `rm` in a Later Layer Cannot Reclaim Space

Docker uses Union File Systems (such as OverlayFS) composed of stacked, immutable (read-only) image layers:
1. **Layer Immutability**: Once an instruction finishes executing, its layer is sealed and rendered read-only. No subsequent operation can modify or shrink an existing layer.
2. **Copy-on-Write and Whiteout Files**: When a deletion command like `rm -f /tmp/build-payload.bin` is executed in a subsequent `RUN` instruction, Docker does not erase the file from the underlying lower layer where it was created. Instead, it writes a small **whiteout file** in the new layer that masks the deleted file in the merged view.
3. **Runtime vs. Storage Impact**: The file becomes invisible inside running containers, but the payload remains permanently embedded in the earlier immutable layer, consuming disk space and network bandwidth during registry pulls and pushes.

## 4. Optimization Mechanism

In `Dockerfile.optimized`, chaining the operations within a single `RUN` instruction (`cp ... && sha256sum ... && rm ...`) ensures that the temporary payload file is created, processed, and deleted before the layer execution completes. As a result, the temporary file is never committed to any Docker layer, completely preventing layer bloat at its source.