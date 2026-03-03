/*
 * Define the indexGenome process that creates a BWA index
 * given the genome fasta file
 */
process indexGenomeBT2 {

    if (params.platform == 'local') {
        label 'process_low'
    } else if (params.platform == 'cloud') {
        label 'process_medium'
    }
    container 'biocontainers/bowtie2:2.4.1_cv1'


    // Publish indexed files to the specified directory
    publishDir("$params.outdir/BOWTIE2", mode: "copy")

    input:
    tuple val(sample_id), path(reads), path(genomeFasta)

    output:
    path("${sample_id}.*")

    script:
    """
    echo "Running Index Genome"

    # Generate BowTie2 index
    bowtie2-build --large-index "${genomeFasta}" GRCh38_index

    bowtie2 -x example/index/lambda_virus -1 "${reads[0]}" -2 "${reads[1]}"


    echo "Mapping complete."
    """
}
