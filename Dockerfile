# syntax=docker/dockerfile:1

# ---------- Stage 1: build ----------
FROM eclipse-temurin:25-jdk AS build
WORKDIR /workspace

# Copy only the files needed to resolve dependencies first, so this layer
# is cached as long as the build scripts don't change.
COPY gradlew settings.gradle build.gradle ./
COPY gradle ./gradle
RUN chmod +x ./gradlew && ./gradlew --no-daemon dependencies > /dev/null 2>&1 || true

# Now copy sources and build the executable WAR. Tests are skipped here because
# the integration tests (@SpringBootTest) require a live database; run them in CI.
COPY src ./src
RUN ./gradlew --no-daemon clean bootWar -x test

# ---------- Stage 2: runtime ----------
FROM eclipse-temurin:25-jre AS runtime
WORKDIR /app

# curl is used by the container/compose healthcheck.
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# Run as an unprivileged user.
RUN groupadd --system spring && useradd --system --gid spring spring

# Copy the Spring Boot executable WAR (bootWar output, not the *-plain.war).
COPY --from=build /workspace/build/libs/*-SNAPSHOT.war app.war
RUN chown spring:spring app.war

USER spring
EXPOSE 8080

# Container-aware memory defaults; override JAVA_OPTS at runtime as needed.
ENV JAVA_OPTS="-XX:MaxRAMPercentage=75.0"

HEALTHCHECK --interval=15s --timeout=5s --start-period=60s --retries=5 \
    CMD curl -fsS http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar app.war"]
