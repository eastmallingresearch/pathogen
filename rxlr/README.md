This is a pipeline for identifying RxLR's in n-gen genomes. 
At present this is partially optimised for grid engine, with the signal p portions of the pipeline
being sent out to grid engine. The problem still remaining is how to resume a script after the grid engine
jobs are done. 

Furthermore, there are probably other tweaks that need to be carried out in order to streamline the 
pipeline. 

TO RUN THIS PIPELINE YOU NEED TO 

1. Have your input file which is the sorted_contigs.fa file from your assembly (or equivalent)
2. run the rxlr_pipeline_part1.sh file in the github scripts/rxlr repo (current location)
3. When the cluster job has completed, run the rxlr_pipeline_part2.sh which will then process the signalp output and find rxlr's

~/git_stuff/scripts/rxlr/rxlr_pipeline_part1.sh sorted_contigs.fa ~/signalp-2.0/



