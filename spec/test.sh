echo "FF 2"
defaults read /Applications/Firefox2.app/Contents/Info CFBundleExecutable
more /Applications/Firefox2.app/Contents/MacOS/launch-ff 
echo "FF 3"
defaults read /Applications/Firefox3.app/Contents/Info CFBundleExecutable
more /Applications/Firefox3.app/Contents/MacOS/launch-ff 
echo "FF 3b1"
defaults read /Applications/Firefox3.1b1.app/Contents/Info CFBundleExecutable 
more /Applications/Firefox3.1b1.app/Contents/MacOS/launch-ff 
echo "MF"
defaults read /Applications/Minefield.app/Contents/Info CFBundleExecutable 
more /Applications/Minefield.app/Contents/MacOS/launch-ff 
