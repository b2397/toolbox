#!/bin/bash

# Define the search directory and the date param
directory="/my/directory"
today=$(date +"%Y%m%d")  # Example: 20241007
today="20241009" # Override if needed to a particular day
echo "-----------------------------------------------------------------------"

declare -A table_files

# Loop through the log files in the directory
for file in "$directory"/*"$today"*.log; do
  file_basename=$(basename "$file")
  echo "Start new file search:" "$file_basename"
  # Check if the log file contains the word 'ERROR'
  if grep -q '\bERROR\b' "$file"; then
    echo "Found the string ERROR in " "$file_basename"
    
    # Extract the table name: from the second underscore to the first numeric character
    # table_name=$(basename "$file" | sed -E 's/^[^_]+_[^_]+_([^0-9_]+).*/\1/')
    # table_name=$(basename "$file" | sed -E 's/^[^_]+_[^_]+_([^_]+)_[0-9]+.*/\1/')
    # table_name=$(basename "$file" | sed -E 's/^[^_]+_[^_]+_([^_]+)_[0-9]+.*/\1/')
    # table_name=$(basename "$file" | sed -E 's/^[^_]+_[^_]+_([^_]+)_[0-9]+.*$/\1/')

    # Extract everything after the second underscore
    part1=$(basename "$file" | sed -E 's/^[^_]+_[^_]+_//')
    
    # Extract everything before the first number in this new string, then remove the final trailing underscore
    table_name=$(echo "$part1" | sed -E 's/[0-9].*$//'| sed -E 's/_$//')
    
    # Compare and store the latest file for each table based on timestamp
    if [[ -z "${table_files[$table_name]}" || "$file" -nt "${table_files[$table_name]}" ]]; then
        echo "Newest log file found. table_files[$table_name]=" "$file_basename"
        table_files[$table_name]="$file"
    else
        echo "$file_basename" "is older than " "${table_files[$table_name]}"
    fi
  fi
  echo "End file search"
  echo "-----------------------------------------------------------------------"
done

# Now process the latest files for each table
for file in "${table_files[@]}"; do
    echo "file in final for:" "$file"
    
    # Extract everything after the second underscore
    part1=$(basename "$file" | sed -E 's/^[^_]+_[^_]+_//')

    # Extract everything before the first number in this new string, then remove the final trailing underscore
    table_name=$(echo "$part1" | sed -E 's/[0-9].*$//'| sed -E 's/_$//')
  
    # Check if the latest file contains the word 'ERROR'
    if grep -q '\bERROR\b' "$file"; then
        # Print the table name since the latest file is clean
        echo "TABLE FOUND:" "$table_name"
    else
        echo "No matching text found"
    fi
done
