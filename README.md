# kaniko-action 

> [GitHub Action](https://github.com/features/actions) for [Kaniko](https://github.com/GoogleContainerTools/kaniko)


kaniko is a tool to build container images from a Dockerfile, inside a container or Kubernetes cluster.

kaniko doesn't depend on a Docker daemon and executes each command within a Dockerfile completely in userspace.
This enables building container images in environments that can't easily or securely run a Docker daemon, such as a standard Kubernetes cluster.

This action allow you to build and push a Docker image using Kaniko in GitHub Actions. It's compatible with the Docker's official actions such as docker/login-action or docker/metadata-action and also support GKE Workload identity as a keyless authentication method to build and push image to a Google Container registry.

_If you are interested in contributing, see [CONTRIBUTING.md](CONTRIBUTING.md)._

### _🚨 NOTE: kaniko and this github action is not an officially supported Google product🚨_


## Table of Contents

- [Usage](#usage)
  - [Workflow](#workflow)
- [Customizing](#customizing)
  - [Inputs](#inputs)

## Usage

### Workflow

If available, this action will provide Docker Credentials to kaniko from `~/.docker/config.json`. 

If a `config.json` file is not provided, kaniko will attempt to use other authentication mechanisms such as workload identity to GKE for authentication against the remote registry .

To build and push a container image to GitHub Container Registry,

```yaml
jobs:
  build:
    steps:
      - uses: actions/checkout@v2

      - uses: docker/metadata-action@v3
        id: metadata
        with:
          images: ghcr.io/${{ github.repository }}

      - uses: docker/login-action@v1
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Kaniko build & push
          uses: bymarshall/kaniko-action@main
          with:
            push: true
            tags: ${{ steps.metadata.outputs.tags }}
            labels: ${{ steps.metadata.outputs.labels }}
```
