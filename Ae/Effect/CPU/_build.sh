cd "$(dirname "$0")"
cd ./

set -eu

PLUGIN="PLUGIN"
echo ${PLUGIN}

mkdir -p ${PLUGIN}.plugin/Contents/{MacOS,Resources}

clang++ -std=c++20 -Wc++20-extensions -bundle -dependency_info -fobjc-arc -O3 -I../../Headers -I../../Util -I./ -framework Cocoa ./main.mm -o ./${PLUGIN}.plugin/Contents/MacOS/${PLUGIN}

Rez -o ./${PLUGIN}PiPL.rsrc -define __MACH__ -arch arm64 -i ../../Headers -i ../../Resources ./${PLUGIN}PiPL.r
ResMerger -dstIs DF ./${PLUGIN}PiPL.rsrc -o ./${PLUGIN}.plugin/Contents/Resources/${PLUGIN}.rsrc
rm ./${PLUGIN}PiPL.rsrc

cp ./Info.plist ./${PLUGIN}.plugin/Contents/
cp ../CPU/PkgInfo ./${PLUGIN}.plugin/Contents/

codesign --force --options runtime --deep --entitlements "../CPU/entitlements.plist" --sign "Developer ID Application" --timestamp --verbose ${PLUGIN}.plugin

echo "** BUILD SUCCEEDED **"