process MULTIQC {
    label 'process_low'

    container 'quay.io/biocontainers/multiqc:1.33--pyhdfd78af_0'

    publishDir("$params.outdir/MULTIQC/multiQC", mode: "copy")

    input:
    path(qc_files, stageAs: "qc_input/*")  // collect all QC outputs

    output:
    path "multiqc_report.html", emit: report

    script:
    """
    multiqc qc_input/ \
        --outdir . \
        --filename multiqc_report.html \
        --verbose
    """
}