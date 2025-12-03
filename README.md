# Development Infrastructure

Shared development infrastructure for local development across multiple projects.

## Quick Start

```bash
# Start all core services
cd C:\Projects\dev-infrastructure
docker-compose up -d

# Verify everything is running
docker ps

# Expected output:
# NAMES          STATUS           PORTS
# dev-redis      Up X (healthy)   0.0.0.0:6379->6379/tcp
# dev-postgres   Up X (healthy)   0.0.0.0:5433->5432/tcp
# dev-rabbitmq   Up X (healthy)   0.0.0.0:5672->5672/tcp, 0.0.0.0:15672->15672/tcp
```

## Migrating from Project-Specific Infrastructure

If you previously ran infrastructure containers per-project, clean them up first:

```bash
# Stop and remove old containers
docker stop sporthorizon-db-dev sporthorizon-rabbitmq-dev vaitask-postgres vaitask-redis vaitask-rabbitmq 2>/dev/null
docker rm sporthorizon-db-dev sporthorizon-rabbitmq-dev vaitask-postgres vaitask-redis vaitask-rabbitmq 2>/dev/null

# Optional: Remove old volumes (WARNING: deletes data)
docker volume rm postgres_dev_data rabbitmq_dev_data postgres_data vaitask_postgres_data 2>/dev/null

# Start shared infrastructure
cd C:\Projects\dev-infrastructure
docker-compose up -d
```

## Services

### Core Services (docker-compose.yml)
| Service | Port | Description |
|---------|------|-------------|
| PostgreSQL (TimescaleDB) | 5433 | Database server with TimescaleDB extension |
| Redis | 6379 | In-memory cache and message broker |
| RabbitMQ | 5672, 15672 | Message queue (AMQP + Management UI) |

### Monitoring Stack (docker-compose.monitoring.yml)
| Service | Port | Description |
|---------|------|-------------|
| Prometheus | 9090 | Metrics collection and storage |
| Grafana | 3000 | Dashboards and visualization |
| Loki | 3100 | Log aggregation |

## Quick Start

```bash
# Start core infrastructure
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

## Start Monitoring (Optional)

```bash
# Start monitoring stack (requires core services to be running first)
docker-compose -f docker-compose.monitoring.yml up -d
```

## Databases

The following databases are created automatically on first start:

| Database | Project | Extensions |
|----------|---------|------------|
| sporthorizon | sport-horizon | TimescaleDB, uuid-ossp |
| vaitask | vaitask | uuid-ossp |

### Connection Strings

**Sport Horizon:**
```
Host=localhost;Port=5432;Database=sporthorizon;Username=postgres;Password=postgres
```

**Vaitask:**
```
Host=localhost;Port=5432;Database=vaitask;Username=postgres;Password=postgres
```

## Service Isolation

### Redis
Projects use separate Redis databases:
- Database 0: sporthorizon
- Database 1: vaitask

Configure in your app: `localhost:6379,defaultDatabase=0` or `defaultDatabase=1`

### RabbitMQ
Projects can use separate virtual hosts for complete isolation:
- `/sporthorizon` - for sport-horizon project
- `/vaitask` - for vaitask project

Or use the default `/` vhost with queue naming conventions.

## Access URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| RabbitMQ Management | http://localhost:15672 | guest / guest |
| Grafana | http://localhost:3000 | admin / admin |
| Prometheus | http://localhost:9090 | - |

## Docker Network

All services run on the `dev-infrastructure` network. Your project's docker-compose should join this network:

```yaml
networks:
  default:
    external: true
    name: dev-infrastructure
```

This allows your containers to connect using service names:
- `dev-postgres` or `postgres` for PostgreSQL
- `dev-redis` or `redis` for Redis
- `dev-rabbitmq` or `rabbitmq` for RabbitMQ

## Stop Services

```bash
# Stop core services
docker-compose down

# Stop monitoring
docker-compose -f docker-compose.monitoring.yml down

# Stop and remove volumes (WARNING: deletes all data)
docker-compose down -v
```

## Project Configuration Changes

When migrating a project to use shared infrastructure, update these files:

### sport-horizon

| File | Change |
|------|--------|
| `docker-compose.yml` | Remove postgres/rabbitmq services, join `dev-infrastructure` network |
| `docker-compose.dev.yml` | Remove postgres/rabbitmq services, join `dev-infrastructure` network |
| `sportinsights-net/src/Api/appsettings.json` | `Port=5432`, `Password=postgres` |
| `sportinsights-net/src/Infrastructure/Persistence/ApplicationDbContextFactory.cs` | `Port=5432`, `Password=postgres` |

### vaitask

| File | Change |
|------|--------|
| `vaitask-net/docker/docker-compose.yml` | Remove infrastructure services |
| `vaitask-net/src/Api/appsettings.json` | Already correct (`Port=5432`, `Password=postgres`) |

## Troubleshooting

### Database not created
If the database wasn't created, the init script only runs on first container start. To re-run:
```bash
docker-compose down -v
docker-compose up -d
```

### Port already in use
Check for conflicting services:
```bash
netstat -ano | findstr :5432
netstat -ano | findstr :6379
netstat -ano | findstr :5672
```

### View container logs
```bash
docker-compose logs postgres
docker-compose logs rabbitmq
docker-compose logs redis
```

### Verify databases exist
```bash
docker exec dev-postgres psql -U postgres -c "\l"
```
