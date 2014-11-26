#!/bin/bash

CRYPTSH_safe_dev="/dev/mmcblk0p2"
CRYPTSH_vault_dev="/dev/sda"
CRYPTSH_vault_key="/mnt/safe/keys/crypt/zero"
CRYPTSH_open_status="\e[1;36m open \e[0m"
CRYPTSH_closed_status="\e[1;31mclosed\e[0m"

unlock-safe(){
	sudo cryptsetup open /dev/mmcblk0p2 safe &&
	sudo mount /mnt/safe
}

unlock-vault(){
	[[ -e /dev/mapper/safe ]] || unlock-safe &&
	sudo cryptsetup open \
		--key-file CRYPTSH_vault_key \
		CRYPTSH_vault_dev vault &&
	sudo mount /mnt/vault
}

lock-safe(){
	[[ -e /dev/mapper/vault ]] && lock-vault &&
	sudo umount /mnt/safe &&
	sudo cryptsetup close safe
}

lock-vault(){
	sudo umount /mnt/vault &&
	sudo cryptsetup close vault
}

status-crypt(){
	[[ -e /dev/mapper/safe ]] &&
		safe_status=$CRYPTSH_open_status ||
		safe_status=$CRYPTSH_closed_status
	[[ -e /dev/mapper/vault ]] &&
		vault_status=$CRYPTSH_open_status ||
		vault_status=$CRYPTSH_closed_status
	echo -en "\e[1m  safe :: $safe_status\n"
	echo -en "\e[1m vault :: $vault_status\n"
}

status-safe(){
	[[ -e /dev/mapper/safe ]] &&
		safe_status=$CRYPTSH_open_status ||
		safe_status=$CRYPTSH_closed_status
	echo -en "\e[1m  safe :: $safe_status\n"
}

status-vault(){
	[[ -e /dev/mapper/vault ]] &&
		vault_status=$CRYPTSH_open_status ||
		vault_status=$CRYPTSH_closed_status
	echo -en "\e[1m vault :: $vault_status\n"
}

setup-safe(){
	sudo cryptsetup -v \
		-c serpent-xts-plain64 \
		-s 512 \
		-h whirlpool \
		-i 5000 \
		--use-random \
		luksFormat $CRYPTSH_safe_dev \
		#--debug
}

setup-vault(){
	sudo cryptsetup -v \
		-c serpent-xts-plain64 \
		-s 512 \
		-h whirlpool \
		-i 5000 \
		--use-random \
		luksFormat $CRYPTSH_vault_dev \
		$CRYPTSH_vault_key \
		#--debug
}
