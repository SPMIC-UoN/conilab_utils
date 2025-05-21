## Short script to make and save a PNG of an MIP

tract_file=$1

x_loc=$2
y_loc=$3
z_loc=$4

thr_up=$5
thr_low=$6

window_slices=$7

output=$8

display_brain=$9

group_to_process=${10}  # "Human" or "Macaque"

template=${11} # What template is used for each species

nm=$(basename ${display_brain})
nm_t=$(basename ${tract_file})

#fsleyes render --scene ortho --outfile ${output} --size 800 300 --worldLoc ${x_loc} ${y_loc} ${z_loc} --displaySpace ${display_brain} --xcentre  0.00000  0.00000 --ycentre  0.00000  0.00000 --zcentre  0.00000  0.00000 --xzoom 100.0 --yzoom 100.0 --zzoom 100.0 --hideLabels --showLocation no --layout horizontal --hideCursor --cursorWidth 1.0 --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --movieSync ${display_brain} --name "${nm//.nii.gz/}" --overlayType volume --alpha 100.0 --brightness 41.204325083692005 --contrast 70.3209768053563 --cmap greyscale --negativeCmap greyscale --displayRange 3170.987 8135.694 --clippingRange 3170.987 8447.64 --modulateRange 0.0 8364.0 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 150 --blendFactor 0.1 --smoothing 0 --resolution 100 --numInnerSteps 10 --clipMode intersection --volume 0 ${tract_file} --name "${nm_t}" --overlayType mip --alpha 100.0 --brightness 64.24635767656991 --contrast 79.3361382804677 --cmap hot --displayRange ${thr_low} ${thr_up} --clippingRange 0.0002 0.023950024768710138 --gamma 0.0 --cmapResolution 256 --interpolation spline --window ${window_slices} --volume 0 &

#echo "${group_to_process}"

if [[ "${group_to_process}" == "Human" && "${template}" == "MNI" ]]; then fsleyes render --scene ortho --outfile ${output} --size 800 300 --worldLoc ${x_loc} ${y_loc} ${z_loc} --displaySpace ${display_brain} --xcentre  0.00000  0.00000 --ycentre  0.00000  0.00000 --zcentre  0.00000  0.00000 --xzoom 100.0 --yzoom 100.0 --zzoom 100.0 --hideLabels --showLocation no --layout horizontal --hideCursor --cursorWidth 1.0 --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --movieSync ${display_brain} --name "${nm//.nii.gz/}" --overlayType volume --alpha 100.0 --brightness 41.204325083692005 --contrast 70.3209768053563 --cmap greyscale --negativeCmap greyscale --displayRange 3170.987 8135.694 --clippingRange 3170.987 8447.64 --modulateRange 0.0 8364.0 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 150 --blendFactor 0.1 --smoothing 0 --resolution 100 --numInnerSteps 10 --clipMode intersection --volume 0 ${tract_file} --name "${nm_t}" --overlayType mip --alpha 100.0 --brightness 48.64560313302842 --contrast 52.709081945515955 --cmap hot --displayRange ${thr_low} ${thr_up} --clippingRange ${thr_low} ${thr_up} --gamma 0.0 --cmapResolution 256 --interpolation spline --window ${window_slices} --volume 0; fi

###########

if [[ "${group_to_process}" == "Macaque" && "${template}" == "F99" ]]; then fsleyes render --scene ortho --outfile ${output} --size 800 300 --worldLoc ${x_loc} ${y_loc} ${z_loc} --displaySpace ${display_brain} --xcentre  0.00000  0.00000 --ycentre  0.00000  0.00000 --zcentre  0.00000  0.00000 --xzoom 100.0 --yzoom 100.0 --zzoom 100.0 --hideLabels --showLocation no --layout horizontal --hideCursor --cursorWidth 1.0 --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --movieSync ${display_brain} --name "${nm//.nii.gz/}" --overlayType volume --alpha 100.0 --brightness 42.54901960784314 --contrast 91.17647058823529 --cmap greyscale --negativeCmap greyscale --displayRange 15.0 60.0 --clippingRange 15.0 129.55 --modulateRange -128.0 127.0 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 150 --blendFactor 0.1 --smoothing 0 --resolution 100 --numInnerSteps 10 --clipMode intersection --volume 0 ${tract_file} --name "${nm_t}" --overlayType mip --alpha 100.0 --brightness 55.29424371969505 --contrast 61.88066817908222 --cmap hot --displayRange ${thr_low} ${thr_up} --clippingRange ${thr_low} ${thr_up} --gamma 0.0 --cmapResolution 256 --interpolation spline --window ${window_slices} --volume 0; fi

if [[ "${group_to_process}" == "Macaque" && "${template}" == "NMT" ]]; then fsleyes render --scene ortho --outfile ${output} --size 800 300 --worldLoc ${x_loc} ${y_loc} ${z_loc} --displaySpace ${display_brain} --xcentre  0.00000  0.00000 --ycentre  0.00000  0.00000 --zcentre  0.00000  0.00000 --xzoom 100.0 --yzoom 100.0 --zzoom 100.0 --hideLabels --showLocation no --layout horizontal --hideCursor --cursorWidth 1.0 --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --movieSync ${display_brain} --name "${nm//.nii.gz/}" --overlayType volume --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange 0.0 1034.24 --clippingRange 0.0 1034.24 --modulateRange 0.0 1024.0 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 150 --blendFactor 0.1 --smoothing 0 --resolution 100 --numInnerSteps 10 --clipMode intersection --volume 0 ${tract_file} --name "${nm_t}" --overlayType mip --alpha 100.0 --brightness 55.29424371969505 --contrast 61.88066817908222 --cmap hot --displayRange ${thr_low} ${thr_up} --clippingRange ${thr_low} ${thr_up} --gamma 0.0 --cmapResolution 256 --interpolation spline --window ${window_slices} --volume 0; fi
