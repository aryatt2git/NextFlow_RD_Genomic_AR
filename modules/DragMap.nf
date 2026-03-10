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
    path(genomeFiles)

    output:
    tuple val(sample_id), file("${sample_id}_dragmap.bam")
    path("dragen_index/*")

    script:
    """
    echo "Mapping reads to reference using DragMap."

    mkdir -p dragen_index

    if [[ -n params.genome_file ]]; then
        genomeFasta=\$(basename ${params.genome_file})
    else
        genomeFasta=\$(find -L . -name '*.fasta')
    fi

    # Generate DragMap hash table
    dragen-os --build-hash-table true --num-threads ${task.cpus} --ht-reference \${genomeFasta} --output-directory dragen_index

    dragen-os --num-threads ${task.cpus} -r dragen_index -1 "${trimmed_reads[0]}" -2 "${trimmed_reads[1]}" > "${sample_id}_dragmap.bam"

    echo "Mapping complete."
    """
}