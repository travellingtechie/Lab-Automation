To create key files
```
openssl req -x509 -newkey rsa:2048 -keyout /home/user/certificates/key.key -out /home/user/certificates/cer.crt -days 3560 -nodes -subj "/C=US/ST=state/L=city/O=organization/OU=IT/CN=example.com"
```