# kaniko-action

> [GitHub Action](https://github.com/features/actions) for [Kaniko](https://github.com/GoogleContainerTools/kaniko)

kaniko is a tool to build container images from a Dockerfile, inside a container or Kubernetes cluster.

kaniko doesn't depend on a Docker daemon and executes each command within a Dockerfile completely in
userspace.

This enables building container images in environments that can't easily or securely run a Docker daemon,
such as a standard Kubernetes cluster.

This action allow you to build and push a Docker image using Kaniko in GitHub Actions. It's compatible with
the Docker's official actions such as docker/login-action or docker/metadata-action and also support GKE
Workload identity as a keyless authentication method to build and push image to a Google Container registry.

_If you are interested in contributing, see [CONTRIBUTING.md](CONTRIBUTING.md)._

## Table of Contents

- [Usage](#usage)
  - [Authentication](#authentication)
  - [Workflow](#workflow)
- [Customizing](#customizing)
  - [Inputs](#inputs)
- [Build performance](#build-performance)
## Usage

### Authentication

If available, this action will provide Docker Credentials to kaniko from `~/.docker/config.json`.

_**Note:** If a `config.json` file is not provided, kaniko will attempt to use other authentication mechanisms such as [workload identity for GKE](https://github.com/GoogleContainerTools/kaniko#pushing-to-gcr-using-workload-identity). This is the prefered and recommended method if you are executing this github action into a GKE Cluster, Workload identity provides a keyless authentication
mechanism against the GCR remote registry._

### Example Workflows

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

To build a docker image and analyze it for potential vulnerabilities, you can export the image to a tarball
and perform a local analysis with trivy or any other compatible container analyzer. If you want to analyze
the image without pushing it, just set `push: false`.

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
            tar_file: image.tar

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          ignore-unfixed: true
          input: image.tar
          exit-code: 1
          severity: 'CRITICAL,HIGH'
          security-checks: vuln,config
```

## Customizing

### inputs

Following inputs can be used as `step.with` keys:

| Name             | Type    | Default                            | Description                                                                    |
|------------------|---------|------------------------------------|--------------------------------------------------------------------------------|
| `context`        | String  | `/github/workspace`                | Relative folder path to the build context. It must be in the current workspace.|
| `file`           | String  | `Dockerfile`                       | Relative path to the Dockerfile. It must be in the context.                    |
| `push`           | Boolean | true                               | Push the image to the registry. Default to true                                |
| `tags`           | List    |                                    | List of tags of the image.                                                     |
| `labels`         | List    |                                    | List of labels of the image.                                                   |
| `tar_file`       | String  |                                    | Tarball name to save the image. The file is saved into Workspace by default.   |
| `build_args`     | List    |                                    | Space separated list of [build-time variables.](https://github.com/docker/buildx/blob/master/docs/reference/buildx_build.md#build-arg)   |
| `debug_mode`     | Boolean    |                                 | Set debug mode true to display the command line and parameters that has been used to build the image. Warning!! some sensitive data used to build the image may will be exposed.   |

## Build performance

In some cases kaniko image build performance may be less efficient; In order to improve the performance,
you could consider enabling the following settings that can help speed up your build time:

- `cache: true`

  Set this flag as true to opt into caching with kaniko.

- `cache_ttl: duration`

  Cache timeout in hours. Defaults to 12 hours.

- `snapshot_mode: redo`

  You can set this flag to set how kaniko will snapshot the filesystem. Valid options are (full, redo, time).

  Redo mode may be up to 50% faster than "full", particularly if your project has a large number files.

Example:

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
            cache: true
            cache_ttl: 6h
            snapshot_mode: redo
```
### Kaniko references:

- https://github.com/GoogleContainerTools/kaniko#caching-layers

- https://github.com/GoogleContainerTools/kaniko#--snapshotmode

### _🚨 NOTE: kaniko and this github action are not an officially supported Google product🚨_
