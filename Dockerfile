# Use official nginx base image
FROM nginx:latest

# Optional: Copy custom index.html to replace the default
COPY index.html /usr/share/nginx/html/index.html
