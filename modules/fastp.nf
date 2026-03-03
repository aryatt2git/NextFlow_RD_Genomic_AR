/*
 * Run fastp on the read fastq files to generate trimmed reads into a zipped fastq files.
 */
process FASTP {

    container 'staphb/fastp:1.1.0'

    tag "{$sample_id}_fastp"

    publishDir("$params.outdir/FASTP", mode: "copy")

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}_FASTP/*.fastq.gz"), emit: trimmed_reads
    path "${sample_id}_FASTP/*.{html,json}"

    script:
    """
    echo "Running FASTP"
    mkdir -p ${sample_id}_FASTP
    fastp \
        -i ${reads[0]} \
        -I ${reads[1]} \
        -o ${sample_id}_FASTP/${sample_id}_1_fastp.fastq.gz \
        -O ${sample_id}_FASTP/${sample_id}_2.fastp.fastq.gz \
        --html ${sample_id}_FASTP/${sample_id}_fastp.html \
        --json ${sample_id}_FASTP/${sample_id}_fastp.json
    echo "FASTP Complete"
    """
}

workflow {
    read_pairs_ch = Channel
            .fromPath(params.samplesheet)
            .splitCsv(sep: '\t')
            .map { row ->
                if (row.size() == 4) {
                    tuple(row[0], [row[1], row[2]])
                } else if (row.size() == 3) {
                    tuple(row[0], [row[1]])
                } else {
                    error "Unexpected row format in samplesheet: $row"
                }
            }

    FASTP(read_pairs_ch)

    FASTQC(FASTP.out.trimmed_reads)
}