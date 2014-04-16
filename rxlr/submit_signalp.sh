#!/bin/bash


FILE_NAME=$1
PATH_TO_SP=$2
$2/signalp -t euk -f summary -trunc 70 $FILE_NAME > $FILE_NAME."out"
