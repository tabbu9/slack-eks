
FROM nginx:latest

WORKDIR /usr/share/nginx/html

COPY index.html /usr/share/nginx/html/index.html

CMD ["start", nginx, -g demon]
