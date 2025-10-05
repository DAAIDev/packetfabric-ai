# PacketFabric.ai - Developer Setup Guide

Welcome to the PacketFabric.ai development team! This guide will get you up and running with the local development environment.

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Starting the Services](#starting-the-services)
4. [Connecting to the Database](#connecting-to-the-database)
5. [Using pgAdmin](#using-pgadmin)
6. [Environment Variables](#environment-variables)
7. [Verification Checklist](#verification-checklist)
8. [Common Commands](#common-commands)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software
- **Docker Desktop** (version 20.10+)
  - [Download for Mac](https://www.docker.com/products/docker-desktop/)
  - [Download for Windows](https://www.docker.com/products/docker-desktop/)
  - [Download for Linux](https://docs.docker.com/desktop/install/linux-install/)
- **Git** (version 2.30+)
  - [Download Git](https://git-scm.com/downloads)
- **Code Editor** (recommended: VS Code)
  - [Download VS Code](https://code.visualstudio.com/)

### Recommended VS Code Extensions
- PostgreSQL (by Chris Kolkman)
- Docker (by Microsoft)
- YAML (by Red Hat)
- GitLens (by GitKraken)

### System Requirements
- **RAM:** 8GB minimum (16GB recommended)
- **Disk Space:** 5GB free space
- **OS:** macOS, Windows 10/11, or Linux

---

## Initial Setup

### 1. Clone the Repository

```bash
# Clone the repository
git clone https://github.com/DAAIDev/packetfabric-ai.git

# Navigate to the database directory
cd packetfabric-ai/packetfabric-db
```

### 2. Verify Docker Installation

```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker-compose --version

# Verify Docker is running
docker ps
```

**Expected Output:**
```
Docker version 24.0.0 or higher
Docker Compose version 2.20.0 or higher
```

If Docker is not running, start Docker Desktop.

---

## Starting the Services

### 1. Start All Services

```bash
# Start PostgreSQL and pgAdmin in detached mode
docker-compose up -d
```

**Expected Output:**
```
Creating network "packetfibric-db_packetfabric_network" ... done
Creating packetfabric_db ... done
Creating packetfabric_pgadmin ... done
```

### 2. Verify Containers Are Running

```bash
# Check container status
docker-compose ps
```

**Expected Output:**
```
NAME                    STATUS              PORTS
packetfabric_db         Up 10 seconds       0.0.0.0:5432->5432/tcp
packetfabric_pgadmin    Up 10 seconds       0.0.0.0:5050->80/tcp
```

### 3. View Logs (Optional)

```bash
# View logs from all services
docker-compose logs -f

# View logs from PostgreSQL only
docker-compose logs -f postgres

# View logs from pgAdmin only
docker-compose logs -f pgadmin
```

Press `Ctrl+C` to exit log view.

---

## Connecting to the Database

### Connection Details

| Parameter | Value |
|-----------|-------|
| **Host** | `localhost` |
| **Port** | `5432` |
| **Database** | `packetfabric_ai` |
| **Username** | `packetfabric_admin` |
| **Password** | `change_me_in_production` |

⚠️ **Security Note:** The default password is for development only. **Never commit production credentials to Git.**

---

### Using psql (Command Line)

#### Connect from Host Machine

```bash
# Install PostgreSQL client (if not already installed)
# macOS
brew install postgresql

# Ubuntu/Debian
sudo apt-get install postgresql-client

# Windows (use Docker)
docker exec -it packetfabric_db psql -U packetfabric_admin -d packetfabric_ai
```

#### Connect Directly

```bash
# Connect to database
psql -h localhost -p 5432 -U packetfabric_admin -d packetfabric_ai
```

When prompted, enter password: `change_me_in_production`

#### Common psql Commands

```sql
-- List all tables
\dt

-- Describe table structure
\d users

-- List all databases
\l

-- List all schemas
\dn

-- Quit psql
\q
```

---

### Using Docker Exec

```bash
# Connect to database via Docker container
docker exec -it packetfabric_db psql -U packetfabric_admin -d packetfabric_ai
```

---

### Using VS Code Extension

1. Install **PostgreSQL** extension by Chris Kolkman
2. Click PostgreSQL icon in sidebar
3. Click **"+"** to add connection
4. Enter connection details:
   - Host: `localhost`
   - Port: `5432`
   - User: `packetfabric_admin`
   - Password: `change_me_in_production`
   - Database: `packetfabric_ai`
   - SSL: `Disable`
5. Test connection and save

---

## Using pgAdmin

pgAdmin provides a web-based GUI for database management.

### 1. Access pgAdmin

Open browser and navigate to: **http://localhost:5050**

### 2. Login

| Field | Value |
|-------|-------|
| **Email** | `admin@packetfabric.ai` |
| **Password** | `admin` |

### 3. Add Server Connection

**First-time setup:**

1. Click **"Add New Server"** (or right-click "Servers" → Register → Server)
2. **General Tab:**
   - Name: `PacketFabric Local`
3. **Connection Tab:**
   - Host name/address: `postgres` ⚠️ (not `localhost`)
   - Port: `5432`
   - Maintenance database: `packetfabric_ai`
   - Username: `packetfabric_admin`
   - Password: `change_me_in_production`
   - Save password: ✅ (optional)
4. Click **Save**

**Why `postgres` not `localhost`?**
pgAdmin runs inside Docker, so it uses the Docker network name (`postgres`) to connect to the database container.

### 4. Navigate the Database

After connecting:
1. Expand **Servers → PacketFabric Local**
2. Expand **Databases → packetfabric_ai**
3. Expand **Schemas → public**
4. Expand **Tables** to see all 10 tables

### 5. Run Queries

1. Right-click on **packetfabric_ai** database
2. Select **Query Tool**
3. Write SQL queries in the editor
4. Click ▶️ **Execute** or press `F5`

---

## Environment Variables

### Creating .env File

⚠️ **Important:** The `.env` file is gitignored and should **never** be committed.

Create `.env` file in `packetfabric-db/` directory:

```bash
# Navigate to project root
cd packetfabric-ai/packetfabric-db

# Create .env file
touch .env
```

### Example .env Content

```bash
# Database Configuration
DB_PASSWORD=your_secure_password_here
POSTGRES_DB=packetfabric_ai
POSTGRES_USER=packetfabric_admin

# API Keys (add when available)
ANTHROPIC_API_KEY=sk-ant-api03-...
TURBOPUFFER_API_KEY=your_turbopuffer_key
PACKETFABRIC_API_KEY=your_packetfabric_key

# n8n Configuration (future)
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your_n8n_password

# Monitoring (future)
BRAINTRUST_API_KEY=your_braintrust_key
```

### Update docker-compose.yml (Optional)

To use `.env` variables, update `docker-compose.yml`:

```yaml
services:
  postgres:
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      # ... other variables
```

Then restart services:
```bash
docker-compose down
docker-compose up -d
```

---

## Verification Checklist

Use this checklist to verify your setup is working correctly.

### ✅ Docker Services

```bash
# All containers should be "Up"
docker-compose ps
```

- [ ] `packetfabric_db` is running
- [ ] `packetfabric_pgadmin` is running

---

### ✅ Database Connection

```bash
# Should connect without errors
docker exec -it packetfabric_db psql -U packetfabric_admin -d packetfabric_ai -c "\dt"
```

**Expected Output:** List of 10 tables

- [ ] Can connect to database
- [ ] See 10 tables listed

---

### ✅ pgAdmin Access

1. Open http://localhost:5050
2. Login with `admin@packetfabric.ai` / `admin`
3. Connect to server
4. View tables

- [ ] pgAdmin loads
- [ ] Can login
- [ ] Server connection works
- [ ] Can see database tables

---

### ✅ Schema Verification

Run this query in pgAdmin or psql:

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
```

**Expected Result:** 10 tables
- [ ] users
- [ ] access_control
- [ ] documents
- [ ] chunks
- [ ] query_logs
- [ ] provisioning_orders
- [ ] provisioning_status_history
- [ ] api_usage_logs
- [ ] ingestion_jobs
- [ ] system_config

---

### ✅ Extensions

```sql
SELECT extname, extversion
FROM pg_extension;
```

**Expected Extensions:**
- [ ] `uuid-ossp`
- [ ] `pg_trgm`

---

## Common Commands

### Docker Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# Stop services and remove volumes (⚠️ deletes data)
docker-compose down -v

# View logs
docker-compose logs -f

# Restart a specific service
docker-compose restart postgres

# View container stats (CPU, memory)
docker stats

# Remove all stopped containers
docker container prune
```

---

### Database Commands

```bash
# Connect to database
docker exec -it packetfabric_db psql -U packetfabric_admin -d packetfabric_ai

# Run SQL file
docker exec -i packetfabric_db psql -U packetfabric_admin -d packetfabric_ai < schema.sql

# Backup database
docker exec packetfabric_db pg_dump -U packetfabric_admin packetfabric_ai > backup.sql

# Restore database
docker exec -i packetfabric_db psql -U packetfabric_admin -d packetfabric_ai < backup.sql

# List all databases
docker exec -it packetfabric_db psql -U packetfabric_admin -c "\l"
```

---

### Git Commands

```bash
# Check status
git status

# Pull latest changes
git pull origin main

# Create feature branch
git checkout -b feature/your-feature-name

# Stage changes
git add .

# Commit changes
git commit -m "Description of changes"

# Push changes
git push origin feature/your-feature-name
```

---

## Troubleshooting

### Port Already in Use

**Problem:** Port 5432 or 5050 is already in use

**Solution:**

```bash
# Find process using port 5432
lsof -i :5432

# Kill the process (replace PID)
kill -9 <PID>

# Or change port in docker-compose.yml
ports:
  - "5433:5432"  # Use 5433 on host instead
```

---

### Cannot Connect to Database

**Problem:** Connection refused or timeout

**Checklist:**
1. Is Docker running?
   ```bash
   docker ps
   ```
2. Is the container running?
   ```bash
   docker-compose ps
   ```
3. Are there errors in logs?
   ```bash
   docker-compose logs postgres
   ```
4. Is the health check passing?
   ```bash
   docker inspect packetfabric_db | grep -A 10 Health
   ```

**Solution:**
```bash
# Restart services
docker-compose restart

# Or rebuild from scratch
docker-compose down -v
docker-compose up -d
```

---

### pgAdmin Cannot Connect to Server

**Problem:** "Unable to connect to server"

**Common Mistakes:**
- ❌ Using `localhost` as hostname (should be `postgres`)
- ❌ Wrong port (should be `5432`)
- ❌ Containers not on same network

**Solution:**
1. Check containers are on same network:
   ```bash
   docker network inspect packetfibric-db_packetfabric_network
   ```
2. Verify both containers are listed
3. Use hostname `postgres` (not `localhost`)

---

### Schema Not Loading

**Problem:** Tables don't exist after startup

**Check:**
```bash
# View initialization logs
docker-compose logs postgres | grep schema
```

**Solution:**
```bash
# Recreate database with volume reset
docker-compose down -v
docker-compose up -d

# Or manually load schema
docker exec -i packetfabric_db psql -U packetfabric_admin -d packetfabric_ai < schema.sql
```

---

### Permission Denied Errors

**Problem:** Permission errors when accessing volumes

**Solution (macOS/Linux):**
```bash
# Fix volume permissions
sudo chown -R $USER:$USER postgres_data/ pgadmin_data/

# Or reset volumes
docker-compose down -v
docker-compose up -d
```

---

### Docker Out of Memory

**Problem:** Containers crashing or slow performance

**Solution:**
1. Open Docker Desktop
2. Go to Settings → Resources
3. Increase Memory to at least 4GB
4. Click "Apply & Restart"

---

### Extensions Not Installing

**Problem:** `uuid-ossp` or `pg_trgm` not available

**Check:**
```sql
SELECT * FROM pg_available_extensions WHERE name IN ('uuid-ossp', 'pg_trgm');
```

**Solution:**
```bash
# Manually install extensions
docker exec -it packetfabric_db psql -U packetfabric_admin -d packetfabric_ai

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
```

---

## Next Steps

### 1. Explore the Database

Run sample queries:
```sql
-- View all tables
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';

-- Check users table structure
\d users

-- Count records (should be empty initially)
SELECT COUNT(*) FROM users;
```

### 2. Review Documentation

- [Database Overview](./database-overview.md) - Complete schema documentation
- [README.md](../README.md) - Project overview and status

### 3. Join the Team

- Slack Channel: #packetfabric-ai
- Stand-ups: Daily at 10am PT
- Sprint Planning: Every other Monday

### 4. Development Workflow

1. Create feature branch
2. Make changes locally
3. Test with Docker
4. Commit and push
5. Create pull request
6. Code review
7. Merge to main

---

## Getting Help

### Resources

- **Documentation:** `docs/` folder
- **GitHub Issues:** [Report bugs](https://github.com/DAAIDev/packetfabric-ai/issues)
- **Team Chat:** Slack #packetfabric-ai
- **PostgreSQL Docs:** https://www.postgresql.org/docs/14/

### Common Questions

**Q: Can I use a different PostgreSQL version?**
A: Yes, but 14-alpine is recommended. Update `docker-compose.yml` if needed.

**Q: How do I add sample data?**
A: Create a `seed.sql` file and run: `docker exec -i packetfabric_db psql -U packetfabric_admin -d packetfabric_ai < seed.sql`

**Q: Can I access the database from outside Docker?**
A: Yes, it's exposed on `localhost:5432`

**Q: How do I reset everything?**
A: Run `docker-compose down -v && docker-compose up -d` (⚠️ deletes all data)

---

## Security Best Practices

### Development Environment
- ✅ Default credentials are acceptable
- ✅ `.env` file is gitignored
- ✅ No real user data in development

### Production Environment (Future)
- ❌ Never use default passwords
- ❌ Never commit `.env` files
- ❌ Never expose database port publicly
- ✅ Use environment variables
- ✅ Enable SSL/TLS
- ✅ Use strong passwords (20+ characters)
- ✅ Regular backups
- ✅ Monitor access logs

---

## Welcome to the Team! 🎉

You're now ready to start developing on PacketFabric.ai. If you run into any issues, check the troubleshooting section or reach out on Slack.

**Happy coding!** 🚀

---

**Last Updated:** 2025-10-05
**Maintained By:** PacketFabric.ai Team
