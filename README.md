# YIO remote cross compile GitHub Action

GitHub action for cross compiling a [YIO remote project](https://github.com/YIO-Remote) for RPi0.

## Inputs

### project-name

The name of the Qt project to build. This must be a YIO project name from a git checkout within `${GITHUB_WORKSPACE}`!

### output-path

The output directory path for the binary build artefacts. This directory must be part of `${GITHUB_WORKSPACE}`, otherwise the build artefacts are not accessible after this action has run.

### qmake-args

The QMake build arguments. E.g. to specify a debug or release build. Default: `CONFIG+=debug CONFIG+=qml_debug`.

### intg-lib-repo

The git repository for checking out the integrations.library project. Default: `https://github.com/YIO-Remote/integrations.library.git`.

If `${GITHUB_WORKSPACE}/integrations.library` doesn't exist it will automatically be checked out.

## Outputs

### project-version

The retrieved project version from the git project.

## Example usage

```yml
name: Cross Compile
on: [push]
env:
  PROJECT_NAME: remote-software

jobs:
  cross_compile:
    name: RPi0 YIO remote-os
    runs-on: ubuntu-latest
    steps:
      - name: Checkout remote-software with history
        uses: actions/checkout@v2
        with:
          fetch-depth: 500
          path: ${{ env.PROJECT_NAME}}

      - name: Fetch all tags to determine version
        run: |
          cd ${{ env.PROJECT_NAME}}
          git fetch origin +refs/tags/*:refs/tags/*
          git describe --match "v[0-9]*" --tags HEAD --always

      - name: Cross compile
        id: cross-compile
        uses: zehnm/yio-crosscompile-action@master
        with:
          project-name: ${{ env.PROJECT_NAME}}
          output-path: ${GITHUB_WORKSPACE}/binaries/app
          qmake-args: 'CONFIG+=release'

      - name: Get app version from build
        run: |
          echo "::set-env name=APP_VERSION::${{ steps.cross-compile.outputs.project-version }}"

      - name: Upload build artefacts
        uses: actions/upload-artifact@v1
        with:
          path: binaries
          name: ${{ env.PROJECT_NAME }}-${{ env.APP_VERSION }}-rpi0
```
