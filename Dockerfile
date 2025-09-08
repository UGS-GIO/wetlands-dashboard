# Get shiny server plus tidyverse packages image
# Use platform specification for compatibility
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
    ## System libraries for sf package
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    ## clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/ \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Install R packages required for the dashboard
# Core Shiny and dashboard packages
RUN R -e "install.packages('shiny', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('flexdashboard', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('rmarkdown', repos='http://cran.rstudio.com/')"

# Visualization packages
RUN R -e "install.packages('leaflet', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('ggplot2', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('DT', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('kableExtra', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('fontawesome', repos='http://cran.rstudio.com/')"

# Data manipulation packages
RUN R -e "install.packages('tidyr', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('dplyr', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('sf', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('scales', repos='http://cran.rstudio.com/')"

# Optional: Database packages (commented out since you're using CSV)
# RUN R -e "install.packages('DBI', repos='http://cran.rstudio.com/')"
# RUN R -e "install.packages('RPostgres', repos='http://cran.rstudio.com/')"

# Clean up
RUN rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Copy configuration files into the Docker image
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf

# Copy shiny app and all data files into the Docker image
COPY app /srv/shiny-server/

# Remove default index.html if it exists
RUN rm -f /srv/shiny-server/index.html

# Make the ShinyApp available at port 5000
EXPOSE 5000

# Copy shiny app execution file into the Docker image
COPY shiny-server.sh /usr/bin/shiny-server.sh

# Make sure the shell script is executable
RUN chmod +x /usr/bin/shiny-server.sh

USER shiny

CMD ["/usr/bin/shiny-server"]