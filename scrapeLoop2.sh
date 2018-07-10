#!/bin/bash
aws s3 ls s3://jbchess/data --recursive > temp.txt

for n in $(seq 0 499)
do
	first=$(($n*1000+1))
	last=$(($n*1000+1000))
	Rscript scrapeLoop2.R $first,$last
	aws s3 mv data s3://jbchess/data --recursive
#	date
done

