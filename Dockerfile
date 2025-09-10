# Get shiny server plus tidyverse packages image
FROM --platform=linux/amd64 rocker/shiny-verse:latest

# System libraries of general use
RUN apt-get update && apt-get install -y \
 curl \
 sudo \
 pandoc \
 libcurl4-gnutls-dev \
 libcairo2-dev \
 libxt-dev \
 libssl-dev \
 libssh2-1-dev \
 libxml2-dev \
 libfontconfig1-dev \
 libharfbuzz-dev \
 libfribidi-dev \
 libfreetype6-dev \
 libpng-dev \
 libtiff5-dev \
 libjpeg-dev \
 libudunits2-dev \
 libgdal-dev \
 libgeos-dev \
 libproj-dev \
 libmagick++-dev \
 ## Add cmake for s2 package compilation
 cmake \
 ## Or alternatively, install abseil directly (uncomment one of these):
 # libabsl-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/ \
 && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Install all required R packages
RUN R -e "options(repos = 'https://cloud.r-project.org/'); \
    install.packages(c('shiny', 'flexdashboard', 'rmarkdown', 'fontawesome', \
                      'leaflet', 'tidyr', 'dplyr', 'ggplot2', 'sf', \
                      'kableExtra', 'scales', 'DT'), \
                    dependencies = TRUE); \
    if (!all(c('leaflet', 'shiny', 'flexdashboard', 'sf', 'DT') %in% rownames(installed.packages()))) { \
        stop('Some packages failed to install'); \
    } else { \
        cat('All packages installed successfully!\n'); \
    }"

# Verify critical packages can be loaded
RUN R -e "library(leaflet); library(shiny); library(flexdashboard); library(sf); library(DT); \
          cat('All critical libraries loaded successfully!\n')"

# List installed packages for debugging
RUN R -e "cat('Installed packages:\n'); print(rownames(installed.packages()))"

# Clean up
RUN rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Copy configuration files into the Docker image
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf

# Copy shiny app and all data files into the Docker image
COPY app /srv/shiny-server/

# Remove default index.html if it exists
RUN rm -f /srv/shiny-server/index.html

# Make the ShinyApp available at port 8080
EXPOSE 8080

# Copy shiny app execution file into the Docker image
COPY shiny-server.sh /usr/bin/shiny-server.sh

# Make sure the shell script is executable
RUN chmod +x /usr/bin/shiny-server.sh

USER shiny
CMD ["/usr/bin/shiny-server.sh"]