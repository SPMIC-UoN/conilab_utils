
module load fsl

tract_path=$1
tractlist=$2
outfile=$3
dat_type=$4 # either "single" or "group"
overwrite=$5

echo "For all tracts the minimum threshold is 0.1% except for the Emc parts (93rd percentile used)."

if [[ "${overwrite}" == "yes" ]]; then echo Tract Max Min > ${outfile}; fi

if [[ "${overwrite}" == "no" ]]; then echo "Output file already exists. Appending."; fi

if [ $dat_type == "single" ]; then for trc in `cat ${tractlist}`; do tract=${tract_path}/${trc}/densityNorm.nii.gz; if [[ "$trc" =~ (EmC|slf) ]]; then read val1 <<< $(fslstats ${tract} -l 0 -P 99.95); read val2 <<< $(fslstats ${tract} -l 0 -P 93); read cog_x cog_y cog_z <<< $(fslstats ${tract} -c); echo "${trc//.nii.gz/}","${val1}","${val2}" >> ${outfile}; fi; if [[ ! "$trc" =~ (EmC|slf) ]]; then read val1 <<< $(fslstats ${tract} -l 0 -P 99.95); echo "${trc//.nii.gz/}","${val1}","0.001" >> ${outfile}; fi; done; fi 

if [ $dat_type == "group" ]; then for trc in `cat ${tractlist}`; do tract=${tract_path}/${trc}.nii.gz; if [[ "$trc" =~ (EmC|slf) ]]; then read val1 <<< $(fslstats ${tract} -l 0 -P 99.95); read val2 <<< $(fslstats ${tract} -l 0 -P 93); read cog_x cog_y cog_z <<< $(fslstats ${tract} -c); echo "${trc//.nii.gz/}","${val1}","${val2}" >> ${outfile}; fi; if [[ ! "$trc" =~ (EmC|slf) ]]; then read val1 <<< $(fslstats ${tract} -l 0 -P 99.95); echo "${trc//.nii.gz/}","${val1}","0.001" >> ${outfile}; fi; done; fi
