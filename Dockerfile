FROM python:3.9-alpine

LABEL maintainer="Garv Aggarwal"

ENV PYTHONUNBUFFERED 1 

COPY requirements.txt /tmp/requirements.txt
COPY requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

WORKDIR /app

EXPOSE 8000

ARG DEV=false

RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip --timeout 100 --retries 3 && \
    apk add --update --no-cache posgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
    build-base posgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt --timeout 100 --retries 3 && \
    if [ "$DEV"="true" ]; \
    then /py/bin/pip install -r /tmp/requirements.dev.txt --timeout 100 --retries 3; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
    --disabled-password \
    --no-create-home \
    django-user

ENV PATH="/py/bin:$PATH"

USER django-user