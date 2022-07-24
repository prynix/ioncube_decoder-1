#!/bin/sh

MKDIR="mkdir -p"

ENCODED_FOLDER=ENCODED
DECODED_FOLDER=DECODED
DELETE_RAR=DECODED.rar
LOG_FILE=Log_Decoded.txt
PHP_COMMAND="php\php-cgi.exe -c php\php.ini"
NUMBER_DECODED_FILES=0

if [ -d "${DECODED_FOLDER}" ]; then
	rm -rf ${DECODED_FOLDER}
	rm -rf ${DELETE_RAR}
fi

${MKDIR} "${DECODED_FOLDER}"

if [ -d "${ENCODED_FOLDER}" ] && [ -d "${DECODED_FOLDER}" ]; then
	echo -e "### Log Files - Decoded ### \n" > "${DECODED_FOLDER}/${LOG_FILE}"

	find "${ENCODED_FOLDER}" | while read FILE; do {
		IS_DECODED=0
		FILENAME=`echo ${FILE} | awk -F '/' '{print $NF}'`
		DESTINATION=`echo ${FILE} | sed -e "s/^${ENCODED_FOLDER}/${DECODED_FOLDER}/;"`
		DESTINATION_FOLDER=`dirname "${DESTINATION}"`

		if [ ! -d "${DESTINATION_FOLDER}" ]; then
			${MKDIR} "${DESTINATION_FOLDER}"
		fi

		if [ -f "${FILE}" ]; then
			FILENAME_EXTENSION=`echo ${FILE} | awk -F '.' '{print $NF}'`

				IS_COMPILED=`cat "${FILE}" | grep "requires the ionCube PHP Loader\|extensionn_loaded('ionnCube Loader'))\|function_exists('_il_exec'))\|<?php @Zend;\|^Zend\|!extension_loaded('Php Express')\|is_callable(\"eaccelerator_load\")\|sg_load\|phpshield_load"`

				if [ "${IS_COMPILED}" ]; then
					echo -e "# Command ./${PHP_COMMAND} \"${FILE}\" > \"${DESTINATION}\""
					./${PHP_COMMAND} "${FILE}" > "${DESTINATION}"
					echo -e "${DESTINATION}" >> "${DECODED_FOLDER}/${LOG_FILE}"
					IS_DECODED=1
					NUMBER_DECODED_FILES=$((${NUMBER_DECODED_FILES} + 1))
				fi
		fi

		if [ -f "${FILE}" ] && [ "${IS_DECODED}" = "0" ]; then
			cp -f "${FILE}" "${DESTINATION}"
		fi
	}
	done

	echo -e "\n" >> "${DECODED_FOLDER}/${LOG_FILE}"
	echo -e " Number Of Decoded Files = \"${NUMBER_DECODED_FILES}\"" >> "${DECODED_FOLDER}/${LOG_FILE}"
fi

exit 0;