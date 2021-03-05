server {
    listen 80;
    listen [::]:80;

    server_name events.grumdog.com;

    location / {
        proxy_pass http://localhost:4444;
    }

    location /socket {
        proxy_pass http://localhost:4444;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";	 	 
    }
}
