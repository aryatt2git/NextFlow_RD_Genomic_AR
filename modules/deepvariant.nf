process DeepVariant {

    if (params.platform == 'local') {
        label 'process_high'
    } else if (params.platform == 'cloud') {
        label 'process_high'
    }

    container 'google/deepvariant:1.10.0'

    // Publish indexed files to the specified directory
    publishDir("$params.outdir/DEEPVARIANT", mode: "copy")

    input:
    tuple val(sample_id), file(bamFile), file(bamIndex)
    path(genomeFasta)
    path(genomeFai)

    output:
    tuple val(sample_id), path("${sample_id}.g.vcf.gz"), emit: gvcf
    path("${sample_id}.vcf.gz")
    path("${sample_id}.g.vcf")
    path("${sample_id}.vcf")

    script:
    """
    echo "Building hash table of human genome fasta file"

    run_deepvariant \
        --model_type=WES \
        --vcf_stats_report=true \
        --ref="${genomeFasta}" \
        --reads="${bamFile}" \
        --output_vcf=./${sample_id}.vcf.gz \
        --output_gvcf=./${sample_id}.g.vcf.gz \
        --num_shards=${task.cpus}

    gunzip -f -k ${sample_id}.vcf.gz
    gunzip -f -k ${sample_id}.g.vcf.gz

    echo "Variant calling complete."
    """
}

process jointCallDeepVariant {

    label 'process_high'

    container 'jinlab/glnexus:v1.4.1'

    // Publish indexed files to the specified directory
    publishDir("$params.outdir/DEEPVARIANT/COMBINED_VCF", mode: "copy")

    input:
    tuple val(sample_id), path(gvcfs)

    output:
    tuple val("cohort"), path("cohort_joint.vcf.gz"), path("cohort_joint.vcf.gz.tbi"), emit: jointCalls
    path("cohort.bcf")

    script:
    """
    for gvcf in ${gvcfs}; do
        bcftools index -t \$gvcf
    done

    # Index the VCF file
    glnexus_cli --config DeepVariant ${gvcfs} > cohort.bcf
    bcftools view cohort.bcf | bgzip -@ ${task.cpus} -c > cohort_joint.vcf.gz
    tabix -p vcf cohort_joint.vcf.gz

    echo "Variant Calling Complete"
    """
}