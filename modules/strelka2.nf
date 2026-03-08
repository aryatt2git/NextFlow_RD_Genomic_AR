/*
 * Define the indexGenome process that creates a BWA index
 * given the genome fasta file
 */
process Strelka2 {

    if (params.platform == 'local') {
        label 'process_medium'
    } else if (params.platform == 'cloud') {
        label 'process_medium'
    }

    container 'blcdsdockerregistry/strelka2:2.9.10'

    tag "$sample_id"

    // Publish indexed files to the specified directory
    publishDir("$params.outdir/STRELKA2", mode: "copy")

    input:
    tuple val(sample_id), path(bamFile), path(bamIndex)
    path(genomeFiles)

    output:
    tuple val("$sample_id"), path("*.g.vcf.gz"), path("*.g.vcf.gz.tbi"), emit: gvcf

    script:
    """
    if [[ -n params.genome_file ]]; then
        genomeFasta=\$(basename ${params.genome_file})
    else
        genomeFasta=\$(find -L . -name '*.fasta')
    fi

    configureStrelkaGermlineWorkflow.py \
    --bam "${bamFile}" \
    --referenceFasta \${genomeFasta} \
    --runDir . \
    --exome
    # execution on a single local machine with 20 parallel jobs
    ./runWorkflow.py -m local -j ${task.cpus}

    outputVCF="\$(basename ${bamFile} .bam)_strelka2.g.vcf.gz"
    outputVCFidx="\$(basename ${bamFile} .bam)_strelka2.g.vcf.gz.tbi"

    mv ./results/variants/variants.vcf.gz \${outputVCF}
    mv ./results/variants/variants.vcf.gz.tbi \${outputVCFidx}
    """
}

process mergeGVCFs {
    container 'staphb/bcftools:1.23'

    // Publish indexed files to the specified directory
    publishDir("$params.outdir/STRELKA2/COMBINED_VCF", mode: "copy")

    input:
    tuple val(sample_ids), path(gvcf_files), path(gvcf_index_files) // collected from all samples

    output:
    tuple val("${sample_ids.join('_')}"), path("*_combined.vcf"), emit: mergedGVCFs
    path("*_combined.vcf.gz")
    path("*_combined.vcf.gz.tbi")

    script:
    def merged_sample_id = "${sample_ids.join('_')}"
    def gvcf_files_args = gvcf_files.collect { file -> "-V ${file}" }.join(' ')
    """
    bcftools merge --force-samples --force-single -Oz -o ${merged_sample_id}_combined.vcf.gz ${gvcf_files}
    bcftools index -t ${merged_sample_id}_combined.vcf.gz

    gunzip -k ${merged_sample_id}_combined.vcf.gz
    """
}