#!/bin/sh

codesign --force --verbose --sign "${CODE_SIGN_IDENTITY}" --entitlements "${CODE_SIGN_ENTITLEMENTS}" "$BUILT_PRODUCTS_DIR/$FULL_PRODUCT_NAME"