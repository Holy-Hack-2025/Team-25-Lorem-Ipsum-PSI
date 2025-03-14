# Use an official Python runtime as a parent image
FROM python:3.13-slim

# Set working directory in the container
WORKDIR /app

# Install Poetry
RUN pip install --no-cache-dir poetry

# Copy only poetry configuration files first for better layer caching
COPY pyproject.toml poetry.lock* /app/

# Install dependencies using Poetry
RUN poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-ansi --no-root

# Copy the rest of the application
COPY . /app/

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Define environment variable for Python to run in unbuffered mode
ENV PYTHONUNBUFFERED=1

# Run app when the container launches
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]