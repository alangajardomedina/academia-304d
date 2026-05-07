#!/bin/sh

echo "Esperando MySQL en $DB_HOST:3306..."

# Espera activa
until nc -z $DB_HOST 3306; do
  echo "MySQL no disponible aún..."
  sleep 3
done

echo "MySQL disponible, iniciando backend..."

java -jar app.jar