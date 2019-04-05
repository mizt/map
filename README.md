# map


### player.mm

	$ xcrun clang++ -ObjC++ -lc++ ./player.mm ./Metalview.mm -fobjc-arc -O3 -std=c++17 -Wc++17-extensions -framework Cocoa -framework Metal -framework Quartz -o ./player
	$ ./player
	

### write.mm

	$ xcrun clang++ -ObjC++ -lc++ ./write.mm -fobjc-arc -O3 -std=c++17 -Wc++17-extensions -framework Cocoa -o ./write
	$ ./write


### msl/main.metal

	$ cd ./msl
	$ xcrun -sdk macosx metal -c main.metal -o main.air; xcrun -sdk macosx metallib main.air -o main.metallib