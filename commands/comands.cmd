ssh -p 4243 level00@localhost 'bash -s' < ressources/find_ssh_port.sh
ssh -p 4243 level00@localhost 'bash -s' < ressources/find_flag00.sh

scp -P 4243 level02@192.168.1.183:level02.pcap .