# Docker with Bitwarden Secrets Manager CLI (bws)

This repository automatically builds and publishes a Docker image containing both the `docker` CLI and the Bitwarden Secrets Manager CLI (`bws`).

## Images Published

- **Runtime Image:** `ghcr.io/alainbrown/docker-bws:latest` - The final runtime image based on `docker:latest` containing both `docker` and `bws`.

## Prerequisites

To enable GitHub Container Registry (GHCR) publishing:
1. Go to your repository settings on GitHub.
2. Navigate to **Settings** > **Actions** > **General**.
3. Scroll down to **Workflow permissions** and select **Read and write permissions**.
4. Save the changes. The workflows will automatically authenticate using the standard `GITHUB_TOKEN`.

## Automatic Builds

The images are designed to stay automatically up to date. The workflow triggers on:
- Pushes to the `main` branch.
- An hourly cron schedule.

**Idempotency Check:** Before building, the workflow compares the upstream versions (the `docker:latest` digest on Docker Hub and the `bws` version on crates.io) against the labels on your currently published image. It skips the build entirely if nothing has changed.

You can also trigger a build manually using the "Run workflow" button in the GitHub Actions tab.

## Pulling and Using the Image

Pull the latest image from GHCR:

```bash
docker pull ghcr.io/alainbrown/docker-bws:latest
```

Verify that both CLI tools are available:

```bash
docker run --rm ghcr.io/alainbrown/docker-bws:latest docker --version
docker run --rm ghcr.io/alainbrown/docker-bws:latest bws --version
```

### Using in GitHub Actions

You can use this image natively in GitHub Actions to run jobs that need both Docker and `bws`:

```yaml
jobs:
  my_job:
    runs-on: ubuntu-latest
    container: ghcr.io/alainbrown/docker-bws:latest
    steps:
      - run: bws --version
      - run: docker --version
```

### Using in GitLab CI

```yaml
my_job:
  image: ghcr.io/alainbrown/docker-bws:latest
  script:
    - bws --version
    - docker --version
```

## Design Decisions

- **Alpine Base & Multi-stage Builds**: We compile `bws` on `rust:alpine` in a builder stage to ensure maximum compatibility with the `docker:latest` base image (which is also Alpine-based). This avoids dynamic linking errors that commonly occur when mixing glibc and musl.
- **Single Runtime Artifact**: We use a multi-stage Dockerfile to keep the final image minimal, extracting only the compiled `bws` binary into the `docker:latest` environment.
