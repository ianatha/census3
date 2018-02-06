.PHONY: i3

default: i3

clean:
	rm -rf build

i3:
	xcodebuild -target i3 -configuration Release
	pushd build/Release && rm -f ../i3.zip && zip -r ../i3.zip i3.app/ && popd
