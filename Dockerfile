# Main Dockerfile - Uses pre-built base image with all dependencies
FROM us-central1-docker.pkg.dev/ut-dnr-ugs-maps-prod/shiny-repo/wetland-dashboard-base:latest

# Switch to root to copy files
USER root

# Copy shiny app and all data files into the Docker image
COPY app/ /srv/shiny-server/

# Make sure permissions are correct
RUN chown -R shiny:shiny /srv/shiny-server

# Remove default index.html if it exists
RUN rm -f /srv/shiny-server/index.html

# Switch back to shiny user
USER shiny

# The CMD is inherited from the base image
CMD ["/usr/bin/shiny-server.sh"]