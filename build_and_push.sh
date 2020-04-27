#!/bin/bash -eu

build_and_push() {
  if [[ -n "${INPUT_DOCKER_BUILD_SCRIPT:-""}" && \
        -n "${INPUT_DOCKERFILE:-""}" ]]; then
    echo "Cannot define both dockerfile and docker_build_script!"
    return 1
  fi

  if [[ -z "${INPUT_IMAGE:-""}" ]]; then
    echo "Config missing required input 'image'"
    return 1
  fi

  if [[ -z "${GCLOUD_SERVICE_ACCOUNT_KEY:-""}" ]]; then
    echo "GCLOUD_SERVICE_ACCOUNT_KEY env var required (GitHub secret)"
    return 1
  fi

  if [[ -z "${GOOGLE_PROJECT_ID:-""}" ]]; then
    echo "GOOGLE_PROJECT_ID env var required (GitHub secret)"
    return 1
  fi

  local -r location="${INPUT_GCR_LOCATION:-"gcr.io"}"

  local -r gcr_image_name="${location}/${GOOGLE_PROJECT_ID}/${INPUT_IMAGE}"
  if [[ -n "${INPUT_DOCKER_BUILD_SCRIPT:-""}" ]]; then
    eval "${INPUT_DOCKER_BUILD_SCRIPT}"
  else
    local -r dockerfile="${INPUT_DOCKERFILE:-"Dockerfile"}"
    docker build -t "${gcr_image_name}" "$(dirname ${dockerfile})"
  fi

  echo "${GCLOUD_SERVICE_ACCOUNT_KEY}" \
    | docker login -u _json_key --password-stdin "https://${location}"
  gcloud auth configure-docker
  docker push "${gcr_image_name}"
}

build_and_push "$@"
