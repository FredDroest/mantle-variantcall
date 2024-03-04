READS=$1
REFERENCE=$2
NAME=$3
OUTDIR=$4"/"
THREADS=$5


READSNAME=$(basename $READS)
REFSNAME=$(basename $REFERENCE)
READSDEST=$OUTDIR"/"$READSNAME
REFDEST=$OUTDIR"/"$REFSNAME
cp $READS $READSDEST
cp $REFERENCE $REFDEST

NAME=$OUTDIR""$NAME
echo "STEP 1"
# Create bowtie2 database
# bowtie2-build $REFDEST REF_DB

echo "STEP 2"
# bowtie2 mapping
# bowtie2 -p $THREADS -x REF_DB -U $READSDEST --no-unal -S $NAME.sam

# samtools:  sort .sam file and convert to .bam file

echo "STEP 3"
minimap2 -ax map-ont $REFDEST $READSDEST --secondary=no > $NAME.sam
samtools view -bS $NAME.sam | samtools sort > $NAME.bam
samtools index $NAME.bam 

# rm -rf $OUTDIR"/"$NAME.sam

refmap=$(samtools view -c -F 4 $NAME.bam)
notmap=$(samtools view -c -f 4 $NAME.bam)
count=$(bc <<<"$refmap+$notmap")
percentmap=$( echo "scale=2; $refmap/$count*100" | bc )

echo "# of reads mapped to reference: $refmap"
echo "# of reads NOT mapped to reference: $notmap"
echo "% of reads mapped: $percentmap"
echo "STEP 4"

samtools view -bS -f 4 $NAME"_unmap.bam"
samtools view -bS -F 4 $NAME"_map.bam"

# Get consensus fastq file
bcftools mpileup -f $REFDEST $NAME.bam | bcftools call -c | vcfutils.pl vcf2fq > $NAME"_consensus.fastq"
bcftools mpileup -f $REFDEST $NAME.bam | bcftools call -m -Ov -o $NAME.vcf

 # vcfutils.pl is part of bcftools
find . -name "*.bt2" -type f -delete

echo "STEP 5"
# Convert .fastq to .fasta and set bases of quality lower than 20 to N
seqtk seq -aQ64 -q20 -n N $NAME"_consensus.fastq" > $NAME"_consensus.fasta"
