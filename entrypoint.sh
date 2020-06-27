#!/bin/sh -l

set -e

PROJECT_NAME=$( eval echo $1 )
export YIO_BIN=$( eval echo $2 )
YIO_REMOTE_QMAKE_ARGS=$( eval echo $3 )
INTG_LIB_REPO=$4
VERSION_FILE_DIR=$( eval echo $5 )
SHADOW_BUILD_DIR=${GITHUB_WORKSPACE}/${PROJECT_NAME}/build_rpi0
export YIO_SRC=${GITHUB_WORKSPACE}

echo "Project dir in workspace : $PROJECT_NAME"
echo "Output path              : $YIO_BIN"
echo "QMake args               : $YIO_REMOTE_QMAKE_ARGS"
echo "Github workspace         : ${GITHUB_WORKSPACE}"
echo "Shadow build dir         : ${SHADOW_BUILD_DIR}"
echo "integrations.library repo: $INTG_LIB_REPO"
echo "version.txt location     : $VERSION_FILE_DIR"

# verify environment
if [ ! -d "${GITHUB_WORKSPACE}/${PROJECT_NAME}" ]; then
    echo "Project directory '$PROJECT_NAME' does not exist in workspace '$GITHUB_WORKSPACE'!"
fi

# retrieve missing dependencies
if [ -d "${GITHUB_WORKSPACE}/integrations.library" ]; then
    echo "Dependency 'integrations.library' found in GITHUB_WORKSPACE"
else
    echo "Dependency 'integrations.library' missing in GITHUB_WORKSPACE"
    YIO_INTG_LIB_VERSION=master

    DEPENDENCY_FILE=${GITHUB_WORKSPACE}/${PROJECT_NAME}/dependencies.cfg
    if [ -r $DEPENDENCY_FILE ]; then
        YIO_INTG_LIB_VERSION=$(cat "$DEPENDENCY_FILE" | awk '/^integrations.library:/{print $2}')
        echo "Retrieved 'integrations.library' version from $DEPENDENCY_FILE: $YIO_INTG_LIB_VERSION"
    else
        echo "WARNING: dependency file not found: $DEPENDENCY_FILE! Using default version: $YIO_INTG_LIB_VERSION"
    fi

    cd ${GITHUB_WORKSPACE}
    git clone --depth 1 $INTG_LIB_REPO -b $YIO_INTG_LIB_VERSION
fi

# make sure there are no old build artefacts and all output directories exist
rm -rf $YIO_BIN || :
mkdir -p $YIO_BIN
rm -rf $SHADOW_BUILD_DIR || :
mkdir -p $SHADOW_BUILD_DIR

echo "Creating Makefile..."
cd $SHADOW_BUILD_DIR
export PATH=${TOOLCHAIN_PATH}/bin:${TOOLCHAIN_PATH}/sbin:$PATH
${TOOLCHAIN_PATH}/bin/qmake ${GITHUB_WORKSPACE}/${PROJECT_NAME} ${YIO_REMOTE_QMAKE_ARGS}

make qmake_all

# build app
cd $SHADOW_BUILD_DIR
CPU_CORES=$(getconf _NPROCESSORS_ONLN)
echo "Numbers of CPU cores for make: $CPU_CORES"
make -j$CPU_CORES
# log build information
echo "GitHub Actions debug build
$(date)
GIT branch: $(git rev-parse --abbrev-ref HEAD)
GIT hash:   $(git rev-parse HEAD)
YIO Buildroot SDK: $BUILDROOT_SDK_VERSION

$(${TOOLCHAIN_PATH}/bin/qmake -query)

$(make --version)

$(cc --version)
$(gcc --version)
$(cpp --version)
" > ${YIO_BIN}/../build.info

echo "Getting app version"
cd $SHADOW_BUILD_DIR
read -r APP_VERSION<${VERSION_FILE_DIR}/version.txt
echo "App version: $APP_VERSION"
echo "::set-output name=project-version::$APP_VERSION"

echo "Creating debug installation package from: ${YIO_BIN}"

# copy additional files for the installation archive
cp ${VERSION_FILE_DIR}/version.txt ${YIO_BIN}/..
# hooks are optional: don't fail if missing
cp -r $SHADOW_BUILD_DIR/hooks ${YIO_BIN}/.. || :
# compress app
cd ${YIO_BIN}/..
rm -f app.tar.gz md5sums
tar -czvf app.tar.gz app
rm -Rf app
# create checksums
md5sum * > md5sums
