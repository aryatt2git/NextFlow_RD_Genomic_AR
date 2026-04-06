/*
 * Run fastq on the read fastq files
 */
process FASTQC_BAM {

    label 'process_single'

    container 'variantvalidator/fastqc:0.12.1'

    // Add a tag to identify the process
    tag "$sample_id"

    // Specify the output directory for the FASTQC results
    publishDir("$params.outdir/MULTIQC/fastQC", mode: "copy")

    input:
    tuple val(sample_id), path(bamFile), path(bai)

    output:
    tuple val(sample_id), path("*.html"), emit: html
    tuple val(sample_id), path("*.zip"),  emit: zip

    script:
    """
    echo "Running FASTQC"
    fastqc -t ${task.cpus} ${bamFile} -o .
    echo "FASTQC Complete"
    """
}
