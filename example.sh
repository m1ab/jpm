#!/bin/bash

###############################################################################
# Testing JPM (Java Project with Maven)
#
# make sure you jpm folder is ~/src/jpm
# otherwise fix the src_dir in jpm.sh and this example.sh
#
src_dir=~/src/
cd ${src_dir}/jpm/
./jpm.sh ru.mkry.hello hello && \
        cd ${src_dir}/hello/ && \
        mvn clean install -Ptotal && \
        cd -
