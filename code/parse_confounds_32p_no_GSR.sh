#!/usr/bin/env bash
#SBATCH --partition=low-moby
#SBATCH --array=1-40
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#BSATCH --mem-per-cpu=1G
#SBATCH --time=1:00:00
#SBATCH --export=ALL
#SBATCH --job-name="parse_confounds_32p_no_GSR_Modsoccs"
#SBATCH --output=/projects/loliver/ModSoCCS/data/logs/parse_confounds_32p_no_GSR_Modsoccs_%j.txt

# these confound files didn't need to be fixed (unlike SPINS and SPASD) - don't have the same issue as we use the in-scanner normalized T1s
# sublist includes site and number 
sublist="/projects/loliver/ModSoCCS/data/processed/3dDeconvolve_sublist_meeting.txt"

index () {
	  head -n $SLURM_ARRAY_TASK_ID $sublist \
	  | tail -n 1
	 }

sub_indir="/archive/data/SPN20/pipelines/in_progress/output/fmriprep"
sub_outdir="/projects/loliver/ModSoCCS/data/processed"
sub_id="sub-`index`"

#mkdir -p ${sub_outdir}/${sub_id}/
#mkdir -p ${sub_outdir}/${sub_id}/ses-01
#mkdir -p ${sub_outdir}/${sub_id}/ses-02

ses_dirs=$(find ${sub_indir}/${sub_id}/ -type d -name "ses-0*")

for dir in ${ses_dirs}; do
    ses=$(basename ${dir})
    #ses=$(echo $run_dir| cut -c 1-6)
    if [ ! -f ${sub_outdir}/${sub_id}/${ses}/${sub_id}_ea_confounds_no_GSR_glm.1D ]; then
      python3 /projects/loliver/ModSoCCS/code/parse_confounds_32p_no_GSR.py ${sub_indir}/${sub_id}/${ses}/func "`index`" ${sub_outdir}/${sub_id}/${ses}
    fi

done
