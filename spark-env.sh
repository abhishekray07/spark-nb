#!/usr/bin/env bash

# This file is sourced when running various Spark programs.
export SPARK_DIST_CLASSPATH=$(/opt/hadoop/bin/hadoop classpath)
export LD_LIBRARY_PATH=/opt/hadoop/lib/native/:$LD_LIBRARY_PATH
export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
