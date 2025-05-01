#! /bin/bash
# script to down sample surfaces from a subject list. 
module load workbench-img

function usage {
  echo -e '\n\033[38;5;93mScript to Downsample HCP data\033[0;0m. \n\nUSAGE:'
  echo -e '\t-s:\t-s \n\t\tPath to study directory. \033[1;31mREQUIRED\033[0;0m'
  echo -e '\t-i:\tID:\n\t\t-n Number of vertexes. \033[1;31mREQUIRED\033[0;0m'
  echo -e "Example Usage: setup_qunex -s /home/user/study_folder -n 1000 \n"
  exit 0
}


while getopts "s:n:h\?" opt; do
  case $opt in
    s) subj=${OPTARG};;
    n) nvert=${OPTARG};;
    h) usage;;
    \?) echo -e "\033[1;31mInvalid option. Use -h for help:\033[0;0m$OPTARG" >&2; exit 1;;
  esac
done

if [ "$#" -eq 0 ]; then
  usage
fi

echo "Working on: $(basename $subj)"
rm -rf ${sub}/downsample
# seed and medial wall
# downsample the medial wall mask and the seed masks
sph=$(basename $subj)
sub=$subj/sessions/$sph/hcp/$sph
mkdir ${sub}/downsample
nvert=10000 # approx
echo $sub
wb_command -surface-create-sphere ${nvert} ${sub}/${sph}.R.surf.gii
wb_command -surface-flip-lr ${sub}/${sph}.R.surf.gii ${sub}/${sph}.L.surf.gii
wb_command -set-structure ${sub}/${sph}.R.surf.gii CORTEX_RIGHT
wb_command -set-structure ${sub}/${sph}.L.surf.gii CORTEX_LEFT

# the medial wall mask
for side in L R; do
  wb_command -metric-resample ${sub}/MNINonLinear/fsaverage_LR32k/${sph}.${side}.atlasroi.32k_fs_LR.shape.gii \
      ${sub}/MNINonLinear/fsaverage_LR32k/${sph}.${side}.sphere.32k_fs_LR.surf.gii\
      ${sub}/${sph}.${side}.surf.gii BARYCENTRIC $sub/${sph}.${side}.atlasroi.resampled_fs_LR.shape.gii
  # threshold - actually just rounding
  wb_command -metric-math 'round(m)' ${sub}/${side}.atlasroi.resampled_fs_LR.shape.gii \
      -var m $sub/${sph}.${side}.atlasroi.resampled_fs_LR.shape.gii
  wb_command -surface-resample ${sub}/MNINonLinear/fsaverage_LR32k/${sph}.${side}.white.32k_fs_LR.surf.gii \
    ${sub}/MNINonLinear/fsaverage_LR32k/${sph}.${side}.sphere.32k_fs_LR.surf.gii \
    ${sub}/${sph}.${side}.surf.gii BARYCENTRIC ${sub}/${sph}.${side}.white.resampled_fs_LR.surf.gii
