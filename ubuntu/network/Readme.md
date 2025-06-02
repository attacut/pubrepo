
- /etc/netplan/50-cloud-init.yaml 
- netplan apply 

```yaml
network:
  version: 2
  wifis:
    wlan0:
      dhcp4: no
      addresses:
        - 192.168.1.230/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
      access-points:
        "XXXX":
          auth:
            key-management: "psk"
            password: "ffce312"
```