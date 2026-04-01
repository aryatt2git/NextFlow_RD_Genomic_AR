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

    output:
    tuple val(sample_id), path("${sample_id}.summary.csv")
    tuple val(sample_id), path("${sample_id}.*")

    script:
    def ref_fasta = genome_stuff.find { it.name =~ /fasta$/ }

    """
    echo "Comparing VCFs with benchmark"

    # Generate BowTie2 index
    hap.py ${benchmarkVCF} ${vcf} \
        -f ${benchmarkBED} \
        -T ${queryBED} \
        -r ${ref_fasta} \
        -o $sample_id \
        --threads ${task.cpus} \
        --engine vcfeval

    echo "Comparison finished."
    """
}