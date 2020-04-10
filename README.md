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

    uses: zehnm/yio-crosscompile-action@master
    with:
      project-name: remote-software
      output-path: ${GITHUB_WORKSPACE}/binaries/app
      qmake-args: 'CONFIG+=release'
