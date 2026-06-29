FROM nginx:alpine

# Copy game files to nginx web root
COPY index.html /usr/share/nginx/html/
COPY audio-adapter.js /usr/share/nginx/html/
COPY cowgame.love /usr/share/nginx/html/

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
