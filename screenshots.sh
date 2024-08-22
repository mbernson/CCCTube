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

# xcrun simctl create "iPhone 15 Plus" "iPhone 15 Plus" "iOS17.5"
# xcrun simctl create "iPhone 8 Plus" "iPhone 8 Plus" "iOS16.4"
# xcrun simctl create "iPad Pro 13-inch (M4)" "iPad Pro 13-inch (M4)" "iOS17.5"
# xcrun simctl create "iPad Pro (12.9-inch) (2nd generation)" "iPad Pro (12.9-inch) (2nd generation)" "iOS17.5"

# xcodebuild -verbose \
# -project "CCCTube.xcodeproj" \
# -scheme "CCCTube" \
# -destination "platform=iOS Simulator,name=iPhone 8 Plus" \
# -destination "platform=iOS Simulator,name=iPhone 15 Plus" \
# -destination "platform=iOS Simulator,name=iPad Pro 13-inch (M4)" \
# -destination "platform=iOS Simulator,name=iPad Pro (12.9-inch) (2nd generation)" \
# -resultBundlePath "./Screenshots.xcresult" \
# -testPlan Screenshots \
# clean test

declare -a destinations=("platform=iOS Simulator,name=iPhone 8 Plus" "platform=iOS Simulator,name=iPhone 15 Plus" "platform=iOS Simulator,name=iPad Pro 13-inch (M4)" "platform=iOS Simulator,name=iPad Pro (12.9-inch) (2nd generation)")

rm -rf ./screenshots
mkdir ./screenshots

for destination in "${destinations[@]}"
do

rm -rf ./Screenshots.xcresult

echo "Taking screenshots for $destination"
xcodebuild -quiet \
-project "CCCTube.xcodeproj" \
-scheme "CCCTube" \
-destination "platform=iOS Simulator,name=iPhone 15 Plus" \
-resultBundlePath "./Screenshots.xcresult" \
-testPlan Screenshots \
clean test

xcparse screenshots --os --model --test-plan-config "./Screenshots.xcresult" "./screenshots/"

done

# Remove alpha channel from the screenshots, otherwise the App Store will reject them
find ./screenshots -name "*.png" -exec convert "{}" -alpha off "{}" \;

open ./screenshots
