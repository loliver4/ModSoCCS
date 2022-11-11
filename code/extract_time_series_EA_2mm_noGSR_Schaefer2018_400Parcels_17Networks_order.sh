#!/bin/bash

#SBATCH --job-name EA_time_series_schaefer400_17net
#SBATCH --cpus-per-task=4
#SBATCH --output=/projects/loliver/ModSoCCS/data/logs/EA_time_series_schaefer400_17net_2mm_noGSR.txt
#SBATCH --error=/projects/loliver/ModSoCCS/data/logs/EA_time_series_schaefer400_17net_2mm_noGSR.err

module load ciftify

# extract EA residual signal from each Schaefer 400 ROI at each timepoint (17 network order)

sub_dir=$(ls -d -- /projects/loliver/ModSoCCS/data/processed/sub*) # lists ea subject directories

#sub_dir=$(ls -d -- /projects/loliver/ModSoCCS/data/processed/sub-CMH0002)

for dir in ${sub_dir}; do
    subj=$(basename ${dir})
    session=$(ls -d -- ${dir}/ses*)
 
    for sesdir in ${session}; do
      ses=$(basename ${sesdir})
      #sesnum=$(echo $ses| cut -c 1-6)

      if [ ! -f ${dir}/${ses}/${subj}_${ses}_EA_2mm_noGSR_schaefer400_17net_meants.csv ]; then
        ciftify_meants --outputcsv ${dir}/${ses}/${subj}_${ses}_EA_2mm_noGSR_schaefer400_17net_meants.csv ${dir}/${ses}/${subj}_glm_ea_1stlevel_residual.dscalar.nii /projects/loliver/ModSoCCS/data/parcellations/Schaefer2018_400Parcels_17Networks_order.dlabel.nii
      fi
    done
done

