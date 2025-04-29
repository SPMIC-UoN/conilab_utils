#!/bin/bash

echo "---"
echo "-----"
echo "----- MatSub.sh"
echo "----- To submit Matlab jobs to the HPC: overcoming issues with quote marks and such!"
echo "_____"
echo "___"
echo ""
echo ""
echo ""
echo ""

Usage() {
    cat << EOF

Usage: MatSub.sh -run <path> [OPTIONS] -args <arguments> -q <job_queue> -t <time>

    Compulsory arguments:
       -run <path>                                Path to Matlab function
       -u <uniqueID>                              A unique identifer for the slurm submission, e.g. sub100206

    Options:
       -args <arguments>                          Matlab function/script arguments, if multiple arguments then use speech marks and provide as Matlab function requires, 
                                                  e.g. -args "'hello', 'world', 'cat', 'dog'" - each word is an argument
       -q <job_queue>                             Sumbit job to a specified queue, e.g. 'shortq'
       -t <time>                                  Time allocated to job, default 01:00:00
       -m <memory>                                Memory allocated to job, default 1 GB
       -w <jobID>                                 Gives a job dependency, jobID is a SLURM ID.

EOF
    exit 1
}

[ "$1" = "" ] && Usage

if [ $# -lt 4 ]; then
    echo
    echo
    echo "Incorrect arguments, please check the usage and retry."
    echo
    echo
    echo $Usage
    exit 1
fi

q="cpu" # default queue is any cpu queue
args="" # default args is no args

# Parse command-line arguments
while [ ! -z "$1" ];do
    case "$1" in
      -run) matloc=$2;shift;;
      -u) u=$2;shift;;
      -args) args=$2;shift;;
      -q) q=$2;shift;;
      -t) t=$2;shift;;
      -m) m=$2;shift;;
      -w) w=$2;shift;;
      *) echo "Unknown option '$1'";exit 1;;
    esac
    shift
done

# Default time/memory
if [ "${t}" == "" ]; then t="01:00:00"; fi
if [ "${m}" == "" ]; then m="1"; fi

# split matlab file path
matP=${matloc%/*}
matF=${matloc##*/}

# Check Matlab file exists
if [ "${matF: -2}" == ".m" ];
then
    if [ ! -f "${matP}/${matF}" ]; then
	echo "Could not find Matlab function file"
	exit 1
    fi
else
    if [ ! -f "${matP}/${matF}.m" ]; then
	echo "Could not find Matlab function file"
	exit 1
    fi
fi

# check if contains the ".m"
if [ "${matF: -2}" == ".m" ]; then len=${#matF}; matF=${matF:0:((len-2))}; fi

module load matlab-uon

js="bash jobsub -q ${q} -p 1 -t ${t} -m ${m} -s ${u}_${matF} "
# Handling job dependency
if [ "${w}" != "" ]; then js="${js} -w ${w}"; fi
js="${js} -c"


subthis=`pwd`/${u}_${matF}
if [ -f ${subthis} ]; then
    i=0
    while [ i=0 ]; do
	if [ -f ${subthis} ]; then
	    subthis="${subthis}+"
	else
	    i=1; break
	fi
    done
    echo "Job file already exists."
    echo "Submitting job with name ${subthis}"
fi

echo '#!/bin/bash' > ${subthis}

# Does the command have arguments to pass?
if [ "${args}" = "" ]; then
    echo "matlab -nodisplay -nosplash -r \"cd ${matP}; ${matF}; quit;\"" >> ${subthis}
    echo "Submitting ${matF}"
else
    echo "matlab -nodisplay -nosplash -r \"cd ${matP}; ${matF}(${args}); quit;\"" >> ${subthis}
    echo "Submitting ${matF}(${args})"
fi
echo ""

eval ${js} \"bash ${subthis}\"

