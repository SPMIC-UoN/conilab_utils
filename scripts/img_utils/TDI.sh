#!/bin/sh

if [ "$4" == "" ];then
    echo ""
    echo " TDI <bpxdir> <brain_mask> <resolution - in mm> <outdir> [frac=1] [ptxOptions]"
    echo ""
    echo " frac is the fraction of brain voxels (between 0 and 1) included as seeds"
    echo " these are randomly spread"
    echo " If mask is not in diffusion space ptxOptions must be defined for xfm=seed2diff, invxfm=diff2seed, seedref"
    echo ""
    exit 1
fi

bpxdir=$1
brain_mask=$2
outres=$3
outdir=$4
shift;shift;shift;shift
frac=1
if [ "$1" != "" ];then
    frac=$1
    shift
fi
opts=$@

mkdir -p $outdir

echo flirting
$FSLDIR/bin/flirt -in $brain_mask \
    -out $outdir/highresmask \
    -ref $brain_mask -applyisoxfm $outres -interp nearestneighbour

if [ "$frac" != 1 ];then
    echo subsampling
    $FSLDIR/bin/fslmaths $outdir/highresmask -mul 0 -rand -mas $outdir/highresmask -uthr $frac -bin $outdir/highresmask
fi

o=""
o="$o --opd --opathdir --forcedir -P 5 --sampvox=1 -S 20 --randfib=1 -m $bpxdir/nodif_brain_mask"
o="$o --dir=${outdir} -s $bpxdir/merged -x $outdir/highresmask"

echo probtrackxing
#fsl_sub -q bigmem.q 
$FSLDIR/bin/probtrackx2_gpu $o $opts -V 0
