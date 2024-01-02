#!/usr/bin/env zsh

# This script automates the process of taking screenshots for the App Store.
# It uses UI tests target, which are configured in the Screenshots test plan.

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

# To create the necessary simulators, run:
# xcrun simctl create "Apple TV 4K (3rd generation) (at 1080p)" "Apple TV 4K (3rd generation) (at 1080p)" "tvOS17.2"
# xcrun simctl create "iPhone 8 Plus" "iPhone 8 Plus" "iOS16.4"
# xcrun simctl create "iPhone 15 Plus" "iPhone 15 Plus" "iOS17.2"
# xcrun simctl create "iPad Pro (12.9-inch) (2nd generation)" "iPad Pro (12.9-inch) (2nd generation)" "iOS17.2"
# xcrun simctl create "iPad Pro (12.9-inch) (6th generation)" "iPad Pro (12.9-inch) (6th generation)" "iOS17.2"

xcodebuild \
-project "CCCTube.xcodeproj" \
-scheme "CCCTube" \
-destination "platform=iOS Simulator,name=iPhone 8 Plus,OS=16.4" \
-destination "platform=iOS Simulator,name=iPhone 15 Plus,OS=17.2" \
-destination "platform=iOS Simulator,name=iPad Pro (12.9-inch) (2nd generation),OS=17.2" \
-destination "platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation),OS=17.2" \
-resultBundlePath "./Screenshots.xcresult" \
-testPlan Screenshots \
clean test

# NOTES:
# -destination "platform=tvOS Simulator,name=Apple TV 4K (3rd generation) (at 1080p),OS=17.2" \
# -parallel-testing-enabled YES \
# -maximum-concurrent-test-simulator-destinations 2 \

xcparse screenshots --os --model --test-plan-config "./Screenshots.xcresult" "./screenshots/"

# Remove alpha channel from the screenshots, otherwise the App Store will reject them
find ./screenshots -name "*.png" -exec convert "{}" -alpha off "{}" \;

open ./screenshots
