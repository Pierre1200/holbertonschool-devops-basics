# Task 0 — Measure Before You Optimize

## Baseline image size
371384120 bytes (~354 MB), measured with:
`docker image inspect image-lab:baseline --format '{{.Size}}'`

## Largest non-base instruction
`COPY . .` — 8.44MB, according to `docker image history image-lab:baseline`.
This is the largest layer created by the project's own Dockerfile
(layers above it belong to the `python:3.12-bookworm` base image).

## Configured runtime user
Empty string (`""`), from:
`docker image inspect image-lab:baseline --format '{{json .Config.User}}'`
No `USER` instruction is set in the Dockerfile, so the container runs as root by default.

## Files/directories copied but unused by the running API
1. `tests/` — contains test files used during development, not required by `app.py` at runtime.
2. `docs/` — contains documentation, not imported or read by the application code.

(local-notes.txt, reports/, and results.md are also unnecessary in the image,
but two examples are sufficient here.)

## Three optimization targets with evidence

### 1. Uncontrolled build context
Evidence: `COPY . .` copies the entire project directory, including `tests/`,
`docs/`, `local-notes.txt`, and `reports/`. None of these are required to run
`app.py`, yet they add 8.44MB to the image and increase the build context
sent to the daemon. A `.dockerignore` file would exclude them.

### 2. Root user at runtime
Evidence: `docker image inspect` shows `Config.User` as an empty string,
meaning no `USER` instruction exists in `Dockerfile.baseline`. The application
therefore runs as root inside the container, which is an unnecessary
privilege for a process that only needs to serve HTTP requests.

### 3. Heavy base image
Evidence: `docker image history` shows three layers inherited from
`python:3.12-bookworm` weighing 592MB, 200MB, and 52.3MB (apt-get installs),
plus a 74.4MB Python build layer. These layers make up the vast majority of
the final 354MB image, even though `app.py` is only 1026 bytes. A slimmer
base image (e.g. `python:3.12-slim`) would likely provide the same runtime
capability with a much smaller footprint.