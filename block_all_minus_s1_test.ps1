Disable-NetFirewallRule -All
netsh advfirewall firewall add rule name="ALLOW S1 S1" dir=in action=allow protocol=ANY remoteip=3.216.168.58,52.7.53.44,107.22.88.13,34.192.9.161,35.170.99.203,54.234.190.35,44.198.16.109,44.196.2.130,18.206.63.76,52.2.22.82,18.207.91.91,34.204.165.130,35.153.189.154,34.234.19.90,54.145.7.63,107.23.183.105,3.222.13.65,35.170.169.73
netsh advfirewall firewall add rule name="DENY ALL EXCEPT S1" dir=in action=block protocol=ANY remoteip=1.1.1.1-3.216.168.57,3.216.168.59-3.222.13.64,3.222.13.66-9.255.255.255,10.0.1.0-34.204.165.129,34.204.165.161-255.255.255.255
