FROM ubuntu:latest

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y git sudo curl nodejs libpq-dev libmysqlclient-dev qt5-default libqt5webkit5-dev

RUN adduser --home /home/webapp --shell /bin/bash --gecos 'webapp' --disabled-password webapp
RUN adduser webapp sudo
RUN echo 'webapp ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER webapp

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN \curl -sSL https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c 'source ~/.rvm/scripts/rvm'

# setup default ruby version
ENV RUBY_VER 2.3.1
RUN /bin/bash -l -c 'rvm install $RUBY_VER'
RUN /bin/bash -l -c 'rvm use $RUBY_VER --default'
RUN /bin/bash -l -c 'gem install bundler --no-ri --no-rdoc'

# preinstall some ruby versions
ENV PREINSTALLED_RUBIES "2.3.1 2.3.0 2.2.2 2.2.1 2.1.2"
RUN /bin/bash -l -c 'for version in $PREINSTALLED_RUBIES; do rvm install $version; done'

# create ruby_setup script
RUN echo "#!/bin/bash \nsource ~/.rvm/scripts/rvm || source /etc/profile.d/rvm.sh \nrvm install \$(cat .ruby-version) \nrvm use --create \$(cat .ruby-version)@\$(cat .ruby-gemset) \ngem install bundler --no-ri --no-rdoc" > ~/ruby_setup.sh
RUN chmod +x ~/ruby_setup.sh

CMD /bin/bash -l
