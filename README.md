🚀 Karate Automation Framework

Este proyecto contiene pruebas automatizadas desarrolladas con Karate Framework, enfocadas en la validación de servicios API con un enfoque BDD (Behavior Driven Development).

🛠️ Stack Tecnológico

Lenguaje: Java 17 (LTS)

Framework de Pruebas: Karate 1.4.1

Pruebas de carga: Gatling 3.9.5 + Karate Gatling

Gestor de Dependencias: Gradle 8.4

Antes de ejecutar el proyecto, asegúrate de cumplir con lo siguiente:



Git: Instalado y configurado (Descargar Git).



JDK 17: Configurado en tus variables de entorno (JAVA\_HOME).



Gradle 8.12.1+: El proyecto incluye el gradlew wrapper, por lo que no es estrictamente necesario instalarlo globalmente.



📂 Guía de Git (Flujo de Trabajo)

Si eres nuevo en el proyecto o necesitas actualizar tu rama, sigue estos pasos en la terminal:



1\. Clonar el repositorio


git clone https://url-del-repositorio.git

cd nombre-del-proyecto

2\. Sincronizar cambios del servidor

Antes de empezar a trabajar, es buena práctica bajar lo último:

git fetch origin          # Descarga info de lo que hay en el servidor

git pull origin main      # Trae los cambios a tu rama local (asumiendo 'main')

3\. Trabajar en una nueva funcionalidad

Nunca trabajes directamente sobre la rama principal. Crea una rama propia:

git switch -c feature/nombre-de-tu-mejora

4\. Guardar y subir cambios


git add .                                   # Prepara los archivos

git commit -m "feat: agrega pruebas de login" # Crea el punto de guardado

git push origin feature/nombre-de-tu-mejora  # Sube la rama al servidor

🚀 Ejecución de Pruebas

Ejecuta los tests desde la terminal usando el wrapper de Gradle:

Ejecutar todos los tests:

./gradlew test

Ejecutar un feature o Runner específico:

./gradlew test --tests "nombre.de.tu.clase.Runner"

Ejecutar la prueba PoC de carga para creación de grupos:

./gradlew gatlingRun-performance.SavingGroupCreateSimulation

📊 Reportes

Al finalizar, Karate genera reportes HTML detallados. Puedes encontrarlos en:

build/karate-reports/karate-summary.html

Gatling genera el reporte HTML de la prueba de carga en:

build/reports/gatling/savinggroupcreatesimulation-*/index.html

📁 Estructura del Proyecto

src/test/java: Contiene los archivos .feature y las clases Java Runner.

src/gatling/scala: Contiene las simulaciones Gatling.

src/gatling/resources: Contiene features Karate usados por Gatling.

karate-config.js: Configuración global (URLs, ambientes, variables).

build.gradle: Definición de dependencias y plugins.
