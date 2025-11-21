#!/bin/bash

# Create icon.iconset directory
mkdir -p AppIcon.iconset

# Create a simple clock icon at different sizes
# We'll create a basic icon using sips or a simple colored square

# Function to create a simple clock icon using sips
create_icon_size() {
    local size=$1
    local filename=$2
    
    # Create a temporary PNG with a simple design
    # Using sips to create a colored square, then we can overlay clock elements
    # For now, create a simple white circle with black border
    
    # Create base image (white circle on transparent background)
    # Note: sips can't create complex shapes, so we'll create a simple design
    # or use a placeholder that can be replaced
    
    # Create a simple colored square as placeholder
    # In a real scenario, you'd want to use a proper icon design tool
    # For now, create a simple icon
    
    echo "Creating $filename at ${size}x${size}..."
    
    # Use sips to create a simple icon (this is a placeholder)
    # You can replace this with a proper icon design
    sips -s format png --setProperty formatOptions low \
         -z $size $size \
         /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Clock.icns \
         --out "AppIcon.iconset/$filename" 2>/dev/null || \
    # Fallback: create a simple colored square
    sips -s format png -c $size $size \
         --setProperty formatOptions low \
         -g pixelWidth $size -g pixelHeight $size \
         /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns \
         --out "AppIcon.iconset/$filename" 2>/dev/null || \
    # Last resort: create a simple colored image
    echo "Note: Could not create $filename automatically. Please add a ${size}x${size} PNG icon manually."
}

# Create all required icon sizes
create_icon_size 16 "icon_16x16.png"
create_icon_size 32 "icon_16x16@2x.png"
create_icon_size 32 "icon_32x32.png"
create_icon_size 64 "icon_32x32@2x.png"
create_icon_size 128 "icon_128x128.png"
create_icon_size 256 "icon_128x128@2x.png"
create_icon_size 256 "icon_256x256.png"
create_icon_size 512 "icon_256x256@2x.png"
create_icon_size 512 "icon_512x512.png"
create_icon_size 1024 "icon_512x512@2x.png"

# Convert iconset to icns
if [ -f "AppIcon.iconset/icon_16x16.png" ]; then
    iconutil -c icns AppIcon.iconset -o AppIcon.icns
    echo "Created AppIcon.icns"
else
    echo "Warning: Could not create all icon sizes. Please create them manually or use an icon design tool."
fi

