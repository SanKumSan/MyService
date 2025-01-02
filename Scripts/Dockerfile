# Base image for RabbitMQ
FROM rabbitmq:3.13.7-management-alpine
#docker pull rabbitmq:3.13.7-management-alpine

# Add custom plugins configuration
#COPY enabled_plugins /etc/rabbitmq/enabled_plugins

# Environment variables for default user and password
ENV RABBITMQ_DEFAULT_USER=username
ENV RABBITMQ_DEFAULT_PASS=password

# Define environment variables.
#ENV RABBITMQ_MNESIA_BASE /data/mnesia

# Set environment variables for logging
ENV RABBITMQ_LOG_BASE=/var/log/rabbitmq
ENV RABBITMQ_LOGS=/var/log/rabbitmq/rabbit.log

# Declare volumes for persistence
VOLUME ["/var/lib/rabbitmq", "/var/log/rabbitmq"]

# Expose RabbitMQ ports
EXPOSE 5672 15672

# Command to start RabbitMQ
CMD ["rabbitmq-server"]
