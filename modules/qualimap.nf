process QUALIMAP {
    tag "$sample_id"
    label 'process_medium'

    container 'quay.io/biocontainers/qualimap:2.3--hdfd78af_0'

    publishDir("$params.outdir/MULTIQC/qualimap", mode: "copy")

    input:
    tuple val(sample_id), path(bam), path(bai)
    path target_bed  // optional, pass [] if WGS

    output:
    tuple val(sample_id), path("${sample_id}_qualimap"), emit: results

    script:
    def target = target_bed.name != 'NO_FILE' ? "--feature-file ${target_bed}" : ""
    """
    qualimap bamqc \
        -bam ${bam} \
        ${target} \
        -outdir ${sample_id}_qualimap \
        -outformat HTML \
        --paint-chromosome-limits \
        -nt ${task.cpus}
    """
}