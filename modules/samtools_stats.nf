process SAMTOOLS_STATS {
    tag "$sample_id"
    label 'process_medium'

    container 'quay.io/biocontainers/samtools:1.23.1--ha83d96e_0'

    publishDir("$params.outdir/MULTIQC/samtools", mode: "copy")

    input:
    tuple val(sample_id), path(bam), path(bai)

    output:
    tuple val(sample_id), path("${sample_id}.flagstat"), emit: flagstat
    tuple val(sample_id), path("${sample_id}.stats"),    emit: stats

    script:
    """
    samtools flagstat --threads ${task.cpus} ${bam} > ${sample_id}.flagstat
    samtools stats --threads ${task.cpus} ${bam} > ${sample_id}.stats
    """
}