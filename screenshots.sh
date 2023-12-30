#!/usr/bin/env zsh

set -e

if ! command -v xcparse &> /dev/null
then
    echo "xcparse could not be found. Please install it: brew install chargepoint/xcparse/xcparse"
    exit 1
fi

if ! command -v convert &> /dev/null
then
    echo "ImageMagick could not be found. Please install it: brew install imagemagick"
    exit 1
fi

rm -rf ./Screenshots.xcresult
rm -rf ./screenshots
mkdir ./screenshots

xcodebuild \
-project "CCCTube.xcodeproj" \
-scheme "CCCTube" \
-destination "platform=iOS Simulator,name=iPhone 8 Plus,OS=16.4" \
-destination "platform=iOS Simulator,name=iPhone 14 Plus,OS=17.2" \
-destination "platform=iOS Simulator,name=iPad Pro (12.9-inch) (2nd generation),OS=17.2" \
-destination "platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation),OS=17.2" \
-resultBundlePath "./Screenshots.xcresult" \
-testPlan Screenshots \
-parallel-testing-enabled YES \
test

xcparse screenshots --os --model --test-plan-config "./Screenshots.xcresult" "./screenshots/"

# Remove alpha channel from the screenshots, otherwise the App Store will reject them
find ./screenshots -name "*.png" -exec convert "{}" -alpha off "{}" \;

open ./screenshots
