Welcome to the scomputeq slurm wrapper for the Augusta Nottingham HPC

Version 1 : Jan 2019 Author : Dr Keith L Evans Owner : University of Nottingham

This script has two objectives :

1) Build slurm submisison scripts for Augusta 2) Scan available queues for unused resources and direct submissions onto free queues

The script has 5 mandatory arguements and 4 optional ones

Mandatory :

"-q"

Used to inform the script whether to expect a CPU or GPU submission

Correct usage : "-q cpu" or "-q gpu"

"-p"

Used to specify total number of processors required for the job, exact number of processors per node will be determined by the script

Correct usage : "-p 90"

"-s"

Used to specify an unique submission name. It can be any string.

Correct usage : "-s submission001"

"-c"

Used to specify the command to be executed. Use double (or single) quotes to enclose the command.

Correct usage : "-c "./mybinary -arg1 4 -arg2 'h d f' -arg3 abc -arg4 -6"" Correct usage : "-c "./myscript.sh"

"-t"

Used to specify walltime for the job

Correct usage : "-t 00:00:10"

"-m"

Used to specify ram required per node in gbs

Optional Arguments :

"-i"

Used to inform the script to submit the final job interactively using "srun" instead of "sbatch" which is the default

Correct usage : "-i"

"-j"

Used to inform the script that this call is part of a job array submission, i.e. that many jobs are being submitted in sequence and will not allow slurm to catch up, this feature currently only works for GPU jobs

Correct usage : "-j"

"-d"

Used to inform the script to run in debug mode mainly for development with repeated submissions

Correct usage : "-d"

"-w"

Used to specify job dependency, will accept either aingle job ID or mulitple

Correct usage : "-w 01010101" or "-w 01010101:87307494"

"-g"

Used to specify the total number of GPUs required for a gpu job. This argument is mandatory if "-q gpu" is specified.

Correct usage : "-g 1"

Methodology :

The script will individually scan each available queue on the HPC for sufficient idle nodes to submit the job to (after determining the number of nodes required). If insufficient idle nodes are found the script will then scan the partly filled nodes for sufficient resources. If there are still insufficient resources to run the job immediately, the script will default to either imgcomputeq or imgvoltaq depending on the job type.
