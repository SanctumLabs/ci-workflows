#!/bin/bash
# shellcheck disable=SC1091,SC2140,SC2207
set -e

## REQUIRED VARIABLES
## DOCKERHUB_PASSWORD: Password for Dockerhub to authenticate with
## DOCKERHUB_USERNAME: Username for Dockerhub to authenticate with
## DOCKERHUB_REPO: The name of the Org to push/pull to/from
## DOCKERHUB_IMAGE_NAME: The name of the image
DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME:?}"
DOCKERHUB_PASSWORD="${DOCKERHUB_PASSWORD:?}"
DOCKERHUB_REPO="${DOCKERHUB_REPO:?}"
DOCKER_IMAGE_NAME="${DOCKER_IMAGE_NAME:?}"

## OPTIONAL VARIABLES
## CACHE_TAG: The tag pulled before starting a build as a base to assist with faster builds using layers
## DOCKER_CACHE_TARGET: Space seperated list of stages in the Dockerfile to build and cache
## DOCKER_CONTEXT: Path of the docker context
## DOCKER_EXTRA_BUILD_ARGS: Some extra arguments that needs to be passed to docker build,
##                          eg --build-arg some ARG
## DOCKERFILE: Path to the Dockerfile we want to use
## DOCKER_IMAGE_TAG: Space seperated list of tags to push after building
CACHE_TAG="${CACHE_TAG:-master}"
DOCKER_CACHE_TARGET="${DOCKER_CACHE_TARGET:-""}"
DOCKER_CONTEXT="${DOCKER_CONTEXT:-.}"
DOCKER_EXTRA_BUILD_ARGS="${DOCKER_EXTRA_BUILD_ARGS:-""}"
DOCKERFILE="${DOCKERFILE:-Dockerfile}"
DOCKER_IMAGE_TAG="${DOCKER_IMAGE_TAG:-""}"

dockerhub_login() {
  echo "Logging into Dockerhub..."
  echo -e "${DOCKERHUB_PASSWORD}" | docker login --username "${DOCKERHUB_USERNAME}" --password-stdin
  echo "---"
}

# Docker login
dockerhub_login

# Build and push all cache targets
CACHE_FROM_ARGS="--cache-from ${ECR_IMAGE_REPO}:${CACHE_TAG}"
for CACHE_TARGET in ${DOCKER_CACHE_TARGET}; do
  IMAGE="${DOCKERHUB_REPO}/${DOCKER_IMAGE_NAME}:${CACHE_TARGET}"
  CACHE_FROM_ARGS="${CACHE_FROM_ARGS} --cache-from ${IMAGE}"

  docker pull "${ECR_IMAGE_REPO}:${CACHE_TARGET}" || true

  # Need to disable word splitting check for flags to docker build
  # shellcheck disable=SC2086
  docker build --target ${CACHE_TARGET} ${CACHE_FROM_ARGS} ${DOCKER_EXTRA_BUILD_ARGS} -t "${IMAGE}" -f "${DOCKERFILE}" "${DOCKER_CONTEXT}"

  docker push "${IMAGE}"
done

# Actually do the build
# Need to disable word splitting check for flags to docker build
# shellcheck disable=SC2086
docker build ${CACHE_FROM_ARGS} ${DOCKER_EXTRA_BUILD_ARGS} -t gitlabimagebuild -f "${DOCKERFILE}" "${DOCKER_CONTEXT}"

# Tag and push the CACHE_TAG
docker tag gitlabimagebuild "${DOCKERHUB_REPO}/${DOCKER_IMAGE_NAME}:${CACHE_TAG}"
docker push "${DOCKERHUB_REPO}/${DOCKER_IMAGE_NAME}:${CACHE_TAG}"

# Tag and push each tag in ECR_IMAGE_TAG
for TAG in ${DOCKER_IMAGE_TAG}; do
  # Limit tag length to 100 characters and replace / with -
  TAG=$(echo "${TAG}" | awk '{print substr($0,1,100)}' | sed 's,/,-,g')

  docker tag gitlabimagebuild "${DOCKERHUB_REPO}/${DOCKER_IMAGE_NAME}:${TAG}"
  docker push "${DOCKERHUB_REPO}/${DOCKER_IMAGE_NAME}:${TAG}"
done
