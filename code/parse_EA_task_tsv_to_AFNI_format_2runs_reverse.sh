#!/usr/bin/env bash
#SBATCH --partition=low-moby
#SBATCH --array=1-2
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#BSATCH --mem-per-cpu=1G
#SBATCH --time=1:00:00
#SBATCH --export=ALL
#SBATCH --job-name="AFNI_convert_task_1D_SPN20"
#SBATCH --output=/projects/loliver/ModSoCCS/data/logs/parse_EA_task_tsv_to_AFNI_format_SPN20_%j.txt

# this sublist includes the full directory name # ZHP participants with timing issue are not in this list
sublist="/projects/loliver/ModSoCCS/data/processed/EA_task_1D_sublist_reverse.txt"
index () {
	  head -n $SLURM_ARRAY_TASK_ID $sublist \
	  | tail -n 1
	 }

sub_indir="/archive/data/SPN20/data/nii"
sub_outdir="/projects/loliver/ModSoCCS/data/processed/"
full=`index`
site=$(echo $full| cut -c 7-9)
subnum=$(echo $full| cut -c 11-14)
subj="$site$subnum"
bids="sub-$site$subnum"
ses=$(echo $full| cut -c 16-17)

python3 /projects/loliver/ModSoCCS/code/parse_EA_task_tsv_to_AFNI_format_2runs_reverse.py ${sub_indir}/`index` ${subj} ${sub_outdir}/${bids}/ses-${ses}

