#!/bin/bash

#SBATCH --job-name EA_time_series_individualized_rois
#SBATCH --cpus-per-task=3
#SBATCH --output=/projects/loliver/ModSoCCS/data/logs/EA_time_series_individualized_rois.txt
#SBATCH --error=/projects/loliver/ModSoCCS/data/logs/EA_time_series_individualized_rois.err
#SBATCH --array=1-46

module load ciftify
# change array to =2 to test on CMH0002 #1-46

# extract EA residual signal from each individualized weighted ROI at each timepoint
sublist=/projects/loliver/ModSoCCS/data/processed/cifti_clean_sublist.txt  # this includes sub-

index() {
   head -n $SLURM_ARRAY_TASK_ID $sublist \
   | tail -n 1
}

subj=`index`
dir=/projects/loliver/ModSoCCS/data/processed/${subj}
session=$(ls -d -- ${dir}/ses*)
 
    for sesdir in ${session}; do
      ses=$(basename ${sesdir})
      #sesnum=$(echo $ses| cut -c 1-6)

      if [ ! -f ${dir}/${ses}/${subj}_${ses}_EA_2mm_noGSR_individualized_rois_allmeants.csv ]; then
        ciftify_meants --weighted --outputcsv ${dir}/${ses}/${subj}_${ses}_EA_2mm_noGSR_left_premotor_meants.csv ${dir}/${ses}/${subj}_task-emp_1stlevel-residual.dscalar.nii ${dir}/rois/${subj}_left_premotor_weightedseed.dscalar.nii
        ciftify_meants --weighted --outputcsv ${dir}/${ses}/${subj}_${ses}_EA_2mm_noGSR_right_premotor_meants.csv ${dir}/${ses}/${subj}_task-emp_1stlevel-residual.dscalar.nii ${dir}/rois/${subj}_right_premotor_weightedseed.dscalar.nii
        ciftify_meants --weighted --outputcsv ${dir}/${ses}/${subj}_${ses}_EA_2mm_noGSR_left_ips_meants.csv ${dir}/${ses}/${subj}_task-emp_1stlevel-residual.dscalar.nii ${dir}/rois/${subj}_left_ips_weightedseed.dscalar.nii
        ciftify_meants --weighted --outputcsv ${dir}/${ses}/${subj}_${ses}_EA_2mm_noGSR_right_ips_meants.csv ${dir}/${ses}/${subj}_task-emp_1stlevel-residual.dscalar.nii ${dir}/rois/${subj}_right_ips_weightedseed.dscalar.nii
        cat ${dir}/${ses}/${subj}_${ses}_EA_2mm_noGSR_individualized_rois_meants.csv ${dir}/${ses}/${subj}_${ses}_EA_2mm_noGSR_left_premotor_meants.csv ${dir}/${ses}/${subj}_${ses}_EA_2mm_noGSR_right_premotor_meants.csv ${dir}/${ses}/${subj}_${ses}_EA_2mm_noGSR_left_ips_meants.csv ${dir}/${ses}/${subj}_${ses}_EA_2mm_noGSR_right_ips_meants.csv > ${dir}/${ses}/${subj}_${ses}_EA_2mm_noGSR_individualized_allrois_meants.csv
      fi
    done

