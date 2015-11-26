#!/bin/bash

this_script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

set -e

current_path=$(pwd)
cd $this_script_dir
bundle install
bundle exec ruby "step.rb" \
  -a "${calabash_features}" \
  -b "${xamarin_user}" \
  -c "${test_cloud_api_key}" \
  -d "${test_cloud_devices}" \
  -e "${test_cloud_is_async}" \
  -f "${test_cloud_series}" \
  -g "${other_parameters}" \
  -i "${apk_path}"
cd $current_path
