#!/bin/bash

#SBATCH --job-name cifti_clean_EA_2mm
#SBATCH --cpus-per-task=2
#SBATCH --output=/projects/loliver/ModSoCCS/data/logs/cifti_clean_EA_2mm.txt
#SBATCH --error=/projects/loliver/ModSoCCS/data/logs/cifti_clean_EA_2mm.err
#SBATCH --array=1-40

module load ciftify
module load connectome-workbench/1.4.1
shopt -s extglob

# cifti clean EA data, including 2 mm smoothing and dropping 4 TRs (no actual cleaning) - this sublist includes sub-
sublist=/projects/loliver/ModSoCCS/data/processed/cifti_clean_sublist_meeting.txt 

index() {
   head -n $SLURM_ARRAY_TASK_ID $sublist \
   | tail -n 1
}

input=/archive/data/SPN20/pipelines/in_progress/output/ciftify
output=/projects/loliver/ModSoCCS/data/processed
mkdir -p ${output}/`index`/
mkdir -p ${output}/`index`/ses-01
mkdir -p ${output}/`index`/ses-02

task_dirs=$(find ${input}/`index`/MNINonLinear/Results/ -type d -name "ses-0*_task-emp*")

for dir in ${task_dirs}; do
    run_dir=$(basename ${dir})
    ses=$(echo $run_dir| cut -c 1-6)
    if [ ! -f ${output}/`index`/${ses}/`index`_${run_dir}_Atlas_s2.dtseries.nii ]; then
      ciftify_clean_img  \
      --output-file=${output}/`index`/${ses}/`index`_${run_dir}_Atlas_s2.dtseries.nii \
      --no-cleaning \
      --smooth-fwhm=2   --drop-dummy-TRs=4 \
      --left-surface=${input}/`index`/MNINonLinear/fsaverage_LR32k/`index`.L.midthickness.32k_fs_LR.surf.gii  \
      --right-surface=${input}/`index`/MNINonLinear/fsaverage_LR32k/`index`.R.midthickness.32k_fs_LR.surf.gii  \
      ${input}/`index`/MNINonLinear/Results/${run_dir}/${run_dir}_Atlas_s0.dtseries.nii
    fi
    
    #Convert cifti back to nifti
    wb_command -cifti-convert -to-nifti ${output}/`index`/${ses}/`index`_${run_dir}_Atlas_s2.dtseries.nii \
                                   ${output}/`index`/${ses}/`index`_${run_dir}_Atlas_s2.nii
     
done

