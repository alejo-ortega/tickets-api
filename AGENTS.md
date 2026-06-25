# AGENTS.md

## Stack & versions
- **Java 25** (toolchain in `build.gradle`)
- **Spring Boot 4.1.0** (Spring Framework 7)
- **Gradle 9.5.1** (wrapper at `./gradlew`)
- **PostgreSQL** via Docker Compose (auto-managed by `spring-boot-docker-compose` in dev)
- **WAR** packaging (`war` plugin active; `ServletInitializer` present)

## Commands
```bash
./gradlew test              # run all tests (JUnit 5 / Jupiter)
./gradlew test --tests "FullyQualifiedTestClassName"   # single test class
```

There is no lint/format/typecheck script. MapStruct and Lombok are the only annotation processors.

## Dev environment
- `compose.yaml` starts a PostgreSQL container. The `spring-boot-docker-compose` dependency auto-launches it on boot in dev profile. No manual `docker compose up` needed.
- Database: `mydatabase`, user `myuser`, password `secret`, port `5432`.
- VS Code launch config references `${workspaceFolder}/.env` for additional env vars (file does not exist yet — create it if needed).

## Package naming
The original artifact name `xyz.alejo-ortega.tickets-api` was invalid as a Java package. The actual base package is **`xyz.alejo_ortega.tickets_api`**.

## Flyway
Migrations go in `src/main/resources/db/migration/`. Follow Flyway naming: `V{n}__description.sql` (double underscore after version). The directory exists but is currently empty.

## MapStruct & Lombok
Both require annotation processors declared in `build.gradle`. MapStruct must be declared in both `implementation` and `annotationProcessor` scopes. When you create a Mapper interface, add `@Mapper(componentModel = "spring")`.

## Security
**Spring Security** is on the classpath — all endpoints will require authentication by default unless you configure a `SecurityFilterChain` bean. **JJWT 0.13.0** (`io.jsonwebtoken`) is included for JWT-based auth.

## Testing
- Tests use `@SpringBootTest` (integration tests by default). Tests requiring a database need the PostgreSQL container running (handled by docker-compose support in dev).
- Use `@WebMvcTest`, `@DataJpaTest`, etc. for sliced tests once controllers/repositories exist.
- Lombok is also available in test scope (`testCompileOnly` + `testAnnotationProcessor`).

## .gitignore quirk
The `.gitignore` allows nested `build/` directories under `src/main/**` and `src/test/**` (`!**/src/main/**/build/`). Do not assume all `build/` dirs are ignored.
