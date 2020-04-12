FROM debian:buster-slim
ADD build_debs.sh /tmp/
RUN /tmp/build_debs.sh

FROM debian:buster-slim
COPY --from=0 /bareos/*.deb ./
ENV DEBIAN_FRONTEND noninteractive
ENV BAREOS_DPKG_CONF bareos-database-common bareos-database-common
ENV BAREOS_DB_TYPE mysql
RUN apt-get update && \
  echo "${BAREOS_DPKG_CONF}/dbconfig-install boolean false" \
    | debconf-set-selections && \
  echo "${BAREOS_DPKG_CONF}/install-error select ignore" \
    | debconf-set-selections && \
  echo "${BAREOS_DPKG_CONF}/database-type select ${BAREOS_DB_TYPE}" \
    | debconf-set-selections && \
  echo "${BAREOS_DPKG_CONF}/missing-db-package-error select ignore" \
    | debconf-set-selections && \
  echo 'postfix postfix/main_mailer_type select No configuration' \
    | debconf-set-selections && \
  apt-get -y install $(ls ./*.deb | grep -e database-${BAREOS_DB_TYPE} -e common -e director -e storage -e tools) && \
  apt-get clean autoclean && \
  apt-get autoremove --yes && \
  rm -rf /var/lib/apt /var/lib/dpkg /var/lib/cache /var/lib/log && \
  rm -f *.deb
