# Script to apply script get_MIP_screenshot.sh in a loop based on look-up table values.

#!/bin/bash

input_script=$1
input_table=$2

dat_type=$3 # can be "single" or "group"

tract_path=$4
window_slices=$5
output_path=$6

display_brain=$7

group_to_process=$8  # "Human" or "Macaque"
#output_table="updated_${input_table}"  # Define output file name

template=$9

#cat ${input_table}

#merged_table=$(echo "$input_table" | awk -F',' -v val="${group_to_process}" 'BEGIN{OFS=","} {print val, $0}')

#echo ${merged_table}

# Define your function
my_function_single() {
    local col1=$1 # species
    local col2=$2 # group
    local col3=$3 # tract
    local col4=$4 # maximum value (ie 99.95th prc)
    local col5=$5 # minimum value (ie 0.001 or prescribed percentile for specific tract)
    local col6=$6 # x_loc
    local col7=$7 # y_loc
    local col8=$8 # z_loc
    #local col4=$(printf "%.0f" "$3")  # Round col4
    #local col5=$(printf "%.0f" "$4")  # Round col5
    #local tract_path=$9
    #local window_slices=${10}
    #local output=${11}
    #local display_brain=${12}
    #####
    tract_file=${tract_path}/${col3}/densityNorm.nii.gz
    #####
    output=${output_path}/${col3}.png
    #####
    echo "Processing: Col1=$col1, Col2=$col3, Col3=$col4, Col4=$col5, Col5=$col6, Col6=$col7, Col7=$col8"
    #####
    # Replace with your actual function
    sh "${input_script}" "$tract_file" "$col6" "$col7" "$col8" "$col4" "$col5" "$window_slices" "$output" "$display_brain" "$group_to_process" "$template"
}


my_function_group() {
    local col1=$1 # species
    local col2=$2 # group
    local col3=$3 # tract
    local col4=$4 # maximum value (ie 99.95th prc)
    local col5=$5 # minimum value (ie 0.001 or prescribed percentile for specific tract)
    local col6=$6 # x_loc
    local col7=$7 # y_loc
    local col8=$8 # z_loc
    #local col4=$(printf "%.0f" "$3")  # Round col4
    #local col5=$(printf "%.0f" "$4")  # Round col5
    #local tract_path=$9
    #local window_slices=${10}
    #local output=${11}
    #local display_brain=${12}
    #####
    tract_file=${tract_path}/${col3}.nii.gz
    #####
    output=${output_path}/${col3}.png
    #####
    echo "Processing: Col1=$col1, Col2=$col3, Col3=$col4, Col4=$col5, Col5=$col6, Col6=$col7, Col7=$col8"
    #####
    # Replace with your actual function
    sh "${input_script}" "$tract_file" "$col6" "$col7" "$col8" "$col4" "$col5" "$window_slices" "$output" "$display_brain" "$group_to_process" "$template"
}

# Read file while skipping the first line (header)

#tail -n +2 "${merged_table}" | while IFS=',' read -r col1 col2 col3 col4 col5 col6 col7 col8; do
    #my_function "$tract_file" "$col6" "$col7" "$col8" "$col5" "$col4" "$window_slices" "$output" "$display_brain"
    # Only process rows that match the selected group (A or B)
#    if [[ "$col1" == "$group_to_process" ]]; then
#        my_function "$col1" "$col2" "$col3" "$col4" "$col5" "$col6" "$col7" "$col8"
#    else
#        echo "Skipping: $col2 (Group $col1 does not match selected group $group_to_process)"
#    fi
#done


#awk -F',' -v group="$group_to_process" 'BEGIN {OFS=","} NR==1 {print "Group", $0} NR>1 {if ($1 == group) {print group, $0}}' "$input_table" | \

while IFS=',' read -r col1 col2 col3 col4 col5 col6 col7 col8; do
    # Ensure the row matches the desired group (it should already be filtered by awk)
    #echo ${col1}
    if [[ "$col1" == "$group_to_process" ]]; then
	if [ $dat_type == "single" ]; then
        	my_function_single "$col1" "$col2" "$col3" "$col4" "$col5" "$col6" "$col7" "$col8"
	fi
	if [ $dat_type == "group" ]; then
                my_function_group "$col1" "$col2" "$col3" "$col4" "$col5" "$col6" "$col7" "$col8"
        fi
    else
        echo "Skipping: $col2 (Group $col1 does not match selected group $group_to_process)"
    fi
done < "${input_table}"
