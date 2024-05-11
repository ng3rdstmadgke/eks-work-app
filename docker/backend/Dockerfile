#
FROM python:3.10-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN printenv

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y locales pipx curl && \
    rm -rf /var/lib/apt/lists

RUN echo 'ja_JP.UTF-8 UTF-8' >> /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=ja_JP.UTF-8

RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# poetry インストール
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH="/root/.local/bin:$PATH"

COPY backend /opt/app
RUN cd /opt/app && \
    poetry install --no-dev

WORKDIR /opt/app

COPY docker/backend/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
CMD ["/usr/local/bin/entrypoint.sh"]