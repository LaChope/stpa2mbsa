#!/bin/bash

WORKSPACE=/opt/java-libs/brat-annotator
BRAT_DATA_HOME=/brat-data
ANNOTATIONS_DIR=$BRAT_DATA_HOME

cd $ANNOTATIONS_DIR
GATE_TOOLS=$WORKSPACE/gate-tools.sh

ls -1 */*/*.txt | while read TEXT_FILE; do

        ANN_FILE=${TEXT_FILE:0:-4}.ann

        if [ ! -s $ANN_FILE ]; then
                echo INFO: Skipping file $TEXT_FILE as there were no annotations found in $ANN_FILE.
                continue;
        fi

        echo INFO: Processing $TEXT_FILE ...
        $GATE_TOOLS brat2gate --input-text-file $TEXT_FILE --brat-server-url https://kbss.felk.cvut.cz/19msmt-demo/annotator --brat-data-home-directory $BRAT_DATA_HOME
done
 
# give rights for brat web tool
chmod -R 777 /brat-data/AIDA
