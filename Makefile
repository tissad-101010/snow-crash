# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: tissad <tissad@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/03/04 13:43:53 by tissad            #+#    #+#              #
#    Updated: 2026/03/19 13:22:26 by tissad           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# **************************************************************************** #
#                                   CONFIG                                     #
# **************************************************************************** #

NAME        = snowcrash
ISO         = SnowCrash.iso
DISK        = $(NAME).qcow2

RAM         = 1024
CPUS        = 2
DISK_SIZE   = 1G

QEMU        = qemu-system-x86_64

# **************************************************************************** #
#                                   RULES                                      #
# **************************************************************************** #

all: run

create-disk:
	@if [ ! -f $(DISK) ]; then \
		echo "Creating disk image ($(DISK_SIZE))..."; \
		qemu-img create -f qcow2 $(DISK) $(DISK_SIZE); \
	else \
		echo "Disk already exists."; \
	fi

run: create-disk
	@if [ ! -f $(ISO) ]; then \
		echo "Error: ISO file not found ($(ISO))"; \
		exit 1; \
	fi
	$(QEMU) \
		-m $(RAM) \
		-smp $(CPUS) \
		-drive file=$(DISK),format=qcow2 \
		-cdrom $(ISO) \
		-cpu host \
		-boot d \
		-net nic \
		-net user,hostfwd=tcp::4243-:4242 \
		-enable-kvm

ctf_build:
	docker compose -f docker-compose.yml build
ctf_run: ctf_build
	docker compose -f docker-compose.yml up -d
	docker exec -it ctf-env /bin/bash
ctf_up:
	docker compose -f docker-compose.yml up -d
	docker exec -it ctf-env /bin/bash
ctf_down:
	docker compose -f docker-compose.yml down
ctf_clean: ctf_down
	docker rmi ctf-env
ctf_prune: ctf_down
	docker system prune -a


clean:
	rm -f $(DISK)

re: clean all

.PHONY: all run clean re create-disk 