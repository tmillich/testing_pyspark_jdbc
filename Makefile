.EXPORT_ALL_VARIABLES:

# Define ROOT_DIR and other variables
ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

JAVA_HOME := ${ROOT_DIR}/lib/jdk
SPARK_HOME := ${ROOT_DIR}/lib/spark
SPARK_SUBMIT := ${SPARK_HOME}/bin/spark-submit

SPARK_CONF_DIR := ${SPARK_HOME}/conf
SPARK_LOG_DIR := ${ROOT_DIR}/temp/log
SPARK_LOG_DIR_DAEMON := ${ROOT_DIR}/temp/log/daemon
SPARK_PID_DIR := ${ROOT_DIR}/temp/pid
SPARK_DEFAULT_CONF_TEMPLATE := ${ROOT_DIR}/conf/spark-default.conf
SPARK_CONF_DEST_FILE := ${SPARK_CONF_DIR}/spark-default.conf

# Log4j2 configuration files
SPARK_LOG4J_PROPERTIES_TEMPLATE := ${ROOT_DIR}/conf/log4j2.properties
SPARK_LOG4J_PROPERTIES := ${SPARK_CONF_DIR}/log4j2.properties

MASTER_HOST := localhost
MASTER_PORT := 7077
WORKER_PORT := 8081  # Default port for Spark worker's web UI

# Define Spark master URL
SPARK_MASTER_URL := spark://$(MASTER_HOST):$(MASTER_PORT)

# Define regex suffix for PID files
SPARK_MASTER_REGEX_SUFFIX := '*-org.apache.spark.deploy.master.Master-1.pid'
SPARK_WORKER_REGEX_SUFFIX := '*-org.apache.spark.deploy.worker.Worker-1.pid'

# Define worker configuration parameters
SPARK_WORKER_CORES := 4
SPARK_WORKER_MEMORY := 2g
SPARK_WORKER_WEBUI_PORT := 8081
SPARK_WORKER_DIR := ${ROOT_DIR}/temp/spark-worker

# Use /bin/bash for the shell
SHELL := /bin/bash

# ----------------------
# --- Ensure Files ---
# ----------------------

# Ensure the PID directory exists
ensure_pid_dir:
	@echo "Ensuring PID directory exists..."; \
	mkdir -p $(SPARK_PID_DIR)

# Ensure the configuration and log4j properties files are correctly set up
ensure_log4j_properties: ensure_pid_dir
	@echo "Generating Spark configuration and log4j properties files..."; \
	cat $(SPARK_DEFAULT_CONF_TEMPLATE) | envsubst > $(SPARK_CONF_DEST_FILE); \
	cat $(SPARK_LOG4J_PROPERTIES_TEMPLATE) | envsubst > $(SPARK_LOG4J_PROPERTIES); \
	echo "Configuration files generated."

# ---------------------
# --- Spark Daemons ---
# ---------------------

# Rule to start the Spark master server
start_master_server: ensure_log4j_properties
	@echo "Checking if Spark master server is running..."; \
	process_status=$$( \
        $(call CHECK_PROCESS_RUNNING, $(SPARK_PID_DIR), $(SPARK_MASTER_REGEX_SUFFIX)) \
    ); \
	echo "Master server is running: $$process_status"; \
	if [ "$$process_status" = "false" ]; then \
		echo "Spark master server is not running. Starting the master server..."; \
		export LOG_PREFIX=master && \
		${SPARK_HOME}/sbin/start-master.sh \
            --properties-file $(SPARK_CONF_DEST_FILE) \
            -h ${MASTER_HOST} -p ${MASTER_PORT} --webui-port 8080; \
	else \
		echo "Spark master server is already running."; \
	fi

# Rule to stop the Spark master server
stop_master_server:
	@echo "Stopping Spark master server..."; \
	${SPARK_HOME}/sbin/stop-master.sh

# Rule to start the Spark worker server
start_worker_server: ensure_log4j_properties
	@echo "Checking if Spark worker server is running..."; \
	process_status=$$( \
        $(call CHECK_PROCESS_RUNNING, $(SPARK_PID_DIR), $(SPARK_WORKER_REGEX_SUFFIX)) \
    ); \
	echo "Worker server is running: $$process_status"; \
	if [ "$$process_status" = "false" ]; then \
		echo "Spark worker server is not running. Starting the worker server..."; \
		export LOG_PREFIX=worker && \
		${SPARK_HOME}/sbin/start-worker.sh \
            --properties-file $(SPARK_CONF_DEST_FILE) \
            --cores $(SPARK_WORKER_CORES) \
            --memory $(SPARK_WORKER_MEMORY) \
            --webui-port $(SPARK_WORKER_WEBUI_PORT) \
            --work-dir $(SPARK_WORKER_DIR) \
            $(SPARK_MASTER_URL); \
	else \
		echo "Spark worker server is already running."; \
	fi

# Rule to stop the Spark worker server
stop_worker_server:
	@echo "Stopping Spark worker server..."; \
	${SPARK_HOME}/sbin/stop-worker.sh

# ---------------------
# --- Start All Daemons ---
# ---------------------

start_daemons: start_master_server start_worker_server
	@echo "All Spark daemons have been started."

# ---------------------
# --- Stop All Daemons ---
# ---------------------

stop_daemons: stop_master_server stop_worker_server
	@echo "All Spark daemons have been stopped."

# -----------------------
# --- Helper Function ---
# -----------------------

# Define a function to check if a process is running
define CHECK_PROCESS_RUNNING
    file_path=$$(find $(1) -type f -name $(2) -print -quit); \
    if [ -n "$$file_path" ]; then \
        pid=$$(cat $$file_path 2>/dev/null); \
        if [ -n "$$pid" ] && ps -p $$pid > /dev/null 2>&1; then \
            echo "true"; \
        else \
            rm -f $$file_path; \
            echo "false"; \
        fi; \
    else \
        echo "false"; \
    fi
endef

# Rule to stop the Spark master server and kill the process if running
stop_example_server:
	@echo "Stopping example server..."; \
	$(call KILL_PROCESS_IF_RUNNING, $(SPARK_PID_DIR), $(SPARK_MASTER_REGEX_SUFFIX)); \

# Define a function to check if a process is running and kill it if it is
define KILL_PROCESS_IF_RUNNING
    file_path=$$(find $(1) -type f -name $(2) -print -quit); \
    if [ -n "$$file_path" ]; then \
        pid=$$(cat $$file_path 2>/dev/null); \
        if [ -n "$$pid" ] && ps -p $$pid > /dev/null 2>&1; then \
            echo "Process $$pid is running. Killing it..."; \
            kill -TERM $$pid; \
            rm -f $$file_path; \
        else \
            echo "No running process found for PID $$pid. Removing stale PID file."; \
            rm -f $$file_path; \
        fi; \
    else \
        echo "No PID file found. No process to kill."; \
    fi
endef