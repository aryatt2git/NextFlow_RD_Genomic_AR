/*
 * Define the indexGenome process that creates a BWA index
 * given the genome fasta file
 */
process BowTie2 {

    if (params.platform == 'local') {
        label 'process_medium'
    } else if (params.platform == 'cloud') {
        label 'process_medium'
    }

    container 'quay.io/biocontainers/bowtie2:2.5.5--ha27dd3b_0'

    tag "$sample_id"

    // Publish indexed files to the specified directory
    publishDir("$params.outdir/BOWTIE2", mode: "copy")

    input:
    tuple val(sample_id), path(trimmed_reads)
    path(genomeFasta)

    output:
    tuple val(sample_id), file("${sample_id}.sam")

    script:
    """
    echo "Mapping Reads to Genome"

    # Generate BowTie2 index
    bowtie2-build --threads ${task.cpus} --large-index "${genomeFasta}" GRCh38_index

    bowtie2 -p ${task.cpus} -x GRCh38_index -1 "${trimmed_reads[0]}" -2 "${trimmed_reads[1]}" -S "${sample_id}.sam"

    echo "Mapping complete."
    """
}

process samToBam {

    if (params.platform == 'local') {
        label 'process_medium'
    } else if (params.platform == 'cloud') {
        label 'process_medium'
    }

    container 'variantvalidator/indexgenome:1.1.0'

    tag "$sample_id"

    publishDir("$params.outdir/BOWTIE2", mode: "copy")

    input:
    tuple val(sample_id), path(sam)

    output:
    tuple val(sample_id), path("${sample_id}.bam")

    script:
    """
    samtools view -bS "${sample_id}.sam" > "${sample_id}.bam"
    """
}

