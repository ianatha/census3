.PHONY: i3

default: i3

clean:
	rm -rf build

i3:
	xcodebuild -target i3 -configuration Release
	rm -rf build/i3.zip
	ditto -v -c -k --sequesterRsrc --keepParent build/Release/i3.app/ build/i3.zip

test-codesign: i3
	spctl -a -t exec --verbose --ignore-cache --no-cache --raw build/Release/i3.app
