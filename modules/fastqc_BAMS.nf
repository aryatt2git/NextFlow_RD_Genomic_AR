/*
 * Run fastq on the read fastq files
 */
process FASTQC_BAM {

    label 'process_single'

    container 'variantvalidator/fastqc:0.12.1'

    // Add a tag to identify the process
    tag "$sample_id"

    // Specify the output directory for the FASTQC results
    publishDir("$params.outdir/FASTQC_BAM", mode: "copy")

    input:
    tuple val(sample_id), path(bamFile)

    output:
    path "fastqc_BAMS_${sample_id}_logs/*"

    script:
    """
    echo "Running FASTQC"
    mkdir -p fastqc_BAMS_${sample_id}_logs
    fastqc -t ${task.cpus} -o fastqc_BAMS_${sample_id}_logs ${bamFile}
    echo "FASTQC Complete"
    """
}
