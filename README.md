# Conilab Utils

This is a collection of utils scripts used by the conilab. It is also amalgamating previous util directories into one central place.

## Contributing

Please feel free to contribute anything you might think is helpful! 

The general philsopsohy is the onus is on the person using it to make it work not the contributer.

However, please make sure that scripts are named and put in the right folder. Also this is an open repo so don't put passwords/API keys/personal details

Also please don't update README/delete file_tree.py. Github bot updates the content section of the readme on each push 

## Content 

```
└── scripts
    ├── Biobank_scripts
    │   ├── lateralisation.m
    │   ├── lateralisation_HCP.m
    │   └── tract_stats.m
    ├── MIP_visualisation
    │   ├── MIP_pipeline_general.sh
    │   ├── MIP_pipeline_general_flag.sh
    │   ├── StepsToRun.txt
    │   ├── create_comb_table.sh
    │   ├── get_MIP_screenshot.sh
    │   ├── get_MIP_screenshot_loop_general.sh
    │   ├── get_ThreshSummary.sh
    │   └── info_table_test.txt
    ├── TBSS_lesion
    │   ├── tbss_1_preproc_lesions
    │   └── tbss_2_reg_lesions
    ├── Tractography
    │   ├── Matrix1
    │   │   ├── ParcelConn.sh
    │   │   ├── PostProcMatrix1_SW.sh
    │   │   ├── RunMatrix1.sh
    │   │   ├── average_results.sh
    │   │   └── mymatx1.sh
    │   ├── Matrix2
    │   │   ├── OLDtracts
    │   │   │   ├── blueprint.m
    │   │   │   ├── blueprintLinux.m
    │   │   │   ├── blueprint_averagingWBC.sh
    │   │   │   ├── bpTractLoop.m
    │   │   │   ├── bpTractLoopLinux.m
    │   │   │   ├── save_scene.m
    │   │   │   ├── savebpCii.m
    │   │   │   ├── savebpCiiLinux.m
    │   │   │   └── v1
    │   │   │       ├── blueprint.m
    │   │   │       ├── blueprintLinux.m
    │   │   │       ├── bpTractLoop.m
    │   │   │       ├── bpTractLoopLinux.m
    │   │   │       ├── savebpCii.m
    │   │   │       └── savebpCiiLinux.m
    │   │   ├── PreTractography.sh
    │   │   ├── RunMatrix2.sh
    │   │   ├── atlas_blueprinting
    │   │   │   ├── blueprintLinux_atlas.m
    │   │   │   ├── blueprint_averagingWBC.sh
    │   │   │   ├── bpTractLoopLinux_atlas.m
    │   │   │   ├── readme
    │   │   │   ├── save_scene_atlas.m
    │   │   │   └── savebpCiiLinux_atlas.m
    │   │   ├── log_transform.m
    │   │   ├── medial_wall
    │   │   │   ├── PreTractography_medial_wall.sh
    │   │   │   ├── RunMatrix2_medial_wall.sh
    │   │   │   ├── blueprintLinux_medial_wall.m
    │   │   │   ├── bpTractLoopLinux_medial_wall.m
    │   │   │   ├── save_scene_medial_wall.m
    │   │   │   └── savebpCiiLinux_medial_wall.m
    │   │   ├── mymatx2.sh
    │   │   ├── mymatx2_medial_wall.sh
    │   │   ├── structureList
    │   │   ├── subID_prep.m
    │   │   ├── v0
    │   │   │   ├── blueprintAve.m
    │   │   │   ├── blueprintLinux.m
    │   │   │   ├── blueprint_averagingWBC.sh
    │   │   │   ├── blueprint_averagingWBC.sh~
    │   │   │   ├── bpTractLoopLinux.m
    │   │   │   ├── readme
    │   │   │   ├── save_scene.m
    │   │   │   ├── savebpCiiLinux.m
    │   │   │   └── savebpCiiLinuxtemp.m
    │   │   └── v1
    │   │       ├── blueprintAveV1.m
    │   │       ├── blueprintLinuxV1.m
    │   │       ├── blueprint_averagingWBCV1.sh
    │   │       ├── bpTractLoopLinuxV1.m
    │   │       ├── readme
    │   │       ├── save_sceneV1.m
    │   │       └── savebpCiiLinuxV1.m
    │   ├── Theoretical_actual_gyral_bias.m
    │   ├── Tractography_gpu_scripts
    │   │   ├── ParcelConn.sh
    │   │   ├── PostProcMatrix1.sh
    │   │   ├── PostProcMatrix3.sh
    │   │   ├── PreTractography.sh
    │   │   ├── RunMatrix1.sh
    │   │   ├── RunMatrix3.sh
    │   │   ├── scripts
    │   │   │   ├── MakeTrajectorySpace.sh
    │   │   │   ├── MakeTrajectorySpace_MNI.sh
    │   │   │   ├── MakeWorkbenchUODFs.sh
    │   │   │   └── separate_FS_labels.m
    │   │   └── separate_FS_labels.m
    │   ├── ave_dconn.sh
    │   ├── ave_matrix1_dconn.sh
    │   └── map_averaging
    │       ├── averageFA_FAreg.sh
    │       ├── averageFA_tensorreg.sh
    │       ├── average_V1.sh
    │       ├── average_kurt.sh
    │       ├── average_maps.sh
    │       ├── average_myelinmap.m
    │       ├── split_averaging.sh
    │       ├── split_data.sh
    │       └── split_data.sh~
    ├── cluster
    │   ├── MatSub.sh
    │   ├── clusterControl.sh
    │   ├── fsl_sub
    │   ├── jobsub
    │   └── jobsub_README.txt
    ├── git_scripts
    │   ├── git_commit.py
    │   └── linting_pre_commit
    └── img_utils
        ├── TDI.sh
        ├── ants2fnirt.sh
        └── down_sample_surfaces.sh
```
