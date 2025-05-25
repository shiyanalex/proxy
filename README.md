# Creating Shadowsocks Proxy on Google Cloud VM

Shadowsocks is a secure proxy protocol inspired by SOCKS5, with built-in encryption (AES, ChaCha20, etc.) and some other modifications.

## How to set up

1. Create a VM in Google Cloud (e2-small works fine). Create random network tag for it.

2. Open the VM terminal in the browser and run:

   ```bash
   wget https://raw.githubusercontent.com/shiyanalex/proxy/refs/heads/master/script.sh -O script.sh && chmod +x script.sh && sudo ./script.sh
   ```
   (may take up to 10 min to complete, just wait)
4. Enter port or press enter to use default 8388. Copy settings into your proxy client.

5. In Google Cloud go to firewall -> Create firewall policy -> Enable TCP, enter your port and your VM network tag from step 1.

5. Enjoy
## Usage & Tips

- **Check daily data usage**:
  ```bash
  vnstat -d
  ```

- **Check Shadowsocks status**:
  ```bash
  systemctl status shadowsocks-libev
  ```

- **Restart the service**:
  ```bash
  sudo systemctl restart shadowsocks-libev
  ```

- **View your current configuration**:
  ```bash
  cat /etc/shadowsocks-libev/config.json
  ```
