##############
# This is a short script that give a stitched png collage of inputed tracts across inputed groups.
##############


input_table=$1

script_path=$2

dat_type=$3 # can be "single" or "group"

tract_path=$4
window_slices=$5
output_path=$6

display_brain=$7

group_to_process=$8  # "Human" or "Macaque"
template=$9

overwrite=$10

########

if [ ! -d ${output_path} ]; then mkdir -p ${output_path}; fi
if [ -d ${output_path} ]; then if [ $overwrite == "yes" ]; then echo "Output directory already exists and contents WILL be overwritten."; rm -r ${output_path}; fi; fi
if [ -d ${output_path} ]; then if [ $overwrite == "no" ]; then echo "Output directory already exists and contents WILL NOT be overwritten."; fi; fi

#########

# Step1: Indetify the groups of the datasets. The grouping variable should be named "Group"

# Check if the "Group" column exists by looking at the first line (header)
header=$(head -n 1 "$input_table")

# Check if "Group" exists in the header
if echo "$header" | grep -q "Group"; then
    # Extract the column number of "Group" by using `awk`
    group_column=$(echo "$header" | awk -F',' '{for(i=1; i<=NF; i++) if($i=="Group") print i}')
    # Extract and display unique groups from that column (skip the header using tail -n +2)
    unique_groups=$(tail -n +2 "$input_table" | cut -d',' -f"$group_column" | sort | uniq)
    group_count=$(echo "$unique_groups" | wc -l)
    echo "Total number of groups is: " $group_count 
    # Loop over the unique groups
    while read -r group; do
        # You can use the $group variable in your loop here
        echo "Processing group: $group"
	tract_path_mod=${tract_path//group/${group}}
	# Subset the input table to only include the rows for this group (skip the header)
        #group_data=$(grep -E "$group" "$input_table")
	grep -E "$group" "$input_table" | awk -F',' -v label="$group_to_process" '{print label "," $0}' > group_data.txt
	###
	mkdir -p ${output_path}/${group}
	###
	#group_data=$(awk -F',' -v group="$group" -v col="$group_column" 'BEGIN {OFS=","} { if (NR == 1) {$col=""; sub(/^,/, "", $0); print $0} else if ($col == group) { $col=""; sub(/^,/, "", $0); print $0 } }' "$input_table")
	sh ${script_path}/get_MIP_screenshot_loop_general.sh ${script_path}/get_MIP_screenshot.sh ./group_data.txt ${dat_type} ${tract_path_mod} ${window_slices} ${output_path}/${group} ${display_brain} ${group_to_process} ${template}
    done <<< "$unique_groups"
    ##########
    # Stitch the output images group-wise.
    # Extract the column number for "Tract"
    tract_column=$(echo "$header" | awk -F',' '{for(i=1; i<=NF; i++) if($i=="Tract") print i}')
    ######
    if [ -n "$tract_column" ]; then
        # Extract unique tracts and store them in a variable
        unique_tracts=$(tail -n +2 "$input_table" | cut -d',' -f"$tract_column" | sort | uniq)
	#echo ${unique_trats}
    else
    	echo "No 'Tract' column found."
    fi
    echo "All unique tracts in our table are:"
    echo ${unique_tracts}
    tract_count=$(echo "$unique_tracts" | wc -l)
    echo "Total number of tracts is: " $tract_count
    #######
    # Create a temporary directory to store the image paths for montage
    temp_list_file_full="image_list.txt" > "$temp_list_file_full"  # Clear the file if it already exists
    # Generate a list of image files for each group and tract combination
    max_files=$(awk -F',' -v col="$group_column" '{print $col}' "$input_table" | sort | uniq -c | sort -nr | head -n 1  | awk '{print $1}')
    while read -r group; do
        echo ""
        echo "Getting tracts for group:" 
        echo ${group}
        #group_data=$(grep -E "$group" "$input_table")
        grep -E "$group" "$input_table" | awk -F',' '{print $0}' > group_data.txt
        grp_tracts=$(tail -n +1 ./group_data.txt | cut -d',' -f"$tract_column" | sort | uniq)
        # Create img file list
        filename="${group}_output.txt"
        temp_list_file="$filename" > "$temp_list_file"
        cat ${temp_list_file}
        ######
    	while read -r tract; do
            echo $tract
	    if echo "$grp_tracts" | grep -qw "$tract"; then
    	    	image_path="${output_path}/${group}/${tract}.png"
            	if [[ -f "$image_path" ]]; then
            		echo "$image_path" >> "$temp_list_file"
		else
			echo "Warning: Image screenshot failed. Creating placeholder."
			existing_image=$(find "${output_path}/${group}" -type f -name "*.png" | head -n 1)
                        dimensions=$(identify -format "%wx%h" "$existing_image")
                	# Extract the width and height from the dimensions
                	width=$(echo $dimensions | cut -d'x' -f1)
                	height=$(echo $dimensions | cut -d'x' -f2)
                	mkdir -p ${output_path}/${group}/placeholders
                	magick -size ${width}x${height} xc:black "${output_path}/${group}/placeholders/blank_$tract.png"
                	echo ${output_path}/${group}/placeholders/blank_$tract.png >> "$temp_list_file"
            	fi
	    else
            	echo "Info for $tract for $group not in table. Creating placeholder."
                existing_image=$(find "${output_path}/${group}" -type f -name "*.png" | head -n 1)
                #ls ${existing_image}
                dimensions=$(identify -format "%wx%h" "$existing_image")
		# Extract the width and height from the dimensions
    		width=$(echo $dimensions | cut -d'x' -f1)
    		height=$(echo $dimensions | cut -d'x' -f2)
                mkdir -p ${output_path}/${group}/placeholders
                magick -size ${width}x${height} xc:black "${output_path}/${group}/placeholders/blank_$tract.png"
                echo ${output_path}/${group}/placeholders/blank_$tract.png >> "$temp_list_file"
            fi
    	done <<< "$unique_tracts"
        echo "${output_path}/${group}_montage.png" >> "$temp_list_file_full"
        echo ""
        echo "Making a montage for group" $group
        #cat $temp_list_file
        montage @"$temp_list_file" -tile "1x$tract_count" -geometry +0+0 -background black "${output_path}/${group}_montage.png"
    done <<< "$unique_groups"
    #rm -r $temp_dir
    #echo ""
    #echo "The full list of tract paths is:"
    #cat ${temp_list_file_full}
    # Use ImageMagick's montage tool to stitch the images in a grid
    echo ""
    echo "Making a combined montage"
    #montage @"$temp_list_file_full" -tile "${max_files}x${#unique_groups[@]}" -geometry +5+6+2+0 -background black ${output_path}/output_montage_comb.png
    montage @"$temp_list_file_full" -tile "${group_count}x1" -geometry +5+6+2+0 -background black ${output_path}/output_montage_comb.png
    # Display the stitched image
    #display  ${output_path}/output_montage_comb.png
    rm ./group_data.txt # clean-up
    rm $temp_list_file # clean-up
    rm $temp_list_file_full # clean-up

else
    echo "No 'Group' column found."
    #mkdir -p ${output_path}
    ###
    #sh ${script_path}/get_MIP_screenshot_loop_flex.sh ${script_path}/get_MIP_screenshot.sh ${group_data} ${tract_path} ${window_slices} ${output_path} ${display_brain} ${group_to_process} ${template}
    ##########
    # Stitch the output images group-wise.
    # Extract the column number for "Tract"
    #tract_column=$(echo "$header" | tr '\t' '\n' | grep -n "Tract" | cut -d: -f1)
    ######
    #if [ -n "$tract_column" ]; then
        # Extract unique tracts and store them in a variable
    #    unique_tracts=$(tail -n +2 "$file" | cut -f"$tract_column" | sort | uniq)
    #else
    #    echo "No 'Tract' column found."
    #fi
    #######
    # Create a temporary directory to store the image paths for montage
    #temp_list_file="image_list.txt" > "$temp_list_file"  # Clear the file if it already exists
   # for tract in "${unique_tracts[@]}"; do
    #	    image_path="${output_path}/${tract}.png"
    #	    if [[ -f "$image_path" ]]; then
    #            echo "$image_path" >> "$temp_list_file"
    #        else
    #            echo "Warning: Image for $tract does not exist: $image_path"
    #        fi
    #done
    # Use ImageMagick's montage tool to stitch the images in a single column
    #montage @"$temp_list_file" -tile x${#unique_tracts[@]} -geometry +5+5 -background black ${output_path}/output_montage.png
    # Display the stitched image
    #display  ${output_path}/output_montage.png

fi


