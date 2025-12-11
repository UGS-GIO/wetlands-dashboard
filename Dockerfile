# Main Dockerfile - Uses pre-built base image with all dependencies
# FOR LOCAL: Use wetland-dashboard-base:local (build with: docker build -f Dockerfile.base -t wetland-dashboard-base:local .)
# FOR REMOTE: Use us-central1-docker.pkg.dev/ut-dnr-ugs-maps-prod/shiny-repo/wetland-dashboard-base:latest
FROM us-central1-docker.pkg.dev/ut-dnr-ugs-maps-prod/shiny-repo/wetland-dashboard-base:latest

# Switch to root to copy files
USER root

# Copy shiny app into its own directory
COPY app/ /srv/shiny-server/wetlands/

# Make sure permissions are correct
RUN chown -R shiny:shiny /srv/shiny-server/wetlands

# Switch back to shiny user
USER shiny

# The CMD is inherited from the base image
CMD ["/usr/bin/shiny-server.sh"]