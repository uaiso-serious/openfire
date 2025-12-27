# Openfire

Openfire container image

## Quick run:

```bash
docker run -d -p 9090:9090 -p 5222:5222 ghcr.io/uaiso-serious/openfire:latest
```

http://localhost:9090

- user: admin
- password: admin

With persistent storage:

```bash
docker run -d -p 9090:9090 -p 5222:5222 \
  -v /some/path/with/777/chmod/or/docker-volume:/data \
  ghcr.io/uaiso-serious/openfire:latest
```

---

## Environment Variables for `docker run`

You can configure the Openfire container using the following environment variables when running with
`docker run -e ...`:

- `DOMAIN`: XMPP domain (default: `localhost`)
- `FQDN`: Fully Qualified Domain Name (default: `localhost`)
- `ADMIN_EMAIL`: Admin email address (default: `admin%40example.com`)
- `ADMIN_PASSWORD`: Admin password (default: `admin`)
- `REST_API_SECRET`: Secret for REST API plugin (default: `myrestapisecret`)
- `DB_TYPE`: Database type (`embedded`, `postgres`, `mysql`, `oracle`, `mssql`; default: `embedded`)
- `DB_SERVER_URL`: JDBC connection string (Postgres only, default: `jdbc:postgresql://localhost:5432/openfire`)
- `DB_USERNAME`: Database username (Postgres only, default: `postgres`)
- `DB_PASSWORD`: Database password (Postgres only, default: `mysecurepassword`)
- `DB_MIN_CONNECTIONS`: Minimum DB connections (Postgres only, default: `5`)
- `DB_MAX_CONNECTIONS`: Maximum DB connections (Postgres only, default: `25`)
- `DB_CONNECTION_TIMEOUT`: DB connection timeout in seconds (Postgres only, default: `1.0`)

### Example

```bash
docker run -e DOMAIN=example.com \
           -e FQDN=chat.example.com \
           -e ADMIN_EMAIL=admin%40example.com \
           -e ADMIN_PASSWORD=supersecret \
           -e REST_API_SECRET=superdupersecret \
           -e DB_TYPE=postgres \
           -e DB_SERVER_URL="jdbc:postgresql://dbhost:5432/openfire" \
           -e DB_USERNAME=postgres \
           -e DB_PASSWORD=yourpassword \
           -p 9090:9090 \
           -p 5222:5222 \
           ghcr.io/uaiso-serious/openfire:latest
```
