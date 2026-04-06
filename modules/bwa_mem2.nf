process BWA_MEM2 {

    if (params.platform == 'local') {
        label 'process_medium'
    } else if (params.platform == 'cloud') {
        label 'process_medium'
    }

    container 'shinejh0528/bwa-mem2:1.2.0-samtools'

    tag "$sample_id"

    // Publish indexed files to the specified directory
    publishDir("$params.outdir/BWA_MEM2", mode: "copy")

    input:
    tuple val(sample_id), path(trimmed_reads)
    path(bwa_mem_2_genome_file)
    path(bwa_mem_2_index_files)

    output:
    tuple val(sample_id), path("${sample_id}_bwa-mem2.bam"), emit: bam

    script:
    // BWA-MEM2 requires the prefix of the index.
    // We assume the index files share the same base name as the fasta.
    // def fastaName = genomeFasta.name
    def rg = "@RG\\tID:${sample_id}\\tSM:${sample_id}\\tPL:ILLUMINA"

    """
    echo "Mapping Reads to Genome"

    export PATH="/usr/src/bwa-mem2/:\$PATH"
    export PATH="/usr/bin/:\$PATH"

    bwa-mem2 mem \\
        -t ${task.cpus} \\
        -R "${rg}" \\
        ${bwa_mem_2_genome_file} \\
        ${trimmed_reads[0]} ${trimmed_reads[1]} \\
        | samtools sort -@ ${task.cpus} -o ${sample_id}_bwa-mem2.bam -

    echo "Mapping complete."
    """
}