FROM python:3.8-alpine
WORKDIR /app
ENV REDIS_HOST=redis
ENV FLASK_ENV=development
EXPOSE 5000
COPY ./hits ./hits
RUN sh -c 'python -m pip install flask==1.1.2 redis==3.5.3'
CMD sh -c 'python -m hits'
