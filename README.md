# YIO remote cross compile GitHub Action

GitHub action for cross compiling a YIO remote project for RPi0

## Inputs

### project-name

The name of the Qt project to build. This must be a folder name of a YIO project git checkout within `${GITHUB_WORKSPACE}`!

### output-path

The output directory path for the binary build artefacts.

### qmake-args

The QMake build arguments.

## Outputs

### project-version

The determined project version from the last git version label.

## Example usage

    uses: zehnm/yio-crosscompile-action
    with:
      project-name: remote-software
      output-path: ${GITHUB_WORKSPACE}/binaries/app
      qmake-args: 'CONFIG+=debug CONFIG+=qml_debug'
