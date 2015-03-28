#!/bin/bash

CRYPTSH_safe_dev="/dev/mmcblk0p2"
CRYPTSH_vault_dev="/dev/sdb1"
CRYPTSH_vault_key="/mnt/safe/keys/crypt/zero"
CRYPTSH_open_status="\e[1;36m open \e[0m"
CRYPTSH_closed_status="\e[1;31mclosed\e[0m"

unlock-safe(){
	echo -e "Unlocking Safe..."
	sudo cryptsetup open $CRYPTSH_safe_dev safe &&
	sudo mount /mnt/safe &&
	echo -e "Safe unlocked" ||
	echo -e "Failed to unlock Safe"
}

unlock-vault(){
	[[ -e /dev/mapper/safe ]] || unlock-safe
	echo -e "Unlocking Vault..."
	sudo cryptsetup open \
		--key-file $CRYPTSH_vault_key \
		$CRYPTSH_vault_dev vault &&
	sudo mount /mnt/vault &&
	echo -e "Vault unlocked" ||
	echo -e "Failed to unlock Vault"
}

lock-safe(){
	echo -e "Locking Safe..."
	[[ -e /dev/mapper/vault ]] && lock-vault
	sudo umount /mnt/safe &&
	sudo cryptsetup close safe &&
	echo -e "Safe locked" ||
	echo -e "Failed to lock Safe"
}

lock-vault(){
	echo -e "Locking Vault..."
	sudo umount /mnt/vault &&
	sudo cryptsetup close vault &&
	echo -e "Vault locked" ||
	echo -e "Failed to lock Vault"
}

status-crypt(){
	[[ -e /dev/mapper/safe ]] &&
		safe_status=$CRYPTSH_open_status ||
		safe_status=$CRYPTSH_closed_status
	[[ -e /dev/mapper/vault ]] &&
		vault_status=$CRYPTSH_open_status ||
		vault_status=$CRYPTSH_closed_status
	echo -e "\e[1m  safe :: $safe_status"
	echo -e "\e[1m vault :: $vault_status"
}

status-safe(){
	[[ -e /dev/mapper/safe ]] &&
		safe_status=$CRYPTSH_open_status ||
		safe_status=$CRYPTSH_closed_status
	echo -e "\e[1m  safe :: $safe_status"
}

status-vault(){
	[[ -e /dev/mapper/vault ]] &&
		vault_status=$CRYPTSH_open_status ||
		vault_status=$CRYPTSH_closed_status
	echo -e "\e[1m vault :: $vault_status"
}

setup-safe(){
	echo -e "Creating Safe..."
	sudo cryptsetup -v \
		-c serpent-xts-plain64 \
		-s 512 \
		-h whirlpool \
		-i 5000 \
		--use-random \
		luksFormat $CRYPTSH_safe_dev  &&
	echo -e "Vault created" ||
	echo -e "Failed to create Vault"
}

setup-vault(){
	echo -e "Creating Vault..."
	sudo cryptsetup -v \
		-c serpent-xts-plain64 \
		-s 512 \
		-h whirlpool \
		-i 5000 \
		--use-random \
		luksFormat $CRYPTSH_vault_dev \
		$CRYPTSH_vault_key  &&
	echo -e "Vault created" ||
	echo -e "Failed to create Vault"
}
