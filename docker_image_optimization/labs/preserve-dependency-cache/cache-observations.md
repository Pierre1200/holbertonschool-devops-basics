# Dependency Cache Observations

## 1. Issue with `Dockerfile.unoptimized`
In `Dockerfile.unoptimized`, a broad `COPY . .` instruction was executed prior to running `npm ci`. Because Docker invalidates the layer cache whenever any file copied by an instruction changes, updating a single line of application source code (such as `src/server.js`) invalidated the `COPY . .` layer. Consequently, Docker was forced to re-run the expensive `npm ci` step on every build.

## 2. Optimization Strategy in `Dockerfile.cached`
In `Dockerfile.cached`, the instruction order was restructured to separate dependency resolution from source code delivery:
1. Copy package manifests (`package.json`, `package-lock.json`) and the local package dependency (`packages/message-format/`).
2. Run `npm ci --omit=dev` to install production dependencies.
3. Copy the remaining application source (`src/`) and test files (`test/`).

## 3. Build Log Evidence (Cache Hit)
During the second build following a comment change in `src/server.js`, the dependency installation layer successfully reused the cache:

```text
# CACHED [5/7] RUN npm ci --omit=dev