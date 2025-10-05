# PacketFabric.ai

AI-powered natural language interface for PacketFabric network services.

## 🎯 Overview

PacketFabric.ai translates user intent into actionable queries on PacketFabric data and APIs, delivering real-time pricing, provisioning workflows, and intelligent responses grounded in PacketFabric's documentation.

## ✨ Features

- 🤖 Natural language query processing
- 💰 Real-time pricing and quote generation
- 🔧 Automated service provisioning via PacketFabric API
- 📚 Document-grounded AI responses with source attribution
- 📊 Monitoring and quality assurance for AI outputs
- 🔐 Role-based access control

## 🏗️ Architecture

```
Frontend (UI) → n8n (Orchestration) → PostgreSQL Database
                        ↓
                   Claude (AI)
                        ↓
                 Turbopuffer (Vectors)
                        ↓
                PacketFabric API
```

## 🚀 Quick Start

See [Team Onboarding Guide](docs/team-onboarding.md) for complete setup instructions.

**TL;DR:**
```bash
git clone https://github.com/DAAIDev/packetfabric-ai.git
cd packetfabric-ai
docker-compose up -d
```

Access services:
- **Database:** localhost:5432
- **pgAdmin:** http://localhost:5050
- **n8n:** http://localhost:5678 (coming soon)

## 📊 Project Status

| Component | Status | Description |
|-----------|--------|-------------|
| **Database** | ✅ Complete | PostgreSQL with 10 tables, full schema |
| **n8n Workflows** | 🚧 In Progress | Document ingestion pipeline |
| **Vector DB** | 📋 Planned | Turbopuffer integration |
| **AI Layer** | 📋 Planned | Claude integration |
| **API Integration** | 📋 Planned | PacketFabric API wrappers |
| **Frontend** | 📋 Planned | Chat interface |

## 📁 Project Structure

```
packetfabric-ai/
├── docker-compose.yml        # Container configuration
├── schema.sql                # Database schema
├── .env                      # API keys (not committed)
├── docs/                     # Documentation
│   ├── database-overview.md  # Complete DB schema docs
│   └── team-onboarding.md    # Developer setup guide
└── README.md                 # This file
```

## 📚 Documentation

- **[Database Overview](docs/database-overview.md)** - Complete schema, tables, relationships
- **[Team Onboarding](docs/team-onboarding.md)** - Setup instructions for developers
- **Architecture Document** - High-level system design (coming soon)

## 🗄️ Database

**10 Production-Ready Tables:**
- `users` - User management
- `access_control` - Permissions
- `documents` - PacketFabric documentation
- `chunks` - Text chunks for RAG
- `query_logs` - User interactions
- `provisioning_orders` - Service requests
- `provisioning_status_history` - Audit trail
- `api_usage_logs` - API call tracking
- `ingestion_jobs` - Document pipeline jobs
- `system_config` - Application settings

See [Database Overview](docs/database-overview.md) for complete details.

## 🛠️ Technology Stack

- **Database:** PostgreSQL 14
- **Orchestration:** n8n
- **Vector DB:** Turbopuffer
- **AI:** Claude (Anthropic)
- **API:** PacketFabric REST API
- **Monitoring:** Braintrust
- **Containerization:** Docker

## 🔧 Development

### Database Management

```bash
# Start services
docker-compose up -d

# Connect to database
docker exec -it packetfabric_db psql -U packetfabric_admin -d packetfabric_ai

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Environment Variables

Create `.env` file (see `.env.example`):
```bash
DB_PASSWORD=your_secure_password
ANTHROPIC_API_KEY=your_key
TURBOPUFFER_API_KEY=your_key
```

## 👥 Team

- **Project Lead:** Christopher Arce
- **Contributors:** [Add team members]

## 📄 License

[Your License]

## 🤝 Contributing

1. Create feature branch
2. Make changes
3. Test locally
4. Submit pull request

## 📞 Support

- **Email:** chris@digitalalpha.ai
- **Issues:** [GitHub Issues](https://github.com/DAAIDev/packetfabric-ai/issues)
- **Docs:** See `docs/` folder
