process MULTIQC {
    label 'process_low'

    container 'multiqc/multiqc:pdf-dev'

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