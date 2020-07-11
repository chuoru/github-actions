#!/bin/bash

set -x

export DEBIAN_FRONTEND=noninteractive

setup-conan()
{
  apt-get update -qq
  apt-get install -qq python3-setuptools python3-pip
  pip3 install conan
  conan remote add @CONAN_REPOSITORY@ @CONAN_REMOTE@
  conan profile new default --detect || true
  conan profile update settings.compiler.libcxx=libstdc++11 default
}

setup-conan
echo "::group::Create conan package"
  conan create . @CONAN_REPOSITORY@/@CONAN_CHANNEL@ -s build_type=Release
  conan create . @CONAN_REPOSITORY@/@CONAN_CHANNEL@ -s build_type=Debug
echo "::endgroup::"
if @CONAN_UPLOAD@
then
  echo "::group::Upload conan package"
  conan user -p @BINTRAY_API_KEY@ -r @CONAN_REPOSITORY@ @CONAN_USER@
  conan alias @CONAN_PACKAGE@/latest@@CONAN_REPOSITORY@/@CONAN_CHANNEL@ @CONAN_PACKAGE@/@CONAN_PACKAGE_VERSION@@@CONAN_REPOSITORY@/@CONAN_CHANNEL@
  conan upload @CONAN_PACKAGE@/@CONAN_PACKAGE_VERSION@@@CONAN_REPOSITORY@/@CONAN_CHANNEL@ --all -r=@CONAN_REPOSITORY@
  conan upload @CONAN_PACKAGE@/latest@@CONAN_REPOSITORY@/@CONAN_CHANNEL@ --all -r=@CONAN_REPOSITORY@
  echo "::engroup"
fi