#!/bin/bash

dnf install -q -y httpd
cat <<EOF > /var/www/html/index.html
<h1>My Web Server</h1>
<p>DB Address: ${db_address}</p>
<p>DB port   : ${db_port}</p>
EOF

systemctl enable --now httpd
