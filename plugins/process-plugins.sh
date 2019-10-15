#!/bin/bash

function LOG_INFO {
    logger "INFO [PROCESS-PLUGINS] [$(date +"%Y%m%d%H%M%S")] - $1"
    echo "INFO [PROCESS-PLUGINS] [$(date +"%Y%m%d%H%M%S")] - $1"
}

function LOG_ERROR {
    logger "ERROR [PROCESS-PLUGINS] [$(date +"%Y%m%d%H%M%S")] - $1"
    echo "ERROR [PROCESS-PLUGINS] [$(date +"%Y%m%d%H%M%S")] - $1"
}

function CHECK_REQUIREMENTS {
    LOG_INFO "[CHECK_REQUIREMENTS] Check if requirements.txt exist."
    if [ -f "${CURRENT_PATH}/requirements.txt" ]; then
        LOG_INFO "[CHECK_REQUIREMENTS] requirements.txt exist."
    else
        LOG_ERROR "[CHECK_REQUIREMENTS] requirements.txt does not exist. Exiting..."
        exit 1
    fi
}

function MAIN()
{
    CHECK_REQUIREMENTS
    cd $PLUGINS_PATH
    LOG_INFO "[MAIN] Reading requeriments."
    while IFS= read -r LINE
    do
        [[ "${LINE}" =~ ^#.*$ ]] && continue
        PLUGIN_NAME=$(echo ${LINE} | cut -d'=' -f1)
        PLUGIN_VERSION=$(echo ${LINE} | cut -d'=' -f3)
        if [ "${PLUGIN_VERSION}" == '' ]; then
            PLUGIN_STRING=${PLUGIN_NAME}.zip
        else
            PLUGIN_STRING=${PLUGIN_NAME}.${PLUGIN_VERSION}.zip
        fi
        LOG_INFO "[MAIN] Downloading ${PLUGIN_STRING}."
        curl -O https://downloads.wordpress.org/plugin/${PLUGIN_STRING} > /dev/null 2>&1
        STATUS=$?
        if [ $STATUS -ne 0 ]; then
                LOG_ERROR "[MAIN] Downloading ${PLUGIN_STRING}."
        else
            LOG_INFO "[MAIN] Downloaded ${PLUGIN_STRING}."
            LOG_INFO "[MAIN] Unzipping ${PLUGIN_STRING}."
            unzip ${PLUGIN_STRING} > /dev/null 2>&1
            STATUS=$?
            if [ $STATUS -ne 0 ]; then
                LOG_ERROR "[MAIN] Unzipping ${PLUGIN_STRING}."
            else
                LOG_INFO "[MAIN] Unzipped ${PLUGIN_STRING}."
                LOG_INFO "[MAIN] Cleaning unnedded files from ${PLUGIN_STRING}."
                rm ${PLUGIN_STRING} > /dev/null 2>&1
                STATUS=$?
                if [ $STATUS -ne 0 ]; then
                    LOG_ERROR "[MAIN] Cleaning ${PLUGIN_STRING}."
                else
                    LOG_INFO "[MAIN] Plugin ${PLUGIN_STRING} cleaned."
                fi
            fi
        fi
    done < "${CURRENT_PATH}/requirements.txt"
    LOG_INFO "[MAIN] Process end."
}

PLUGINS_PATH="${1}"
CURRENT_PATH="$(pwd)"

MAIN