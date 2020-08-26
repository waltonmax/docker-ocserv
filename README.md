ocserv
======

[OpenConnect server][1] (ocserv) is an SSL VPN server. Its purpose is to be a
secure, small, fast and configurable VPN server.

## docker-compose.yml

```yaml
ocserv:
  image: waltonmax/ocserv
  ports:
    - "4443:443/tcp"
    - "4443:443/udp"
  environment:
    - VPN_DOMAIN=vpn.easypi.pro
    - VPN_NETWORK=10.20.30.0
    - VPN_NETMASK=255.255.255.0
    - LAN_NETWORK=192.168.0.0
    - LAN_NETMASK=255.255.0.0
    - VPN_USERNAME=waltonmax
    - VPN_PASSWORD=waltonmax
  cap_add:
    - NET_ADMIN
  restart: always
```

> - :warning: Please choose a strong password to protect VPN service.
> - These environment variables are used to generate config files/keys.
> - VPN accounts can be managed via [ocpasswd][2] command.
> - VPN status can be viewed via `occtl` command
> - You can edit the config file [/etc/ocserv/ocserv.conf][3], then restart service.

## iptables开放端口 filter
```bash
-A INPUT -p tcp -m tcp -m state --state NEW -m multiport --dports 4443 -m comment --comment ocserv_PORT -j ACCEPT
-A INPUT -p udp -m udp -m state --state NEW -m multiport --dports 4443 -m comment --comment ocserv_PORT -j ACCEPT

```
## up and running

```bash
$ docker-compose up -d
$ docker-compose exec ocserv sh
>>> cd /etc/ocserv/
>>> echo 'no-route = 1.2.3.4/32' >> /etc/ocserv/defaults/group.conf
>>> ocpasswd -c ocpasswd username
    Enter password: ******
    Re-enter password: ******
>>> exit
$ docker-compose restart
$ docker cp ocserv_ocserv_1:/etc/ocserv/certs/client.p12 .
$ docker cp ocserv_ocserv_1:/etc/ocserv/certs/server-cert.pem .
$ docker-compose logs -f
```

> You need to access your vpn server directly with `no-route`.

To remove the password protection of `client.p12`:

```bash
$ mv client.p12 client.p12.orig
$ openssl pkcs12 -in client.p12.orig -nodes -out tmp.pem
$ openssl pkcs12 -export -in tmp.pem -out client.p12 -passout pass:
$ rm tmp.pem
```

> :warning: Apple's Keychain Access will refuse to open it with no passphrase.

## mobile client

There are two auth types:

- :-1: passwd: type everytime
- :+1: certificate: import once

```
AnyConnect ->
  Connection ->
    Add New VPN Connection... ->
      Advanced Preferences... ->
        Certificate ->
          Import ->
            File System: client.p12
```

> :question: Android client show warning dialog: `Certificate is not yet valid.` ([WHY?][4])

## desktop client

[download](https://www.cellsystech.com/software/anyconnect/)

`client.p12` and `server-cert.pem` can be imported into keychain.


[1]: http://www.infradead.org/ocserv/
[2]: http://www.gnutls.org/manual/html_node/certtool-Invocation.html
[3]: http://www.infradead.org/ocserv/manual.html
[4]: http://www.cisco.com/c/en/us/td/docs/security/vpn_client/anyconnect/anyconnect31/release/notes/anyconnect31rn.html

软件下载: 
    MAC 版本号:4.9.00086 (支持Catalina 10.15),下载地址: https://www.catpaws2012.com/download/anyconnect/anyconnect-macos-4.9.00086.dmg
    MAC 老版本(Maverick/Yosemite),请使用老版本4.7.04056:下载地址: https://www.catpaws2012.com/download/anyconnect/anyconnect-macos-4.7.04056.dmg
    Windows10(32/64位)系统：AnyConnect Mobile:版本号:4.9.00086, 下载地址: https://www.catpaws2012.com/download/anyconnect/anyconnect-win-4.9.00086.msi
    Win7/8老版本操作系统：AnyConnect Mobile:版本号:4.7.04056, 下载地址: https://www.catpaws2012.com/download/anyconnect/anyconnect-win-4.7.04056.msi
