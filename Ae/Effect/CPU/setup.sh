cd "$(dirname "$0")"
cd ./

set -eu

if [ $# -ne 1 ]; then
	exit 1
fi

mkdir ../$1

sed -e "s/PLUGIN=\"PLUGIN\"/PLUGIN=\"$1\"/g" ./_build.sh >> ../$1/build.sh
sed -e "s/#define IDENTIFIER @\"Ae.CPU.Plugin\"/#define IDENTIFIER @\"Ae.CPU.$1\"/g" ./_Config.h >> ../$1/Config.h
sed -e "s/\<string\>Plugin\<\/string\>/\<string\>$1\<\/string\>/g" \
-e "s/\<string\>Ae.CPU.Plugin\<\/string\>/\<string\>Ae.CPU.$1\<\/string\>/g" \
./Info.plist >> ../$1/Info.plist
sed -e "s/\"Plugin\"/\"$1\"/g" \
-e "s/\"Ae.CPU.Plugin\"/\"Ae.CPU.$1\"/g" \
./PiPL.r >> ../$1/$1PiPL.r
cp ./_main.mm ../$1/main.mm

echo $1