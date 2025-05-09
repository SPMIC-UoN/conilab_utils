# Quick script to create a combined table with [x,y,z] coordinates and intensity values per tract and group.
# Requires the coordinate script and the intensity script to already be obtained either manually or by using another script.

input_loc_table=$1
input_thr_table_path=$2

#head -n 1 "${input_thr_table}" > "$merged_table_exp"
dir_path=$(dirname "$input_loc_table")
echo ${dir_path}

merged_table_exp=${dir_path}/info_table_comb.txt

#head -n 1 "${input_loc_table}" > "$merged_table_exp"

echo Group,Tract,max,min,x,y,z > "$merged_table_exp" 

if [ -n "$3" ]; then 
	group_list=$3 # a list of all the groups that should be part of the table
	for group in `cat ${group_list}`; do 
		input_thr_table=${input_thr_table_path}/${group}_TractVisThresh.txt
		# Create a temporary file for the output of the awk command
		awk -F',' '{print $(NF-2) "," $(NF-1) "," $NF}' ${input_loc_table} > /tmp/loc_columns.txt;
		# Now use paste to merge the two tables
		merged_table=$(paste -d',' ${input_thr_table} /tmp/loc_columns.txt);
		# Clean up temporary file
		rm /tmp/loc_columns.txt;
		# Add group information
		merged_table_grp=$(echo "$merged_table" | awk -F',' -v val="${group}" 'BEGIN{OFS=","} {print val, $0}');
		#echo ${merged_table_grp};
		# Skip the first header row from merged_table_grp and append the res
		echo "$merged_table_grp" | tail -n +2 >> "$merged_table_exp";
	done


else
	echo "No grouping provided. Running as if for one group."
	merged_table_exp=${dir_path}/info_table.txt
	echo Tract,max,min,x,y,z > "$merged_table_exp"
	input_thr_table=${input_thr_table_path}/*_TractVisThresh.txt
	# Create a temporary file for the output of the awk command
        awk -F',' '{print $(NF-2) "," $(NF-1) "," $NF}' ${input_loc_table} > /tmp/loc_columns.txt
        # Now use paste to merge the two tables
        merged_table=$(paste -d',' ${input_thr_table} /tmp/loc_columns.txt)
        # Clean up temporary file
        rm /tmp/loc_columns.txt
	# Save
	echo "$merged_table" | tail -n +2 >> "$merged_table_exp"
fi


