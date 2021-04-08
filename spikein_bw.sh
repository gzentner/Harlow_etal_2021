#!/bin/bash

# This script requires that Samtools and deepTools be in your path.

for i in *sorted.bam
do 
    # Calculate spike-in normalization factor
    NREADS=$(samtools idxstats $i | grep "ERCC" | awk '{s+=$3} END {print s}') # Count number of reads mapping to ERCC transcripts
    SCALE_NUMERATOR=100000 
    SPIKE=$( echo "scale=5 ; $SCALE_NUMERATOR / $NREADS" | bc )

    echo $i
    echo "Reads mapped to ERCC spike-ins = $NREADS"
    echo "Scale factor = $SPIKE"
    
    # Generate bigWigs
    ## Note that the below strand filtering is for negatively-stranded libraries (e.g., dUTP RNA-seq, 3' QuantSeq REV). For 
    ## forward-stranded libraries (e.g., Lexogen CORALL), the reverse strand should filtered to generate a the forward strand 
    ## coverage and vice versa. For generating single-end converage tracks, -e 200 should be specific. As written, this will 
    ## only work for paired-end data (by default -e extends paired-end reads to the length of the fragment from which they 
    ## were derived).


    ## Forward
    bamCoverage -b $i -of bigwig --filterRNAstrand forward -bs 25 --scaleFactor $SPIKE -p 8 -e -o ${i/.bam/.forward.bw}

    ## Reverse 
    bamCoverage -b $i -of bigwig --filterRNAstrand reverse -bs 25 --scaleFactor $SPIKE -p 8 -e -o ${i/.bam/.reverse.bw}
done
