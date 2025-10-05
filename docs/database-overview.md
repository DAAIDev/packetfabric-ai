# PacketFabric.ai Database Structure Overview

## Database Information
- **Database Name:** `packetfabric_ai`
- **PostgreSQL Version:** 14-alpine
- **Character Set:** UTF8
- **Extensions:** `uuid-ossp`, `pg_trgm`

---

## Table of Contents
1. [Tables Overview](#tables-overview)
2. [Table Details](#table-details)
3. [Relationships](#relationships)
4. [Data Flow](#data-flow)
5. [Use Cases](#use-cases)

---

## Tables Overview

| Table Name | Purpose | Key Features |
|------------|---------|--------------|
| `users` | User account management | Authentication, roles, activity tracking |
| `access_control` | Permission management | Resource-level access control |
| `documents` | Documentation storage | Version control, content hashing, metadata |
| `chunks` | Text chunks for RAG | Embedding storage, semantic search |
| `query_logs` | User interaction tracking | Performance metrics, feedback loop |
| `provisioning_orders` | Service order management | API integration, workflow tracking |
| `provisioning_status_history` | Audit trail | Complete order lifecycle history |
| `api_usage_logs` | API call tracking | Rate limiting, cost analysis |
| `ingestion_jobs` | Document pipeline | Job status, error handling |
| `system_config` | Application settings | Feature flags, API keys |

---

## Table Details

### 1. users
**Purpose:** Manage user accounts, authentication, and role-based permissions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | PRIMARY KEY | Unique identifier |
| `email` | VARCHAR(255) | UNIQUE, NOT NULL | User email address |
| `username` | VARCHAR(100) | UNIQUE, NOT NULL | Display name |
| `full_name` | VARCHAR(255) | | Full name |
| `role` | VARCHAR(50) | CHECK | `admin`, `user`, `readonly` |
| `is_active` | BOOLEAN | DEFAULT true | Account status |
| `created_at` | TIMESTAMP | DEFAULT NOW() | Account creation |
| `updated_at` | TIMESTAMP | DEFAULT NOW() | Last modification |
| `last_login` | TIMESTAMP | | Last login time |

**Indexes:**
- `idx_users_email` on `email`
- `idx_users_username` on `username`
- `idx_users_role` on `role`

---

### 2. access_control
**Purpose:** Fine-grained access control for resources and actions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `acl_id` | UUID | PRIMARY KEY | Unique identifier |
| `user_id` | UUID | FOREIGN KEY → users | User reference |
| `resource_type` | VARCHAR(50) | NOT NULL | Type of resource |
| `resource_id` | VARCHAR(255) | | Specific resource ID |
| `permission` | VARCHAR(50) | CHECK | `read`, `write`, `delete`, `admin` |
| `granted_at` | TIMESTAMP | DEFAULT NOW() | Permission grant time |
| `granted_by` | UUID | FOREIGN KEY → users | Admin who granted |

**Indexes:**
- `idx_acl_user` on `user_id`
- `idx_acl_resource` on `resource_type, resource_id`

**Unique Constraint:** `(user_id, resource_type, resource_id, permission)`

---

### 3. documents
**Purpose:** Store PacketFabric documentation with version control and metadata.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `document_id` | UUID | PRIMARY KEY | Unique identifier |
| `source_url` | TEXT | | Original document URL |
| `title` | VARCHAR(500) | NOT NULL | Document title |
| `document_type` | VARCHAR(100) | NOT NULL | Type (guide, API, FAQ) |
| `category` | VARCHAR(100) | | Category/section |
| `version` | VARCHAR(50) | DEFAULT '1.0' | Version number |
| `content_hash` | VARCHAR(64) | NOT NULL | SHA-256 hash |
| `raw_content` | TEXT | | Original content |
| `normalized_content` | TEXT | | Cleaned content |
| `metadata` | JSONB | | Additional metadata |
| `storage_path` | TEXT | | File path if stored externally |
| `is_active` | BOOLEAN | DEFAULT true | Active status |
| `created_at` | TIMESTAMP | DEFAULT NOW() | Creation time |
| `updated_at` | TIMESTAMP | DEFAULT NOW() | Last update |
| `indexed_at` | TIMESTAMP | | Last indexing time |

**Indexes:**
- `idx_documents_type` on `document_type`
- `idx_documents_category` on `category`
- `idx_documents_hash` on `content_hash`
- `idx_documents_metadata` on `metadata` (GIN)

---

### 4. chunks
**Purpose:** Store text chunks with embeddings for semantic search (RAG).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `chunk_id` | UUID | PRIMARY KEY | Unique identifier |
| `document_id` | UUID | FOREIGN KEY → documents | Parent document |
| `chunk_index` | INTEGER | NOT NULL | Position in document |
| `chunk_text` | TEXT | NOT NULL | Text content |
| `token_count` | INTEGER | | Token count |
| `embedding` | VECTOR(1536) | | OpenAI embedding |
| `metadata` | JSONB | | Additional metadata |
| `created_at` | TIMESTAMP | DEFAULT NOW() | Creation time |

**Indexes:**
- `idx_chunks_document` on `document_id`
- `idx_chunks_embedding` on `embedding` (vector similarity)

**Unique Constraint:** `(document_id, chunk_index)`

---

### 5. query_logs
**Purpose:** Track user queries, AI responses, and feedback for quality improvement.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `query_id` | UUID | PRIMARY KEY | Unique identifier |
| `user_id` | UUID | FOREIGN KEY → users | User who queried |
| `query_text` | TEXT | NOT NULL | Original query |
| `query_intent` | VARCHAR(100) | | Classified intent |
| `response_text` | TEXT | | AI response |
| `sources_used` | JSONB | | Documents referenced |
| `api_calls_made` | JSONB | | PacketFabric API calls |
| `response_time_ms` | INTEGER | | Response latency |
| `tokens_used` | INTEGER | | AI tokens consumed |
| `user_feedback` | VARCHAR(20) | CHECK | `positive`, `negative`, `neutral` |
| `feedback_notes` | TEXT | | User comments |
| `created_at` | TIMESTAMP | DEFAULT NOW() | Query time |

**Indexes:**
- `idx_query_user` on `user_id`
- `idx_query_intent` on `query_intent`
- `idx_query_created` on `created_at`

---

### 6. provisioning_orders
**Purpose:** Manage service provisioning requests and PacketFabric API integration.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `order_id` | UUID | PRIMARY KEY | Unique identifier |
| `user_id` | UUID | FOREIGN KEY → users | Requesting user |
| `query_id` | UUID | FOREIGN KEY → query_logs | Originating query |
| `service_type` | VARCHAR(100) | NOT NULL | Service type |
| `order_details` | JSONB | NOT NULL | Service parameters |
| `estimated_cost` | DECIMAL(10,2) | | Estimated cost |
| `status` | VARCHAR(50) | DEFAULT 'pending' | Order status |
| `packetfabric_order_id` | VARCHAR(255) | | PF API order ID |
| `api_response` | JSONB | | Full API response |
| `error_message` | TEXT | | Error details |
| `created_at` | TIMESTAMP | DEFAULT NOW() | Order creation |
| `updated_at` | TIMESTAMP | DEFAULT NOW() | Last update |
| `completed_at` | TIMESTAMP | | Completion time |

**Status Values:** `pending`, `submitted`, `in_progress`, `completed`, `failed`, `cancelled`

**Indexes:**
- `idx_prov_user` on `user_id`
- `idx_prov_status` on `status`
- `idx_prov_created` on `created_at`

---

### 7. provisioning_status_history
**Purpose:** Complete audit trail of provisioning order state changes.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `history_id` | UUID | PRIMARY KEY | Unique identifier |
| `order_id` | UUID | FOREIGN KEY → provisioning_orders | Related order |
| `status` | VARCHAR(50) | NOT NULL | New status |
| `details` | TEXT | | Status details |
| `changed_by` | UUID | FOREIGN KEY → users | User/system actor |
| `created_at` | TIMESTAMP | DEFAULT NOW() | Change time |

**Indexes:**
- `idx_prov_history_order` on `order_id`
- `idx_prov_history_created` on `created_at`

---

### 8. api_usage_logs
**Purpose:** Track PacketFabric API calls for monitoring and cost analysis.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `log_id` | UUID | PRIMARY KEY | Unique identifier |
| `user_id` | UUID | FOREIGN KEY → users | User who triggered |
| `endpoint` | VARCHAR(255) | NOT NULL | API endpoint |
| `method` | VARCHAR(10) | NOT NULL | HTTP method |
| `request_payload` | JSONB | | Request body |
| `response_status` | INTEGER | | HTTP status code |
| `response_payload` | JSONB | | Response body |
| `response_time_ms` | INTEGER | | API latency |
| `error_message` | TEXT | | Error details |
| `created_at` | TIMESTAMP | DEFAULT NOW() | Call time |

**Indexes:**
- `idx_api_user` on `user_id`
- `idx_api_endpoint` on `endpoint`
- `idx_api_created` on `created_at`
- `idx_api_status` on `response_status`

---

### 9. ingestion_jobs
**Purpose:** Track document ingestion pipeline jobs (n8n workflows).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `job_id` | UUID | PRIMARY KEY | Unique identifier |
| `job_type` | VARCHAR(100) | NOT NULL | Job type |
| `source` | VARCHAR(255) | | Data source |
| `status` | VARCHAR(50) | DEFAULT 'pending' | Job status |
| `documents_processed` | INTEGER | DEFAULT 0 | Docs processed |
| `documents_failed` | INTEGER | DEFAULT 0 | Failed docs |
| `error_log` | TEXT | | Error details |
| `metadata` | JSONB | | Additional metadata |
| `started_at` | TIMESTAMP | | Start time |
| `completed_at` | TIMESTAMP | | Completion time |
| `created_at` | TIMESTAMP | DEFAULT NOW() | Job creation |

**Status Values:** `pending`, `running`, `completed`, `failed`

**Indexes:**
- `idx_ingestion_status` on `status`
- `idx_ingestion_created` on `created_at`

---

### 10. system_config
**Purpose:** Store application configuration, feature flags, and API keys.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `config_id` | UUID | PRIMARY KEY | Unique identifier |
| `config_key` | VARCHAR(100) | UNIQUE, NOT NULL | Configuration key |
| `config_value` | TEXT | NOT NULL | Configuration value |
| `value_type` | VARCHAR(50) | DEFAULT 'string' | Data type |
| `description` | TEXT | | Human-readable description |
| `is_secret` | BOOLEAN | DEFAULT false | Sensitive data flag |
| `updated_at` | TIMESTAMP | DEFAULT NOW() | Last update |
| `updated_by` | UUID | FOREIGN KEY → users | User who updated |

**Value Types:** `string`, `integer`, `boolean`, `json`

**Indexes:**
- `idx_config_key` on `config_key`

---

## Relationships

### Entity Relationship Diagram

```
users (1) ─────────< (N) query_logs
  │                      │
  │                      └──< (1) provisioning_orders
  │                               │
  │                               └──< (N) provisioning_status_history
  │
  ├─────────< (N) access_control
  │
  └─────────< (N) api_usage_logs

documents (1) ─────< (N) chunks

ingestion_jobs (independent)

system_config (independent)
```

### Key Relationships

1. **User → Query Logs** (1:N)
   - Each user can make multiple queries
   - Tracks user interaction history

2. **Query → Provisioning Order** (1:1 or 1:0)
   - Not all queries result in provisioning
   - Links orders back to originating query

3. **Provisioning Order → Status History** (1:N)
   - Complete audit trail of order lifecycle
   - Tracks all state changes

4. **Document → Chunks** (1:N)
   - Each document split into multiple chunks
   - Enables RAG and semantic search

5. **User → Access Control** (1:N)
   - Fine-grained permissions per user
   - Resource-level access control

---

## Data Flow

### 1. Document Ingestion Flow
```
External Source → ingestion_jobs (pending)
                        ↓
                   documents (created)
                        ↓
                   chunks (with embeddings)
                        ↓
                 ingestion_jobs (completed)
```

### 2. User Query Flow
```
User Query → query_logs (created)
                  ↓
            RAG Search (chunks)
                  ↓
            AI Response
                  ↓
         query_logs (updated with response)
                  ↓
    [Optional] provisioning_orders (created)
                  ↓
         provisioning_status_history (audit trail)
```

### 3. API Call Flow
```
User Action → api_usage_logs (before call)
                    ↓
             PacketFabric API
                    ↓
         api_usage_logs (updated with response)
                    ↓
      [If provisioning] provisioning_orders (updated)
```

---

## Use Cases

### 1. User Management
**Tables:** `users`, `access_control`

**Example:** Create admin user with full access
```sql
INSERT INTO users (email, username, full_name, role)
VALUES ('admin@example.com', 'admin', 'Admin User', 'admin');

INSERT INTO access_control (user_id, resource_type, permission)
VALUES ('user-uuid', 'documents', 'admin');
```

---

### 2. Document Ingestion
**Tables:** `ingestion_jobs`, `documents`, `chunks`

**Workflow:**
1. Create ingestion job
2. Fetch and store documents
3. Split into chunks
4. Generate embeddings
5. Mark job complete

---

### 3. RAG Query
**Tables:** `query_logs`, `chunks`, `documents`

**Workflow:**
1. Log user query
2. Generate query embedding
3. Semantic search in `chunks`
4. Retrieve parent `documents`
5. Generate AI response
6. Update query log with response and sources

---

### 4. Service Provisioning
**Tables:** `provisioning_orders`, `provisioning_status_history`, `api_usage_logs`

**Workflow:**
1. Create order from query
2. Log status: `pending`
3. Call PacketFabric API (log in `api_usage_logs`)
4. Update status: `submitted`
5. Poll for completion
6. Update status: `completed` or `failed`
7. All status changes logged in `provisioning_status_history`

---

### 5. Analytics & Monitoring
**Tables:** `query_logs`, `api_usage_logs`, `provisioning_orders`

**Queries:**
- Most common user intents
- Average response time
- API usage by endpoint
- Provisioning success rate
- User feedback analysis

---

## Sample Queries

### Find most active users
```sql
SELECT u.username, COUNT(q.query_id) as query_count
FROM users u
JOIN query_logs q ON u.user_id = q.user_id
GROUP BY u.user_id, u.username
ORDER BY query_count DESC
LIMIT 10;
```

### Track provisioning order lifecycle
```sql
SELECT
    po.order_id,
    po.service_type,
    po.status as current_status,
    json_agg(
        json_build_object(
            'status', psh.status,
            'changed_at', psh.created_at,
            'details', psh.details
        ) ORDER BY psh.created_at
    ) as status_history
FROM provisioning_orders po
LEFT JOIN provisioning_status_history psh ON po.order_id = psh.order_id
GROUP BY po.order_id, po.service_type, po.status;
```

### Semantic search for chunks
```sql
SELECT
    c.chunk_text,
    d.title,
    d.source_url,
    1 - (c.embedding <=> '[query_embedding_vector]') as similarity
FROM chunks c
JOIN documents d ON c.document_id = d.document_id
WHERE d.is_active = true
ORDER BY c.embedding <=> '[query_embedding_vector]'
LIMIT 5;
```

---

## Maintenance

### Recommended Indexes (Already Created)
- All foreign keys are indexed
- Timestamp columns for queries
- JSONB columns with GIN indexes
- Vector columns with appropriate similarity indexes

### Data Retention
- `query_logs`: 90 days (configurable)
- `api_usage_logs`: 30 days (configurable)
- `provisioning_status_history`: Indefinite (audit requirement)

### Backup Strategy
- Daily full backups
- Point-in-time recovery enabled
- Retention: 30 days

---

## Extensions Used

### uuid-ossp
Provides UUID generation functions:
```sql
uuid_generate_v4()
```

### pg_trgm
Enables trigram-based text search:
```sql
CREATE INDEX idx_documents_title_trgm ON documents USING gin (title gin_trgm_ops);
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-10-05 | Initial schema with 10 tables |

---

**Last Updated:** 2025-10-05
**Maintained By:** PacketFabric.ai Team
