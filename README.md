# manuscript-bacGC

# Instructions to reproduce analysis in "Evolutionary jumps in bacterial GC content"

This document describes the instructions, datasets, and code to reproduce the results in the research article ["Evlutionary jumps in GC content"](https://doi.org/10.1101/2021.02.16.431469).
					
## Datasets
1. The original phylogeny was obtained from GTDB (https://data.gtdb.ecogenomic.org/releases/release80/80.0/bac120_r80.tree). To run the following code and replicate results, this file should be placed in- “/Input_data/phylogenies/GTDB_bac120_r80.tree”.
2. We sub-sampled this original GTDB phylogeny using a custom script which is documented in the R notebook- “/Codes/tree_pruning_GTDB.Rmd”. This notebook also contains code corresponding to the choice of the specific threshold for sub-sampling. The resulting sub-sampled/pruned phylogeny will be generated in the file- “/Input_data/phylogenies/GTDB_bac120_r80_pruned0.01.newick”.
3. We obtained the metadata corresponding to the original phylogeny from GTDB (https://data.gtdb.ecogenomic.org/releases/release80/80.0/bac_metadata_r80.tsv). From this, the previous R notebook also extracts the metadata corresponding to the sub-sampled phylogeny; this metadata will be generated in the file- “/Input_data/phylogenies/GTDB_bac_metadata_r80_pruned0.01.tsv”.
4. The extraction of order-level clades can be reproduced using the notebook- “/Codes/extracting_order_level_clades.Rmd”. The code in this notebook also extracts GC content data corresponding to each order-level clade used for further analysis. The output tree files for each order-level clade can be found at- “/Input_data/phylogenies/X_GTDB_14k_tree.newick” and the files containing corresponding GC contents can be found at “/Input_data/phylogenies/X_GTDB_14k_GC.txt”.
5. Here X represents the 10 order-level clades used in our analysis- Alpha1 (Acetobacterales and other clades), Rhizobiale, Rhodobacterale, Sphingomonadale, Bacteroidale, Flavobacteriale, Cytophagale, Betaproteo, Pseudomonadale, or Enterobacterale.
	
## Comparing trait evolution models
1. We fit the basic Brownian and Ornstein-Uhlenbeck (OU models) to GC contents of different order-level clades using R-package geiger. The fitting procedure can be reproduced using the following script- “/Codes/fitting_Brownian_and_OU_to_order_level_clades.Rmd”.
2. The Levy jumps model was fit using the software levolution as suggested in the documentation (https://bitbucket.org/WegmannLab/levolution/wiki/Launching%20levolution). Levolution can be run by supplying a parameter config file, input phylogeny, and trait data (here, GC content).
3. The parameter config file corresponding to the Bacteroidales (an order-level clade) used in this example is available at- “/Input_data/levolution_config_files/levolution_Bacteroidale_GTDB_14k_GC_config1_alpha0.1.param”.
	1. The config file specifies the parameters for the algorithm and also one parameter of the Lévy jumps model (α, relative magnitude of jumps).
	2. The maximum likelihood can be evaluated for different values of α by changing its value in this input parameter config file.
 4. The levolution program should be run from the directory- “/Input_data/levolution_files_inference_actual_data/” and the output files are also generated in the same directory.
 5. This command at the terminal will execute levolution and direct the output to a log file: “path_to_levolution/levolution ../levolution_config_files/levolution_Bacteroidale_GTDB_14k_GC_config1_alpha0.1.param tree=../phylogenies/Bacteroidale_GTDB_14k_tree.newick traits=../phylogenies/Bacteroidale_GTDB_14k_GC.txt out=Bacteroidale_GTDB_14k_GC_config1_alpha0.1 > levolution_Bacteroidale_GTDB_14k_GC_config1_alpha0.1.log”.
 6. The following files are generated as an output of the above config file, in the same directory-
 	1. Bacteroidale_GTDB_14k_GC_config1_alpha0.1.post (a phylogeny with branch lengths equal to posterior probabilities of >0 jumps on a branch)
 	2. Bacteroidale_GTDB_14k_GC_config1_alpha0.1_oneLineSummary.txt (a summary of likelihood and best-fit parameter values)
 	3. levolution_Bacteroidale_GTDB_14k_GC_config1_alpha0.1.log (a log file where on-screen output is directed)

## Identification of GC content jumps
1. As described in the main text, we decided posterior probability thresholds to identify jumps by using a simulation approach.
	1. First, for a given order-level clade, we simulated jumps on the phylogeny according to a Levy jumps model using best-fit parameter values obtained via levolution (previous section). These simulations can be run using this R notebook- “/Codes/GC_Levy_jumps_simulations_GTDB.Rmd” which sources and calls the function “/Codes/ex_jump_simulator.R”. This notebook returns simulated trait data for each taxa, as well as the location of jumps in the following two example output files-
		1. trait data file: /Input_data/levolution_files_inference_simulated_data/Bacteroidale_GTDB_14k_GC_config1_alpha0.25_geigerSim1.traits
		2. file with details of simulated jumps (including locations, magnitude etc.):
/Input_data/levolution_files_inference_simulated_data/Bacteroidale_GTDB_14k_GC_config1_alpha0.25_geigerSim1.details (contains locations of simulated jumps)
	2. Second, as described for actual data (previous section), we inferred posterior probability of jumps in this simulated data using levolution. An example output file with the inferred probabilities can be found here (the branch length of the tree in the file are posterior probabilities of observing >0 jumps on that branch)- “/Input_data/levolution_files_inference_simulated_data/Bacteroidale_GTDB_14k_GC_config1_alpha0.25_geigerSim1.post”.
	3. Third, using the exactly known location of simulated jumps from step 1 and the inferred posterior probabilities by levolution in step 2, we can calculate the precision and recall of jumps for different posterior probability thresholds. This is described in detail in the main text, and the implementation can be reproduced by using the R notebook- “/Codes/precision_recall_curves_simulated_jumps.Rmd”.
	4. This code outputs the precision-recall curves for each clade (Figure S1) in “/Results/geigerSim_results/”.
	5. Fourth, we decided the posterior probability thresholds (to be used for jump inference from actual data) after visually assessing the precision-recall curves. For each-order-level clade, the threshold was chosen to maximize recall (as much as possible), while retaining >90% precision (see main text for details).
	6. The R notebook-  “/Codes/precision_recall_curves_simulated_jumps.Rmd” also summarizes the variation in precision and recall at the chosen thresholds.
The branches whose posterior probabilities (of jumps >0) inferred from actual GC content data were greater than the thresholds decided above were identified as those experiencing GC content jumps.
7. Code in the same notebook also plots recall rate of jumps by their magnitude (Fig S2).

## Analysis of inferred jumps
1. We first mapped the branches with jumps to the phylogenies of each order-level clade. Using the branch-specific posterior probabilities generated in 2f.i and the posterior probability thresholds decided in 3e. 
2. The image files can be obtained by running the code in this R notebook - “/Codes/levolution_jump_mapping_phylogeny.Rmd”. This notebook generates all image files in “.svg” format in the folder – “levolution_files_inference_actual_data/”, e.g. “levolution_Bacteroidale_GTDB_14k_GC_config1_alpha0.25_pp0.95_unlabelled_jumpNum_magma_scale.svg”. These images appear as Figure 1, 2 and Figure S3-S10 in the manuscript.
3. The jump magnitudes and directions can be summarized and plotted using this R notebook- “/Codes/levolution_jumps_analysis.Rmd”. This code generates Figure 3 in the manuscript. The code in this notebook also:
	1. Generates a directory for results of the analysis of jumps- “/Results/jumps_analysis/” and subdirectories for each jump e.g. “/Results/jumps_analysis/Sphingomonadale_jump1/”.
	2. Extracts phylogenetic data for each jump such as the GTDB labels for taxa in the focal clade (on whose stem branch a jump is inferred), sister clade, and 2 successive outgroup clades (where available). It also generates a newick tree and image files for the relevant subtree, where the focal clade branches are colored orange and sister clade branches are colored purple. This data can be found in the subdirectory of each jump.
	3. Generates files with summary of jumps (“/levolution_jumps_feature_summaries.tab”) such as number of taxa in each clade and summary of features (all_features_comparison_table.tab) such as median GC content of focal and sister clades, the difference in GC (i.e. approximate magnitude of the GC jump), and the oxygen-dependence of taxa in the focal and sister clades. These files can be found in the “/Results/jumps_analysis/” directory.
	4. The raw data for oxygen dependence can be found in “/Input_data/trait_data/”.
4. Figure 4 is generated by the R script  based on a manually created table (found in “/Results/jump_analysis/Ecology_GCdirection_proportions.tab”) which summarizes data from Table S4 and S5.

## Supplementary analysis
1. The section "Analysis of jump heights vs branch heights" in the R notebook "/Codes/levolution_jumps_analysis.Rmd" also plots the distribution of branch heights in actual phylogenies, expected distribution of heights if GC jumps were randomly placed, and distribution of actual heights at which GC jumps occur. These appear is Fig S11.
2. The R notebook "Code/deltaGC_from_ribosomal.Rmd" compares the magnitudes of GC jumps as calculated from all CDS and ribosomal protein genes. These appear in Fig S12.