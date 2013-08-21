#!/bin/sh

convert tileset.png -crop 7x7@ +repage +adjoin tile_%d.png
montage tile_*.png -background none -colorspace RGB -alpha Set -tile 7x7 -geometry 32x32+2+2 tileset_out2.png
python2.5 ~/cocos2d-iphone-1.0.1/tools/spritesheet-artifact-fixer.py -f tileset_out2.png -x 32 -y 32 -m 2 -s 4

