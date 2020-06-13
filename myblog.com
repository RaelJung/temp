server {
    listen 80;
    listen [::]:80;

    server_name myblog.com;

    root /home/rael/html/blog;
    index index.php index.html index.htm;

    client_max_body_size 100M;

    autoindex off;

    location / {
        try_files $uri $uri/ @handler;
    }

    location  /admin {
        try_files $uri $uri/ /admin/index.php?$args;
    }

    location @handler {
        if (!-e $request_filename) { rewrite / /index.php last; }
        rewrite ^(.*.php)/ $1 last;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}

