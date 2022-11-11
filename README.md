ModSoCCS Analysis
===============================================

Analysis of pre- and post-rTMS functional connectivity in SSDs

Created by Lindsay Oliver lindsay.oliver@camh.ca

Project Organization
-----------------------------------

    .
    ├── README.md          <- The top-level README
    ├── .gitignore         <- Files to not upload to github - includes /data
    ├── data
    │   ├── processed      <- Processed data
    │   └── raw            <- Raw data
    │
    ├── notebooks          <- R notebooks for analysis workflow
    │
    ├── docs/references    <- Data dictionaries, manuals, and all other explanatory materials
    │
    ├── reports            <- Generated analysis as HTML, PDF, LaTeX, etc.
    │   └── figures        <- Generated graphics and figures to be used in reporting
    │
    ├── requirements.txt   <- The requirements file for reproducing the analysis environment 
    │
    ├── code               <- Source code for use in this project (virtual environments, bash scripts, etc.)
    
    
    
This directory contains scripts to wrangle data and generate files needed to run the EA GLM with 2 mm smoothing, without GSR for ModSoCCS (SPN20) participants.

Code directory includes scripts to run the EA GLM and generate files needed for analyses:
Activate corresponding python env before running any .py scripts using source /projects/loliver/ModSoCCS/code/py_venv/bin/activate
1) cifti_clean_EA_2mm.sh to smooth outputs (2 mm) and drop first 4 TRs after fmriprep and ciftify have been run
2) parse_EA_task_tsv_to_AFNI_format_2runs.sh (which runs parse_EA_task_tsv_to_AFNI_format_2runs.py) to generate 1D regressor files needed for the GLM from the EA task tsvs
   For ZHP participants before trigger change (see below): parse_EA_task_tsv_to_AFNI_format_2runs_ZHP.sh (which runs parse_EA_task_tsv_to_AFNI_format_2runs_ZHP.py) 
3) parse_confounds_*.sh (which runs corresponding parse_confounds_*.py, without GSR) to generate confound regressor file needed for the GLM
4) EA_GLM_*mm.sh (which runs corresponding EA_GLM_*mm.py, with 2 mm smoothing, without GSR) to run the EA GLM # these output names should be updated to bids
5) extract_time_series_EA_2mm_noGSR_Schaefer2018_*Parcels_17Networks_order.sh to extract EA residual signal from each Schaefer 400 or 1000 ROI at each timepoint (17 network order)


Important GLM Notes:
For the SPINS ZHP (Zucker Hillside Prisma) scans collected before June 14, 2022, the trigger occurred prior to dummy scan collection (6000 ms duration), after which data acquistiion actually began. Thus, onset times need to be adjusted by subtracting 6000 ms from the recorded video onset time - trigger time for these scans (in EA_task_1D_sublist_ZHP.txt). After sub-ZHP0019, the trigger onset coincided with actual data collection (starting with sub-ZHP0023).

Slice timing correction was not performed for this data using fmriprep, so we assume no alterations were made in terms of registering to the middle vs the onset of a TR.
The -stim_times_subtract option was used to correct for this in SPINS, but this has been commented out for now. See below:
The -stim_times_subtract = -0.4 option for 3dDeconvolve subtracts the specified number of seconds from each time encountered in any '-stim_times*' option (or in this case adds 0.4 seconds).  The purpose of this option is to make it simple to adjust timing files for the removal of images from the start of each imaging run. This was implemented for SPINS based on the recommendation from this post https://reproducibility.stanford.edu/slice-timing-correction-in-fmriprep-and-linear-modeling, which essentially outlines that fMRIprep registers to the middle slice of a TR for slice timing correction by default but linear modeling using AFNI's 3dDeconvolve (and nilearn) assumes that the data are acquired at time zero (so need to adjust by half a TR). The -stim_times_subtract option is included in the model.py script for 3dDeconvolve in nipype. 


Other Notes:
For CMH0003 ses-01, manually renamed ciftify output files to make frmiprep run order match EA task run order (switched run 1 and 2), and deleted concatenated confound files and replaced them with the runs in reverse order (run order and EA run order do not match). For CMH0003 ses-01 and MRP0010 ses-02, their task tsvs need to be sorted in reverse (CMH0003 due to run order and EA order not matching; MRP0010 orders match, but they get sorted incorrectly because an EA run was repeated).

EA task tsv parsing scripts need to be updated once we decide on naming and organization of these files (order in which files are pulled in).

Participants with nan values in their EA 1D regressor files:
sub-CMH0001/ses-01
sub-CMH0002/ses-01
sub-CMH0003/ses-01
sub-MRP0005/ses-01
sub-MRP0009/ses-02
sub-MRP0019/ses-01

nan values in EA 1D regressor files occur when a participant's EA responses can't be correlated with the target's responses due to a lack of responding during the task. The GLM will not run successfully in this case. I updated nan values to 0 for these participants to allow the GLM to run successfully.


Virtual environment notes:
The nipype 3dDeconvolve interface doesn’t include some 3dDeconvolve options by default (AM2 option, polort A, xjpeg, residuals and full model), so the corresponding model.py script in the virtual env needed to be updated accordingly (the AM2 option in particular is needed for parametric modulation)
Here, /projects/loliver/ModSoCCS/code/py_venv/lib/python3.8/site-packages/nipype/interfaces/afni/model.py
It's probabyly easiest to copy or use this virtual env vs making these changes yourself if you are re-running this.

polort A addition:
polort_A = traits.Str(
        desc="Set the polynomial order automatically " "[default: A]",
        argstr="-polort %s",
    )

AM2 addition:
num_stimts = traits.Int(
        desc="number of stimulus timing files",
        argstr="-num_stimts %d",
        position=-6,
    )
 stim_times_AM2 = traits.List(
        traits.Tuple(
        traits.Int(desc="k-th R model"),         File(
                 desc="stimulus timing file with different duration to class k"
             ),
             Str(desc="model"),
         ),
         desc="generate two resonpose models: one with th emean amplittude and one with the differences from the mean.",
         argstr="-stim_times_AM2 %d %s '%s'...",
         position=-6,
     )

Then need to change num_stimts position to -7

Also need to change:
stim_label = traits.List(
        traits.Tuple(
            traits.Int(desc="k-th input stimulus"), Str(desc="stimulus label")
        ),
        desc="label for kth input stimulus (e.g., Label1)",
        argstr="-stim_label %d %s...",
        requires=["stim_times", "stim_times_AM2"], ## THIS LINE RIGHT HERE
        position=-4,
    )

xjpeg:
xjpeg = File(
        desc="specificy name for a JPEG file graphing the X matrix",
        argstr="-xjpeg %s",
    )

residuals and full model:
res_file = File(desc="output residual files", argstr="-errts %s")
    full_model = File(
        desc="output the (full model) time series fit to the input data",
        argstr="-fitts %s",
    )

Also need to comment out REML outputs (different model type):
class DeconvolveOutputSpec(TraitedSpec):
    out_file = File(desc="output statistics file", exists=True)
    #reml_script = File(
    #    desc="automatical generated script to run 3dREMLfit", exists=True
    #)

 # outputs["reml_script"] = self._gen_fname(suffix=".REML_cmd", **_gen_fname_opts)

