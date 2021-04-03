#!/bin/bash

file="./syslog.log"
regex='.+: (INFO|ERROR) (.+) \((.+)\)'
declare -A errors
declare -A userErrors
declare -A userInfo

while read -r line
do
	[[ $line =~ $regex ]]

	if [[ ${BASH_REMATCH[1]} == "ERROR" ]]
	then
		((errors['${BASH_REMATCH[2]}']++))
		((userErrors['${BASH_REMATCH[3]}']++))
	else
		((userInfo['${BASH_REMATCH[3]}']++))
	fi
done < "$file"

echo "Error,Count" > error_message.csv
for key in "${!errors[@]}"
do
	printf "%s,%d\n" "$key" "${errors[$key]}" 
done | sort -rn -t , -k 2 >> error_message.csv

echo "Username,INFO,ERROR" > user_statistic.csv
for key in "${!userErrors[@]}" "${!userInfo[@]}"
do
	printf "%s,%d,%d\n" "$key" "${userInfo[$key]}" "${userErrors[$key]}" 
done | sort -u >> user_statistic.csv
