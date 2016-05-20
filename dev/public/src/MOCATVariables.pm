package MOCATVariables;
use strict;
use warnings;
use Exporter;

# This code is part of the MOCAT analysis pipeline
# Code is (c) Copyright EMBL, 2012-2016
# This code is released under GNU GPL v3.

our @ISA = 'Exporter';
our @EXPORT = qw/@BWA @BOWTIE2 $RUN_MODULE $screened_files $extracted_files $cpu_module $cpus @mod_overrides @mod_overrides_all %mod_overrides %mod_overrides_all %use3files @mod_optional_all %mod_optionals @mod_optional $MODLOG $modcomment $MODCFG @MODULE_DB %mod_requests @mod_requested_all @mod_requested $mod_single_job $mod_dir @MODULE_PARAM $MODULE_OPTION $CALCULATE_HORIZONTAL_COVERAGE $VERBOSE $SHM $profiling_v2 @do_paste_coverage_files @do_profiling $TEMP $profiling_mode @databases $only_regenerate_reads $carma_file_to_annotate $print_final_text $SCREEN_FASTA_FILE $use_old_version $ziplevel $use_extracted_reads $realtime_status $carma_file @do_annotate_using_carma_file $ZIP @all_commands @args $data_dir_bkup $import_max_sample_name $import_path $version $coverage_prog_type $extract_genes $systemType $ZCAT $cpu $calculate_coverage_assembly $calculate_coverage_reads $activate_dev $only_print $no_execute $assembly $reads $screen_fasta_file @screen $cwd $bin_dir $scr_dir $src_dir $data_dir $qsub @samples %conf $sep $sample_file $config_file $no_temp $tc_max $do_cluster_genes $do_import_old $do_redo_scaf @do_calculate_coverage $do_extract_genes $do_import @do_calculate_multiplemappers $do_calculate_taxonomic_composition $do_run_carma_annotation $importOldScafLength $coverage_version_1 @do_summarize_carma_coverages $taxo_profiling_cog @do_taxo_profiling $taxo_profiling_mode @taxo_profiling_insert @taxo_profiling_base @do_analyze $run_on_host $date $analyze_function $analyze_downsample $analyze_type $analyze_norm $analyze_taxa $analyze_desc $analyze_file $analyze_group $analyze_condA $analyze_condB @analyze_settings @analyze_output $pcf_uniq @analyze_metadata $analyze_project_name @analyze_feature_annotations $analyze_running_galaxy $functional_profiling_eggnog_map $sample_file_basename $total_jobs_to_submit $jobdir @do_functional_profiling $functional_profiling_kegg_map $functional_profiling_temp @do_resistance_screen $resistance_screen_reads2 $use_extracted_reads2 $output_file $analyze_downsample_size $taxo_profiling_ids $run_carma_annotate_host1 $run_carma_annotate_host2 @do_group_by_column $do_fetch_mg $extract_genes_scaftig $SampleStatusExcel2_useAssembly $multiple_mappers_summarize_level $username $hostname @do_calculate_taxonomy $gbc_map @reads $calculateTaxonomy_manual_stats_file $calculateTaxonomy_previous_calc_coverage_stats_file @do_virulence_screen $identity2 $no_paste $only_paste $resistance_screen_refgenecatalog $rownames_dir $resistance_screen_suffix $PUBLIC $OUTPUT_FOLDER $MOCAT_ID $preprocessSOLiD $database_name $INTERNAL_MOCAT_VERSION $MOCAT_DESCRIPTION $MOCAT_DESCRIPTION_FILE $INTERNAL_NCBI_VERSION $ext_dir $INTERNAL_TAXONOMIC_VERSION $INTERNAL_FUNCTIONAL_VERSION $INTERNAL_MOTU_VERSION $INTERNAL_GENERAL_VERSION $INTERNAL_VIRULENCE_VERSION $INTERNAL_RESISTANCE_VERSION $INTERNAL_GENE_VERSION $INTERNAL_A_VERSION $INTERNAL_B_VERSION $INTERNAL_C_VERSION $INTERNAL_X_VERSION $INTERNAL_Y_VERSION $INTERNAL_Z_VERSION $profiling_SAM/;
our (@BWA, @BOWTIE2, $RUN_MODULE, $extracted_files, $screened_files, $cpu_module, $cpus, @mod_overrides_all, @mod_overrides, %mod_overrides_all, %mod_overrides, %use3files, %mod_optionals, @mod_optional_all, @mod_optional, $MODLOG, $modcomment, $MODCFG, @MODULE_DB, %mod_requests, @mod_requested, @mod_requested_all, $mod_single_job, $mod_dir, @MODULE_PARAM, $MODULE_OPTION, $VERBOSE, $CALCULATE_HORIZONTAL_COVERAGE, $SHM, $profiling_v2, @do_paste_coverage_files, @do_profiling, $TEMP, $profiling_mode, $reads, @databases, $carma_file_to_annotate, $only_regenerate_reads, $print_final_text, $SCREEN_FASTA_FILE, $use_old_version, $ziplevel, $use_extracted_reads, $realtime_status, $carma_file, @do_annotate_using_carma_file, $ZIP, @all_commands, @args, $data_dir_bkup, $import_max_sample_name, $import_path, $version, $coverage_prog_type, $extract_genes, $systemType, $ZCAT, $cpu, $calculate_coverage_assembly, $calculate_coverage_reads, $activate_dev, $only_print, $no_execute, $assembly, $screen_fasta_file, @screen, $cwd, $bin_dir, $src_dir, $scr_dir, $data_dir, $qsub, @samples, %conf, $sep, $sample_file, $config_file, $no_temp, $tc_max, $do_cluster_genes, $do_import_old, $do_redo_scaf, @do_calculate_coverage, $do_extract_genes, $do_import, @do_calculate_multiplemappers, $do_calculate_taxonomic_composition, $do_run_carma_annotation, $importOldScafLength, $coverage_version_1, @do_summarize_carma_coverages, @do_taxo_profiling, $taxo_profiling_mode, @taxo_profiling_insert, @taxo_profiling_base, @do_analyze, $run_on_host, $date, $analyze_function,$analyze_downsample,$analyze_type,$analyze_norm,$analyze_taxa,$analyze_desc,$analyze_file,$analyze_group,$analyze_condA,$analyze_condB,@analyze_settings,@analyze_output, $pcf_uniq, @analyze_metadata, $analyze_project_name, @analyze_feature_annotations, $analyze_running_galaxy, $functional_profiling_eggnog_map, $sample_file_basename, $total_jobs_to_submit, $jobdir, @do_functional_profiling, $functional_profiling_kegg_map, $functional_profiling_temp, @do_resistance_screen, $resistance_screen_reads2, $use_extracted_reads2, $output_file, $analyze_downsample_size, $run_carma_annotate_host2, $run_carma_annotate_host1, @do_group_by_column, $do_fetch_mg, $extract_genes_scaftig, $SampleStatusExcel2_useAssembly, $multiple_mappers_summarize_level, $username, $hostanme, @do_calculate_taxonomy, $gbc_map, @reads, $calculateTaxonomy_manual_stats_file, $calculateTaxonomy_previous_calc_coverage_stats_file, @do_virulence_screen, $identity2, $no_paste, $only_paste, $resistance_screen_refgenecatalog, $rownames_dir, $resistance_screen_suffix, $database_name, $PUBLIC, $OUTPUT_FOLDER, $MOCAT_ID, $preprocessSOLiD, $INTERNAL_MOCAT_VERSION, $MOCAT_DESCRIPTION, $MOCAT_DESCRIPTION_FILE, $INTERNAL_NCBI_VERSION, $ext_dir, $INTERNAL_TAXONOMIC_VERSION, $INTERNAL_FUNCTIONAL_VERSION, $INTERNAL_MOTU_VERSION, $INTERNAL_GENERAL_VERSION, $INTERNAL_VIRULENCE_VERSION, $INTERNAL_RESISTANCE_VERSION, $INTERNAL_GENE_VERSION, $INTERNAL_A_VERSION, $INTERNAL_B_VERSION, $INTERNAL_C_VERSION, $INTERNAL_X_VERSION, $INTERNAL_Y_VERSION, $INTERNAL_Z_VERSION, $profiling_SAM );

1;


 