#!/bin/bash
OUTPUT=$(aws ecr describe-repositories --repository-names $1 2>&1);
echo "$OUTPUT";
if [ $? -ne 0 ]; then
    if echo $OUTPUT | grep -q RepositoryNotFoundException; then
        aws ecr create-repository --repository-name $1;
    else
        >&2 echo $OUTPUT;
    fi
fi