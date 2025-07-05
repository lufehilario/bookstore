FROM python:3.13.3-slim AS python-base

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

ENV POETRY_VERSION=2.1.2 \
    POETRY_HOME=/opt/poetry \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1

ENV PYSETUP_PATH=/opt/pysetup \
    VENV_PATH=/opt/pysetup/.venv

ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

FROM python-base AS builder-base
RUN apt-get update && apt-get install --no-install-recommends -y curl build-essential

RUN curl -sSL https://install.python-poetry.org | python

RUN apt-get update && apt-get -y install libpq-dev gcc && pip install psycopg2

WORKDIR $PYSETUP_PATH
COPY poetry.lock pyproject.toml ./

RUN poetry install --no-root

WORKDIR /app
COPY . /app/
EXPOSE 8000
CMD [ "python", "manage.py", "runserver", "0.0.0.0:8000" ]