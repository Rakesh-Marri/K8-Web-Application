# Use the alpine nginx official image

FROM nginx:alpine

# copy the modified nginx.conf into the container

COPY nginx.conf /etc/nginx/nginx.conf

# copy the index.html and other static files into the container

COPY ./web-application/ /usr/share/nginx/html

# Expose port 80 - default http port of nginx

EXPOSE 80

# Step 4: command to run to start the nginx process

CMD ["nginx", "-g", "daemon off;"]