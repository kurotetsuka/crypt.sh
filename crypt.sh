#!/bin/bash

# variables
CRYPTSH_keyring_dev="/dev/disk/by-uuid/f1400986-d05b-46aa-b250-012c10f09b4a"
CRYPTSH_safe_dev="/dev/disk/by-uuid/ac7ca834-ca12-459c-8f04-d2243bdcad75"
CRYPTSH_vault_dev="/dev/disk/by-uuid/c07e2852-6da6-4b4d-b9ad-a8ca6fa97f0b"
CRYPTSH_vault_key="/mnt/keyring/keys/crypt/vault"
CRYPTSH_open_status="\e[1;36m open \e[0m"
CRYPTSH_closed_status="\e[1;31mclosed\e[0m"
# not in use
#CRYPTSH_safe_key="/mnt/safe/keys/crypt/safe"

unlock-keyring(){
	echo -e "Unlocking Keyring..."
	sudo cryptsetup open $CRYPTSH_keyring_dev keyring &&
	sudo mount /mnt/keyring &&
	echo -e "Keyring unlocked" ||
	echo -e "Failed to unlock Keyring"
}

unlock-safe(){
	echo -e "Unlocking Safe..."
	sudo cryptsetup open $CRYPTSH_safe_dev safe &&
	sudo mount /mnt/safe &&
	echo -e "Safe unlocked" ||
	echo -e "Failed to unlock Safe"
}

unlock-vault(){
	[[ -e /dev/mapper/keyring ]] || unlock-keyring
	echo -e "Unlocking Vault..."
	sudo cryptsetup open \
		--key-file $CRYPTSH_vault_key \
		$CRYPTSH_vault_dev vault &&
	sudo mount /mnt/vault &&
	echo -e "Vault unlocked" ||
	echo -e "Failed to unlock Vault"
}

lock-keyring(){
	echo -e "Locking Keyring..."
	killall gpg-agent &> /dev/null
	[[ -e /dev/mapper/vault ]] && lock-vault
	sudo umount /mnt/keyring &&
	sudo cryptsetup close keyring &&
	echo -e "Keyring locked" ||
	echo -e "Failed to lock Keyring"
}

lock-safe(){
	echo -e "Locking Safe..."
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
	[[ -e /dev/mapper/keyring ]] &&
		keyring_status=$CRYPTSH_open_status ||
		keyring_status=$CRYPTSH_closed_status
	[[ -e /dev/mapper/safe ]] &&
		safe_status=$CRYPTSH_open_status ||
		safe_status=$CRYPTSH_closed_status
	[[ -e /dev/mapper/vault ]] &&
		vault_status=$CRYPTSH_open_status ||
		vault_status=$CRYPTSH_closed_status
	echo -e "\e[1m keyring :: $keyring_status"
	echo -e "\e[1m   safe  :: $safe_status"
	echo -e "\e[1m  vault  :: $vault_status"
}

status-keyring(){
	[[ -e /dev/mapper/keyring ]] &&
		keyring_status=$CRYPTSH_open_status ||
		keyring_status=$CRYPTSH_closed_status
	echo -e "\e[1m  keyring :: $keyring_status"
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

setup-keyring(){
	echo -e "Creating Keyring..."
	sudo cryptsetup -v \
		-c serpent-xts-plain64 \
		-s 512 \
		-h whirlpool \
		-i 5000 \
		--use-random \
		luksFormat $CRYPTSH_keyring_dev  &&
	echo -e "Keyring created" ||
	echo -e "Failed to create Keyring"
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
	echo -e "Safe created" ||
	echo -e "Failed to create Safe"
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
