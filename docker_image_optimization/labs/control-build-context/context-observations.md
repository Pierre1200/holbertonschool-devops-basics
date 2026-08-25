# Context Observations

## 1. Context Size Comparison
- **Before (`context-lab:before`)**: 2.10 MB
- **After (`context-lab:after`)**: 174 B

## 2. Runtime Results
- **Before (`context-lab:before`)**: Local-only data detected in container.
- **After (`context-lab:after`)**: `context-clean`

## 3. Impact of `.dockerignore` on `COPY` Instructions
The `.dockerignore` file acts at the client level before the build context is packaged and sent to the Docker daemon (or BuildKit). 

Because excluded files are never included in the transferred context archive, they are physically non-existent from the build engine's perspective. When a `COPY . .` or `ADD` instruction runs inside the `Dockerfile`, it can only source files that exist within the received build context. 

Therefore, `.dockerignore` does not merely optimize network transfer speed and build performance; it strictly controls file availability, ensuring sensitive, temporary, or unneeded files (such as `.git`, `.env`, logs, or test reports) cannot be copied into any image layer.