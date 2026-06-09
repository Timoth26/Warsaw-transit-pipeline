FROM apache/superset:latest

USER root

RUN pip install --no-cache-dir --target /app/.venv/lib/python3.10/site-packages "pyathena[sqlalchemy]"

RUN chown -R superset:superset /app/.venv/lib/python3.10/site-packages/

USER superset