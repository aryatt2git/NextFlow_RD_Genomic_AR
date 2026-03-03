/*
 * Define the indexGenome process that creates a BWA index
 * given the genome fasta file
 */
process DragMap {

    if (params.platform == 'local') {
        label 'process_high'
    } else if (params.platform == 'cloud') {
        label 'process_high'
    }

    container 'fauzul/dragmap:1.0'

    // Publish indexed files to the specified directory
    publishDir("$params.outdir/DRAGMAP", mode: "copy")

    input:
    tuple val(sample_id), path(trimmed_reads)
    path(genomeFasta)

    output:
    tuple val(sample_id), file("${sample_id}.bam")

    script:
    """
    echo "Building hash table of human genome fasta file"

    mkdir -p dragen_index

    # Generate DragMap hash table
    dragen-os --build-hash-table true --num-threads 4 --ht-reference "${genomeFasta}" --output-directory dragen_index

    dragen-os --num-threads 4 -r dragen_index -1 "${trimmed_reads[0]}" -2 "${trimmed_reads[1]}" > "${sample_id}.bam"

    echo "Mapping complete."
    """
}