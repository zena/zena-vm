# A fully functional zena installation.
FROM debian:squeeze

MAINTAINER Gaspard Bucher version: 0.1

# Install required packages
RUN apt-get update
RUN apt-get install -y install build-essential ruby rdoc ruby1.8-dev libopenssl-ruby apache2 mysql-server libmysqlclient15-dev libmagick9-dev imagemagick gs-gpl libssl-dev gettext libgettext-ruby1.8 libreadline6 libreadline6-dev zlib1g-dev libncurses5 libncurses5-dev unzip liburi-perl libjpeg-dev subversion ssh sudo awstats git-core apache2 curl libonig-dev rubygems libcurl4-openssl-dev libaprutil1-dev apache2-prefork-dev libapr1-dev

# Cleanup after us
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# ------------------------------------- Ruby gems
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc
RUN gem install rake -v=0.9.2.2
RUN gem install capistrano   -v=1.4.2
RUN gem install mysql        -v=2.8.1
RUN gem install httparty     -v=0.7.8
RUN gem install ruby_parser  -v=2.3.1
RUN gem install rubyzip      -v=0.9.9
RUN gem install activerecord -v=2.3.18
RUN gem install passenger    -v=4.0.38
RUN /var/lib/gems/1.8/bin/passenger-install-apache2-module --auto

# Authlogic hell hack
COPY vendor/authlogic-2.1.9.gem ./
RUN gem install --local ./authlogic-2.1.9.gem
RUN rm authlogic-2.1.9.gem

# Install gems for common bricks
RUN gem install textpow -v=0.10.1
RUN gem install i18n -v=0.6.11
RUN gem install daemons -v=1.1.9
RUN gem install delayed_job -v=1.8.4
RUN gem install riddle -v=1.3.2
RUN gem install thinking-sphinx -v=1.3.14
RUN gem install ts-delayed-delta -v=1.0.2
RUN gem install ultraviolet -v=0.10.2
RUN gem install rmagick -v=2.13.1

# Install zena gem
RUN gem install zena -v=1.2.8
# ------------------------------------- Create basic application
RUN cd ~
RUN zena new myapp
RUN cd myapp
# Fix default settings, set password
ADD config/deploy.rb /root/myapp/config
RUN capify .
RUN cap deploy
RUN cap mksite -s host='localhost' -s pass='zenadmin'

# ------------------------------------- Apache
# Sphinx ??
# echo "5. Install Sphinx"
# wget http://sphinxsearch.com/files/sphinx-2.0.7-release.tar.gz
# tar xzf sphinx*.tar.gz
# cd sphinx-2.0.7-release
# ./configure
# make && sudo make install
# cd ..

# ------------------------------------- Apache
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

# Expose port 80 and 8008
EXPOSE 80
EXPOSE 8008

# Start apache
CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
