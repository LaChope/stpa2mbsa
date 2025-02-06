#!/bin/bash

WORKSPACE=annotator/config/
BRAT_DATA_HOME=brat-data/AIDA
ANNOTATIONS_DIR=$BRAT_DATA_HOME

if [ ! -d "$ANNOTATIONS_DIR" ]; then
    echo "ERROR: Directory $ANNOTATIONS_DIR does not exist."
    exit 1
fi

GATE_TOOLS="./$WORKSPACE/gate-tools.sh"

if [ ! -x "$GATE_TOOLS" ]; then
    echo "ERROR: GATE_TOOLS script ($GATE_TOOLS) does not exist or is not executable."
    exit 1
fi

for TEXT_FILE in "$ANNOTATIONS_DIR"/*.txt; do
    ANN_FILE="${TEXT_FILE%.txt}.ann"

    if [ ! -s "$ANN_FILE" ]; then
        echo "INFO: Skipping file $TEXT_FILE as there were no annotations found in $ANN_FILE."
        continue
    fi

        echo INFO: Processing $TEXT_FILE ...
        $GATE_TOOLS brat2gate --input-text-file $TEXT_FILE --brat-server-url https://kbss.felk.cvut.cz/19msmt-demo/annotator --brat-data-home-directory $BRAT_DATA_HOME
done

chmod -R 777 "$BRAT_DATA_HOME"
