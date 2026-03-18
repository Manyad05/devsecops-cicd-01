FROM nginx:alpine

# Remove default nginx page
RUN rm -rf /usr/share/nginx/html/*

# Copy your HTML file
COPY manish-portfolio2.html /usr/share/nginx/html/index.html