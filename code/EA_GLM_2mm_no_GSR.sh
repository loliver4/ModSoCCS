#!/usr/bin/env bash
#SBATCH --partition=low-moby
#SBATCH --array=1-40
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#BSATCH --mem-per-cpu=1G
#SBATCH --time=12:00:00
#SBATCH --export=ALL
#SBATCH --job-name="EA_GLM_2mm_no_GSR_Modsoccs"
#SBATCH --output=/projects/loliver/ModSoCCS/data/logs/EA_GLM_2mm_no_GSR_Modsoccs_%j.txt

module load connectome-workbench/1.4.1
module load AFNI/2017.07.17

sublist="/projects/loliver/ModSoCCS/data/processed/3dDeconvolve_sublist_meeting.txt" 
index () {
	  head -n $SLURM_ARRAY_TASK_ID $sublist \
	  | tail -n 1
	 }

sub_in=/projects/loliver/ModSoCCS/data/processed/sub-`index`/
sub_out=/projects/loliver/ModSoCCS/data/processed/sub-`index`/
sub_id="sub-`index`"

ses_dirs=$(find ${sub_in}/ -type d -name "ses-0*")

for dir in ${ses_dirs}; do
    ses=$(basename ${dir})
    if [ ! -f ${sub_out}/${ses}/*glm_ea_1stlevel.dscalar.nii ]; then
      python3 /projects/loliver/ModSoCCS/code/EA_GLM_2mm_no_GSR.py ${sub_in}/${ses} ${sub_out}/${ses} `index`
    fi
done

