#!/bin/bash

# @author    	Kai Grassnick <info@kai-grassnick.de>
# @description 	make a picture 50% darker

convert "$1" -fill black -colorize 50% "$1"_grey.jpg

