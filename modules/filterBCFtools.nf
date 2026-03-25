process filterBCF {
    label 'process_low'
    container 'staphb/bcftools:1.23'

    tag "$sample_id"
    publishDir("$params.outdir/VCF", mode: "copy")

    input:
    tuple val(sample_id), path(vcf)

    output:
    tuple val("$sample_id"), path("bcf_filtered.vcf.gz"), path("bcf_filtered.vcf.gz.tbi")

    script:
    // Define thresholds based on the 'degraded_dna' flag
    def min_qual = params.degraded_dna ? 20 : 30
    def min_dp   = params.degraded_dna ? 5  : 10

    """
    echo "Running bcftools filtering for: ${sample_id}"

    # Logic Breakdown:
    # 1. FORMAT/GQ >= min_qual : Keeps high-confidence genotypes
    # 2. FORMAT/DP >= min_dp   : Ensures enough reads support the site
    # 3. Allele Balance (AB)   : For 'het' calls, Alt reads should be 20-80% of total
    #    (Expressed as AD[1]/FORMAT/DP)

    bcftools filter \\
        -e "FMT/GQ < ${min_qual} || FMT/DP < ${min_dp} || (GT='het' && (FMT/AD[:1]/FMT/DP) < 0.2) || FILTER == '.'" \\
        -s "LowConf" \\
        -m + \\
        -O z \\
        -o bcf_filtered.vcf.gz \\
        ${vcf}

    # Index the filtered output
    bcftools index -t bcf_filtered.vcf.gz
    """
}