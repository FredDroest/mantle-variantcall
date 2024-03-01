params.READS = file(params.reads)
params.REFERENCE = file(params.reference)
params.NAME = params.name ?: "default_name" // Use default name if not provided
params.OUTDIR = file(params.outdir ?: "./output")

// Add echo statements to debug
println "Executing map2genome.sh with the following parameters:"
println "READS: ${params.READS}"
println "REFERENCE: ${params.REFERENCE}"
println "NAME: ${params.NAME}"
println "OUTDIR: ${params.OUTDIR}"

// Define a process to run the map2genome.sh script
process map2genome {
	conda 'bioconda::samtools bioconda::bcftools bioconda::bowtie2'
//    secret 'MANTLE_USER'
//    secret 'MANTLE_PASSWORD'
    
    // Specify the input files for the process
    input:
//    val pipelineId
    file READS
    file REFERENCE

    // Specify the output files for the process
    output:
//    file '*.mapped.bam' into mapped_bams
//    file 'log.txt' into log_files

    // Specify the command to run your map2genome.sh script
    script:
    """
    echo "Executing map2genome.sh with inputs: ${READS}, ${REFERENCE}, ${params.NAME}, ${params.OUTDIR}"
    bash map_reads2genome.sh ${READS} ${REFERENCE} ${params.NAME} ${params.OUTDIR}
    """
}

// Run the map2genome process with the provided inputs
workflow {
    map2genome(params.READS, params.REFERENCE)
}

