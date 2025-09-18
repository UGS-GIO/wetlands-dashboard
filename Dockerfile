# Get shiny server plus tidyverse packages image
FROM --platform=linux/amd64 rocker/shiny-verse:latest

# Use binary packages from RStudio Package Manager for faster installs
RUN echo "options(repos = c(CRAN = 'https://packagemanager.rstudio.com/cran/__linux__/jammy/latest'))" >> /usr/local/lib/R/etc/Rprofile.site

# System libraries of general use (install in one layer)
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
 cmake \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Install R packages in separate layers for better caching
# Core packages (rarely change)
RUN R -e "install.packages(c('shiny', 'flexdashboard', 'rmarkdown'), dependencies = TRUE)"

# Visualization packages 
RUN R -e "install.packages(c('ggplot2', 'scales', 'fontawesome'), dependencies = TRUE)"

# Data manipulation packages
RUN R -e "install.packages(c('tidyr', 'dplyr', 'kableExtra', 'DT'), dependencies = TRUE)"

# API and network packages
RUN R -e "install.packages(c('httr', 'jsonlite'), dependencies = TRUE)"

# Geospatial packages (slowest, so install last)
RUN R -e "install.packages(c('leaflet', 'sf'), dependencies = TRUE)"

# Verify only critical packages (reduce verification time)
RUN R -e "library(shiny); library(flexdashboard); library(leaflet); library(sf); cat('Critical packages loaded successfully!\n')"

# Clean up
RUN rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Copy configuration files
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf
COPY shiny-server.sh /usr/bin/shiny-server.sh
RUN chmod +x /usr/bin/shiny-server.sh

# Copy app files (do this last so code changes don't invalidate package layers)
COPY app /srv/shiny-server/
RUN rm -f /srv/shiny-server/index.html

# Set environment and expose port
ENV PORT=8080
EXPOSE 8080

USER shiny
CMD ["/usr/bin/shiny-server.sh"]