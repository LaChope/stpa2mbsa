#!/bin/bash
#
# Usage: ./auto-annotate-scenarios.sh <scenarios.json>

# --- Check arguments ---
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <combined_scenarios.json>"
  exit 1
fi

json_file="$1"

if [ ! -f "$json_file" ]; then
  echo "JSON file '$json_file' not found!"
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo "This script requires jq but it was not found. Please install jq."
  exit 1
fi

# --- Helper function: compute offset (0-indexed) using grep ---
get_offset() {
  local needle="$1"
  local offset
  offset=$(grep -b -oF "$needle" <<< "$final_text" | head -n1 | cut -d: -f1)
  if [ -z "$offset" ]; then
    echo -1
  else
    echo "$offset"
  fi
}

# --- Process each scenario ---
keys=$(jq -r 'keys[]' "$json_file")
for key in $keys; do
  scenarioText=$(jq -r --arg key "$key" '.[$key].scenarioText' "$json_file")
  controller=$(jq -r --arg key "$key" '.[$key].metadata.controller' "$json_file")
  controlAction=$(jq -r --arg key "$key" '.[$key].metadata.controlAction' "$json_file")
  controlledProcess=$(jq -r --arg key "$key" '.[$key].metadata.controlledProcess' "$json_file")
  context_val=$(jq -r --arg key "$key" '.[$key].metadata.context' "$json_file")
  scenarioTextOneLine=$(echo "$scenarioText" | tr '\n' ' ' | sed 's/  */ /g' | sed 's/^[ \t]*//; s/[ \t]*$//')
  final_text="${key}: ${scenarioTextOneLine}"
  if [[ "$final_text" != *"$controlledProcess"* ]]; then
    final_text="${final_text} ${controlledProcess}"
  fi
  if [[ "$final_text" != *"$context_val"* ]]; then
    final_text="${final_text} - ${context_val}"
  fi

  T1="$key"
  T2="$controller"
  T3="$controlAction"
  T4="$controlledProcess"
  T5="$context_val"

  offset_T1=$(get_offset "$T1")
  offset_T2=$(get_offset "$T2")
  offset_T3=$(get_offset "$T3")
  offset_T4=$(get_offset "$T4")
  offset_T5=$(get_offset "$T5")

  if [ "$offset_T1" -lt 0 ] || [ "$offset_T2" -lt 0 ] || [ "$offset_T3" -lt 0 ] || [ "$offset_T4" -lt 0 ] || [ "$offset_T5" -lt 0 ]; then
    echo "Error: One or more offsets could not be found for scenario $key."
    echo "Offsets: T1=$offset_T1, T2=$offset_T2, T3=$offset_T3, T4=$offset_T4, T5=$offset_T5"
    echo "Final text: $final_text"
    continue
  fi

  len_T1=${#T1}
  len_T2=${#T2}
  len_T3=${#T3}
  len_T4=${#T4}
  len_T5=${#T5}

  txt_file="${key}.txt"
  ann_file="${key}.ann"

  echo "$final_text" > "$txt_file"

  # Write the annotation file in BRAT format.
  {
    echo "T1	stpa_LossScenario $offset_T1 $((offset_T1 + len_T1))	$T1"
    echo "T2	stpa_Controller $offset_T2 $((offset_T2 + len_T2))	$T2"
    echo "T3	stpa_ControlAction $offset_T3 $((offset_T3 + len_T3))	$T3"
    echo "T4	stpa_ControlledProcess $offset_T4 $((offset_T4 + len_T4))	$T4"
    echo "T5	stpa_Context $offset_T5 $((offset_T5 + len_T5))	$T5"
  } > "$ann_file"

  echo "Generated files for scenario $key:"
  echo "  Text: $txt_file"
  echo "  Annotations: $ann_file"
done

echo "All scenarios processed."
