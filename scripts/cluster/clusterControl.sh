#!/bin/bash

echo "---"
echo "-----"
echo "----- For all of your cluster control needs: clusterControl!"
echo "_____"
echo "___"



Usage() {
    cat << EOF

Usage: clusterControl -u <username> -f <function> -bounds <lower-bound> <upper-bound> -q <job_queue>

    Compulsory arguments:
       -u <username>                              Username of the user who submitted the jobs (e.g. msxsaw)
       -f <function>                              'cancel', 'hold', 'release', 'suspend', 'resume', 'update'
       -bounds <lower-bound> <upper-bound>        Lowest and highest job ID to be included (limits are inclusive)


    Options:
       -q <job_queue>                             Limit management to a specified queue, e.g. 'imgpascalq'

       IF -f update
       -p <partition> <qos>                       <partition> Partition to move the job to (e.g. voltaq, hmemq, imgvoltaq)
                                                  <qos> QOS to move the job to ('hpc' or 'img')

       cancel  = cancel, i.e. stop, the following jobs
       hold    = prevent the following jobs from running
       release = cancel the hold, allow the following jobs to start after being previouly on hold
       suspend = susend the following jobs at the current stage
       resume  = re-start a job after being suspended
       requeuehold = requeue jobs previously held to a pending state
       move = change the partition and/or QOS of a job

       For full details enter 'scontrol --help' or 'scancel --help' into the command line

EOF
    exit 1
}

[ "$1" = "" ] && Usage

if [ $# -lt 7 ]; then
    echo
    echo
    echo "Incorrect arguments, please check the usage and retry."
    echo
    echo
    echo $Usage
    exit 1
fi

q="" # default queue is any queue

# Parse command-line arguments
while [ ! -z "$1" ];do
    case "$1" in
      -u) uname=$2;shift;;
      -f) f=$2;shift;;
      -bounds) lB=$2;uB=$3;shift;shift;;
      -q) q=$2;shift;;
      -p) partition=$2;qos=$3;shift;shift;;
      *) echo "Unknown option '$1'";exit 1;;
    esac
    shift
done

# Check which slurm manager command to use
if [ "${f}" == "cancel" ]; then
    cmd="scancel";
elif [ "${f}" == "hold" ] || [ "${f}" == "release" ] || [ "${f}" == "suspend" ] || [ "${f}" == "resume" ] || [ "${f}" == "requeuehold" ]; then
    cmd="scontrol ${f}"
elif [ "${f}" == "update" ]; then
    cmd="scontrol ${f} partition=${partition} qos=${qos} jobid="
fi

if [ "${q}" == "" ]; then
    echo "'${f}'-ing jobs on any queue within ${lB} - ${uB} range"
else
    echo "'${f}'-ing jobs on ${q} within ${lB} - ${uB} range"
fi

echo ""
echo ""

if [ "${f}" == "hold" ]; then
    tempList=(`squeue -u ${uname} | grep "${q}" | grep -v "JobHeldUser" | awk '{print $1}'`)
elif [ "${f}" == "release" ] || [ "${f}" == "requeuehold" ]; then
    tempList=(`squeue -u ${uname} | grep "${q}" | grep "JobHeldUser" | awk '{print $1}'`)
else
    tempList=(`squeue -u ${uname} | grep "${q}" | awk '{print $1}'`)
fi

jobList=()
for i in ${tempList[@]}
do
    if [[ ! "${i}" == *".b"* ]] && [[ ! "${i}" == "JOBID" ]] && [[ "${i}" -ge "${lB}" ]] && [[ "${i}" -le "${uB}" ]]; then
      jobList+=(${i})
    fi
done

echo "Found ${#jobList[@]} jobs in the given bounds."

# Now loop through the available jobs, skip batch jobs and perform task
for i in ${jobList[@]}
do
    if [[ "${i}" == *".b"* ]]; then
        echo "Skipping batch"
    elif [[ ! "${i}" == *".b"* ]]; then
      if [ "${f}" == "update" ]; then
        ${cmd}${i}
      else
        ${cmd} ${i} -u ${uname} # use the user ID here as a safety precaution
      fi
	echo "${f} : ${i}"
    fi
done
