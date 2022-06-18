#!/usr/bin/env bash

BASE_DIR=$(readlink -f ${0%/*})
RECIPES_DIR="${BASE_DIR}/recipes"

ALL=""

for recipe_file in $(find ${RECIPES_DIR} -name "*.sh")
do
    source ${recipe_file}
    ALL="${ALL} ${RECIPE_PKGS}"
done
