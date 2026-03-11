/*
 * Define the indexGenome process that creates a BWA index
 * given the genome fasta file
 */
process DragMap {

    container 'fauzul/dragmap:1.0'

    // Publish indexed files to the specified directory
    publishDir("$params.outdir/DRAGMAP", mode: "copy")

    input:
    tuple val(sample_id), path(trimmed_reads)
    path(dragen_index)

    output:
    tuple val(sample_id), file("${sample_id}_dragmap.bam"), emit: dragmap_bam

    script:
    """
    echo "Mapping reads to reference using DragMap."

    dragen-os --num-threads ${task.cpus} -r "${dragen_index}" -1 "${trimmed_reads[0]}" -2 "${trimmed_reads[1]}" > "${sample_id}_dragmap.bam"

    echo "Mapping complete."
    """
}