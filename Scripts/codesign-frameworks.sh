#!/bin/sh

# WARNING: You may have to run Clean in Xcode after changing CODE_SIGN_IDENTITY!

# Verify that $CODE_SIGN_IDENTITY is set
if [ -z "${CODE_SIGN_IDENTITY}" ] ; then
echo "CODE_SIGN_IDENTITY needs to be set for framework code-signing!"

if [ "${CONFIGURATION}" = "Release" ] ; then
exit 1
else
# Code-signing is optional for non-release builds.
exit 0
fi
fi

if [ -z "${CODE_SIGN_ENTITLEMENTS}" ] ; then
echo "CODE_SIGN_ENTITLEMENTS needs to be set for framework code-signing!"

if [ "${CONFIGURATION}" = "Release" ] ; then
exit 1
else
# Code-signing is optional for non-release builds.
exit 0
fi
fi

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

FRAMEWORK_DIR="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

# Loop through all frameworks
FRAMEWORKS=`find "${FRAMEWORK_DIR}" -depth -type d -name "*.framework" -or -name "*.dylib" -or -name "*.bundle" | sed -e "s/\(.*framework\)/\1\/Versions\/A\//"`
RESULT=$?
if [[ $RESULT != 0 ]] ; then
exit 1
fi

echo "Found:"
echo "${FRAMEWORKS}"

for FRAMEWORK in $FRAMEWORKS;
do
echo "Signing '${FRAMEWORK}'"
`codesign --force --verbose --sign "${CODE_SIGN_IDENTITY}" --entitlements "${CODE_SIGN_ENTITLEMENTS}" "${FRAMEWORK}"`
RESULT=$?
if [[ $RESULT != 0 ]] ; then
exit 1
fi
done

# restore $IFS
IFS=$SAVEIFS