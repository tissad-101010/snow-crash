# snow-crash
## Overview
This repository contains the source code and resources for the "Snow Crash" Capture The Flag (CTF) challenge.
The challenge is designed to test participants' skills in various areas of cybersecurity, 
including reverse engineering, cryptography, web exploitation, and binary exploitation.

## requirements
- `SnowCrash.iso`: The ISO file for the Snow Crash VM. (This ressource is not included in the repository you can ask for.)
- Docker: The CTF environment is containerized using Docker, so you will need to have Docker installed on your machine to run the challenge.
- QEMU: To run the Snow Crash VM, you will need to have QEMU installed on your machine.
    ``` bash
    # For Debian/Ubuntu-based systems:
    sudo apt-get update
    sudo apt-get install qemu qemu-kvm
    ```



## Utils
### `Makefile`: 
This file contains a set of commands to manage the CTF environment using Docker. 
It includes targets for building the Docker image, starting and stopping the container, and cleaning up resources.
#### Commands:
- `make ctf_build`: Builds the Docker image for the CTF environment.
- `make ctf_up`: Starts the Docker container for the CTF environment.
- `make ctf_down`: Stops the Docker container for the CTF environment.
- `make ctf_clean`: Removes the Docker container for the CTF environment.
- `make ctf_clean_all`: Prunes all unused Docker resources, including images, containers, networks, and volumes.

### Find the ssh port snow-crash VM is listening on:
1. If is bridge networking:
```bash
    # run the following command on the host machine to find the Port number the Snow Crash VM is listening on:
    nmap -p- <VM_IP_ADDRESS> #on the VM run `ip a` to find the IP address
```
2. If is NAT networking:
```bash
    cat /etc/ssh/sshd_config | grep Port #on the VM run the above command to find the Port number the Snow Crash VM is listening on
    ss -tuln | grep <Port_number> #on the VM run the above command to confirm that the Snow Crash VM is listening on the specified port
``` 


### Running the Snow Crash VM with QEMU:
```bash
    qemu-system-x86_64 -hda snow-crash.qcow2 -m 2048 -net user,hostfwd=tcp::<hostPort>-:<guestPort> -net nic -nographic
```
Replace `<hostPort>` and `<guestPort>` with the appropriate port numbers for your setup.
#### Commands:
- `make run`: Runs the Snow Crash VM with the specified qemu configuration.
#### SSH Access:
- To access the Snow Crash VM via SSH from your host machine, use the following command:
```bash
    ssh user@localhost -p <hostPort>
```
Replace `<hostPort>` with the port number you specified in the qemu command for port forwarding.


- To access the Snow Crash VM via SSH from the Docker container, use the following command:
```bash
    # If NAT networking is used: 
    ssh user@<HostMachineIP> -p <hostPort>
    # If bridge networking is used:
    ssh user@<VM_IP_ADDRESS> -p <Port_number>
    # to find the IP address run the following command:
    ifconfig #or
    ip a
```
Replace `<HostMachineIP>` with the IP address of the host machine and `<hostPort>` with the port number you specified in the qemu command for port forwarding.

### Level00:
- use **find** to search everything related to the flag00 user in the machine where level00 has rights:
```bash
    RESULT=$(find / -user flag00 2>/dev/null)
    echo $RESULT
```
- we find two files:
    - /usr/sbin/john 
    - /rofs/usr/sbin/john
    - The both files contains the same string: `cdiiddwpgswtgt` which is Caesar code with a shift of 11
    - so we can decode it to get :  `nottoohardhere` using the script in file `level00/ressources/caesar_decode.sh`:
```bash
    # run the following command to decode the string:
    bash level00/ressources/caesar_decode.sh
    # the output will be:
    Decoded content: nottoohardhere
```
- This code is the password for the user flag00, so we can use it to swap to the user flag00 and get the flag for level01:

```bash
    su flag00
    # enter the password: nottoohardhere
    # then run the following command to get the flag for level01:
    getflag
```
- The flag for level01 is: `the result of getflag` which is in the file `level00/flag`

### Level01:
- Swap to the user flag01 and enter the password which is the flag for level01:
```bash
    su flag01
    # enter the password: the result of getflag
```
- Find the password for the user flag01:
```bash
    PASSWORD=$(cat /etc/passwd | grep flag01 | awk -F: '{print $2}')
    echo $PASSWORD
```
- We get this string: `42hDRfypTqqnw` 