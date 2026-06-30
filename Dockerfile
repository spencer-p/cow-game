FROM nginx:alpine

# Run `make build` before `docker build` — the www/ dir is the compiled game.
COPY www/ /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
