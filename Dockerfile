# Stage 1: Install browser
FROM python:3.11.4-slim-bullseye as install-browser

RUN apt-get update \
    && apt-get install -y \
    chromium=112.0.5615.138-1~deb11u1 \
    chromium-common=112.0.5615.138-1~deb11u1 \
    chromium-driver=112.0.5615.138-1~deb11u1 \
    && chromium --version && chromedriver --version

# Stage 2: Install dependencies
FROM install-browser as gpt-researcher-install

ENV PIP_ROOT_USER_ACTION=ignore

RUN mkdir /usr/src/app
WORKDIR /usr/src/app

COPY ./requirements.txt ./requirements.txt
RUN pip install -r requirements.txt

# Stage 3: Finalize and set permissions
FROM gpt-researcher-install AS gpt-researcher

# Create user and set permissions for the app directory
RUN useradd -ms /bin/bash gpt-researcher \
    && chown -R gpt-researcher:gpt-researcher /usr/src/app

# Create and set permissions for the output directory
RUN mkdir -p ./outputs && chown -R gpt-researcher:gpt-researcher ./outputs && chmod -R 755 ./outputs

USER gpt-researcher

COPY ./ ./

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
