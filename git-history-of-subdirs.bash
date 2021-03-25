#!/usr/bin/bash

usage()  
{  
echo "Usage: $0 [-p path-to-directory] [-d number-of-days] [-e to export details to a file]" 
exit 1  
} 

while getopts ":p:d:e" o; do
    case "${o}" in
        p)
            path_to_scan=${OPTARG}
            ;;
        d)
            number_of_days=${OPTARG}
            ;;
        e)
            export_to_file=true    
            starting_dir=$PWD
            echo -n "" > "$starting_dir/export.txt"
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

#path is a required input
if [ -z "${path_to_scan}" ]; then
    usage
else
    cd "$path_to_scan" || exit
fi

#if -d wasn't specified, default to 90
if [ "$number_of_days" == "" ]; then
    number_of_days="90 days ago"
else
    number_of_days=$number_of_days" days ago"
fi

for current_dir in $(find . -maxdepth 1 -type d); do (
    # skip the current directory - only want stats for subdirectories
    if [ "$current_dir" != "." ]
    then
        # Always spit out the basic stats to stdout
        number_of_git_changes_in_subdir=$(git log --no-merges --after="${number_of_days} days ago" --pretty="${current_dir},%H,%cs,%cl,%cs,%s" -- "$current_dir" | wc -l)
        (echo "git log entries for $current_dir: $number_of_git_changes_in_subdir") | tr -d "\n" 
        echo "" 

        # only export the results to a file if -s for simple view is not specified
        if [ "$export_to_file" ]
        then
            (git log --no-merges --after="${number_of_days} days ago" --pretty="${current_dir},%H,%cs,%cl,%cs,%s" -- "$current_dir") >> "$starting_dir"/export.txt
        fi
    fi
); done

