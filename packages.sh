#!/usr/bin/env bash

BASE_DIR=$(readlink -f ${0%/*})
RECIPES_DIR="${BASE_DIR}/recipes"

ALL_PACKAGES=""

for recipe_file in $(find ${RECIPES_DIR} -name "*.sh")
do
    source ${recipe_file}
    ALL_PACKAGES="${ALL_PACKAGES} ${RECIPE_PKGS}"
done
