# Main Dockerfile - Uses pre-built base image with all dependencies
# FOR LOCAL: Use wetland-dashboard-base:local (build with: docker build -f Dockerfile.base -t wetland-dashboard-base:local .)
# FOR REMOTE: Use us-central1-docker.pkg.dev/ut-dnr-ugs-maps-prod/shiny-repo/wetland-dashboard-base:latest
FROM wetland-dashboard-base:local

# Switch to root to copy files
USER root

# Copy updated shiny-server config
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf

# Copy shiny app into its own directory
COPY app/ /srv/shiny-server/wetlands/

# Make sure permissions are correct
RUN chown -R shiny:shiny /srv/shiny-server/wetlands

# Create log directory and file with proper permissions
RUN mkdir -p /var/log/shiny-server && \
    touch /var/log/shiny-server.log && \
    chown -R shiny:shiny /var/log/shiny-server /var/log/shiny-server.log

# Switch back to shiny user
USER shiny

# The CMD is inherited from the base image
CMD ["/usr/bin/shiny-server.sh"]