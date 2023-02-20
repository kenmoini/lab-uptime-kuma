# Lab - Uptime Kuma

Uptime Kuma is a dope uptime monitoring tool - I was going to build one but this one actually does most of what I wanted to do, even if it is a primative architecture.

## Container Image

There is a Dockerfile in this repository that is based on the Red Hat UBI images.

```bash
# Build the container image
podman build -t uptime-kuma-ubi -f Dockerfile .

# Run the container image
podman run --name uptime-kuma --rm -d -p 8080:8080 uptime-kuma-ubi

# Run the container image with a persistent volume
podman run --name uptime-kuma --rm -d -p 8080:8080 -v uptime-kuma:/app/data uptime-kuma-ubi

```

## GitHub Actions

This repo also includes some default Dependabot configuration to keep things up to date.

There is also a GitHub Action that will build this UBI-based Container Image and push it to a repo - in order for it to work you need a few secrets added to the GitHub repo.  Reference the first few lines in that `build-and-push.yml` GHA for the needed secrets.
