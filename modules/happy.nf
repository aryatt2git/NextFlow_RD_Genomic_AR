process happy {

    if (params.platform == 'local') {
        label 'process_medium'
    } else if (params.platform == 'cloud') {
        label 'process_medium'
    }

    container 'pkrusche/hap.py:v0.3.9'

    tag "$sample_id"

    // Publish indexed files to the specified directory
    publishDir("$params.outdir/HAPPY", mode: "copy")

    input:
    tuple val(sample_id), path(vcf), path(vcf_idx)
    path(benchmarkVCF)
    path(benchmark_idx)
    path(benchmarkBED)
    path(queryBED)
    path(genomeFasta)
    path(genome_idx)

    output:
    tuple val(sample_id), path("./*")

    script:
    """
    echo "Comparing VCFs with benchmark"

    # Generate BowTie2 index
    hap.py ${benchmarkVCF} ${vcf} -f ${benchmarkBED} -T ${queryBED} -r ${genomeFasta} -o $sample_id --threads ${task.cpus}

    echo "Comparison finished."
    """
}