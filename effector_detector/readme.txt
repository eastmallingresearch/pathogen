The organise_effector.sh file is not yet a shell script. It simply contains commands required
to parse the effector list and return it in a fasta list format. Each name is a concatonation
of the effector family, the effector, the strain/pv and if available some isolate number/name
eg: >avrE1_Psy_B64

The perl script-blast effectors currently uses a hardcoded database -lazy
and a list of input effectors, made by running the awk commands in the not yet a shell script
file. 

This is run like so:

/home/harrir/git_master/pathogen/effector_detector/blast_effectors.pl  /home/harrir/git_master/pathogen/effector_detector/hop.fasta 

It will currently do a blast on some silly critera and return some text to screen about the hits



