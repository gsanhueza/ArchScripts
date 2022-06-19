#!/usr/bin/env bash

BASE_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )"
RECIPES_DIR="${BASE_DIR}/recipes"

ALL_PACKAGES=""

for recipe_file in $(find ${RECIPES_DIR} -name "*.sh")
do
    source ${recipe_file}
    export ALL_PACKAGES="${ALL_PACKAGES} ${RECIPE_PKGS}"
done
