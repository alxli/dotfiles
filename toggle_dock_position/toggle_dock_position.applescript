do shell script "
current=$(defaults read com.apple.dock orientation);
if [ \"$current\" = \"left\" ]; then
  defaults write com.apple.dock orientation -string bottom;
else
  defaults write com.apple.dock orientation -string left;
fi;
killall Dock
"
