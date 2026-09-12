FROM python:3.14-slim-bookworm

RUN mkdir -p /var/app 2> /dev/null
RUN mkdir -p /var/app/flask 2> /dev/null
RUN apt-get update
RUN apt-get install -y gcc
COPY requirements.txt /var/app/flask/
RUN pip install -r /var/app/flask/requirements.txt
COPY app.py /var/app/flask/
COPY uwsgi.ini /var/app/flask/

EXPOSE 8080

#CMD ["python", "/var/app/flask/app.py"]
CMD ["uwsgi", "--ini", "/var/app/flask/uwsgi.ini"]
