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
    tuple val(sample_id), file(bamFile), file(bamIndex)
    path(genomeFasta)
    path(genomeFai)

    output:
    tuple val("$sample_id"), path("${sample_id}.g.vcf.gz"), path("${sample_id}.g.vcf.gz.tbi"), emit: gvcf

    script:
    """
    configureStrelkaGermlineWorkflow.py \
    --bam "${bamFile}" \
    --referenceFasta "${genomeFasta}" \
    --runDir . \
    --exome
    # execution on a single local machine with 20 parallel jobs
    ./runWorkflow.py -m local -j ${task.cpus}

    mv ./results/variants/variants.vcf.gz ${sample_id}.g.vcf.gz
    mv ./results/variants/variants.vcf.gz.tbi ${sample_id}.g.vcf.gz.tbi
    """
}

process mergeGVCFs {
    container 'staphb/bcftools:1.23'

    // Publish indexed files to the specified directory
    publishDir("$params.outdir/STRELKA2/COMBINED_VCF", mode: "copy")

    input:
    tuple val(sample_ids), path(gvcf_files), path(gvcf_index_files) // collected from all samples

    output:
    tuple val("cohort"), path("cohort_joint.vcf.gz"), path("cohort_joint.vcf.gz.tbi")

    script:
    """
    bcftools merge --force-samples --force-single -Oz -o cohort_joint.vcf.gz ${gvcf_files}
    bcftools index -t cohort_joint.vcf.gz
    """
}