#!/bin/bash 
echo "*****************************************************"
echo "this is post build!! current configure is :$1"

if [[ $2 = tc32 ]]; then
	script_dir="$(cd "$(dirname "$0")" && pwd)"
elif [[ $2 = riscv ]]; then
	script_dir=$(dirname $(realpath "$0"))
elif [[ $2 = iot_riscv ]]; then
	script_dir=$(dirname $(realpath "$0"))
fi

if [[ "$OSTYPE" = "linux-gnu"* ]]; then
    echo "Current system is Linux"
	tool=${script_dir}/tl_check_fw2.out
elif [[ "$OSTYPE" = "darwin"* ]]; then
    echo "Current system is macOS"
	echo "Not support"
	exit
elif [[ "$OSTYPE" = "msys"* || "$OSTYPE" == "cygwin"* ]]; then
    echo "Current system is Windows"
	tool=${script_dir}/tl_check_fw2.exe
else
    echo "Unknown operating system: $OSTYPE"
	exit
fi

if [[ $2 = tc32 ]]; then
	tc32-elf-objcopy -v -O binary $1.elf $1.bin
	${tool} $1.bin
elif [[ $2 = riscv ]]; then
	riscv32-elf-objcopy -S -O binary $1.elf output/$1.bin
	${tool} output/$1.bin
elif [[ $2 = iot_riscv ]]; then
	riscv32-elf-objcopy -S -O binary $1.elf $1.bin
	${tool} $1.bin
fi

# set -e

# PROJECT_DIR="build"
# SREC_CAT_TOOL="${script_dir}/srecord/srec_cat.exe"
# BOOTLOADER_FILE="${script_dir}/../boot/bootLoader_8258.bin"
# APP_BINARY_FILE="${script_dir}/../$PROJECT_DIR/SNZB03P.bin"
# APP_OFFSET="0x9000"
# OUTPUT_FILE="${script_dir}/../$PROJECT_DIR/FWSN_SNZB03P.bin"

# if [ ! -f "$SREC_CAT_TOOL" ]; then
#     echo "[ERROR] srec_cat not found: '$SREC_CAT_TOOL'"
#     exit 1
# fi
# if [ ! -f "$BOOTLOADER_FILE" ]; then
#     echo "[ERROR] Bootloader not found: '$BOOTLOADER_FILE'"
#     exit 1
# fi
# if [ ! -f "$APP_BINARY_FILE" ]; then
#     echo "[ERROR] Application binary not found: '$APP_BINARY_FILE'. Compilation may have failed."
#     exit 1
# fi

# echo "[INFO] Merging binary files..."
# "$SREC_CAT_TOOL" \
#     "$BOOTLOADER_FILE" -binary \
#     "$APP_BINARY_FILE" -binary -offset "$APP_OFFSET" \
#     -o "$OUTPUT_FILE" -binary

# echo "[INFO] Merging complete. Output file: '$OUTPUT_FILE'"

# echo "[INFO] $(date)"

echo "**************** end of post build ******************"
